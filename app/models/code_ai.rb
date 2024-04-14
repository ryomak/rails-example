class CodeAi

  def initialize(index: "Langchain")
    @llm = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"], llm_options:{
      model: "gpt-4",
    })
    @vector_search =  Langchain::Vectorsearch::Weaviate.new(
      url: 'http://localhost:8080',
      api_key: '',
      index_name: index,
      llm: @llm,
    )

  end

  def create_schema
    @vector_search.create_default_schema
  end

  def input(texts)
    @vector_search.add_texts(texts: texts)
  end

  def load_from_dir(path, extensions: ['rb'])
    Dir.glob(File.join(path, "**/*")).map do |file|
      next unless extensions.include?(File.extname(file).delete('.'))
      Langchain::Loader.load(file) do |raw_data, options|
        "file:\n#{file} code:\n#{raw_data}"
      end
    rescue
      nil
    end.flatten.compact
  end

  def ask_normal(question)
    response = @vector_search.ask(question: question)
    response.raw_response.dig("choices", 0, "message", "content")
  end

  def ask_rag_fusion(question)
    queries = generate_queries(question)
    rank_hash = generate_rank_hash(queries)
    ranked_queries = reciprocal_rank_fusion(rank_hash)

    context = ranked_queries.map { |doc, _| doc }.join("\n- ")

    prompt_template = %Q{あなたはコードサポートAIです。
下記、制約を厳守しながら、コンテキストからユーザの質問に関西弁の日本語で回答してください。

制約)
- コンテキストを元に回答すること
- 対象のファイル名やクラス名は必ず明記すること

コンテキスト)
{context}}
    prompt = ::Langchain::Prompt::PromptTemplate.new(template: prompt_template, input_variables: ["context"]).format(context: context)
    chat_custom(prompt, question)
  end

  def ask_custom(question)

    context = search_custom(question: question)

    prompt_template = %Q{あなたはコードサポートAIです。
下記、制約を厳守しながら、コンテキストからユーザの質問に関西弁の日本語で回答してください。

制約)
- コンテキストを元に回答すること
- 対象のファイル名やクラス名は必ず明記すること

コンテキスト)
{context}}
    prompt = ::Langchain::Prompt::PromptTemplate.new(template: prompt_template, input_variables: ["context"]).format(context: context)
    chat_custom(prompt, question)
  end

  private

  def chat_custom(prompt, question)
    res = @llm.chat(
      messages: [{role: "system", content: prompt},{role:"user", content:question}],
      tools: [
        {
          "type": "function",
          "function": {
            "name": "generate_code_ai_reply",
            "description": "コードサポートAIの回答を出力する",
            "parameters": {
              "type": "object",
              "properties": {
                "reply": {
                  "type": "string",
                  "description": "質問に対する回答の文章。関西弁を使用"
                },
                "code": {
                  "type": "string",
                  "description": "説明で使用する実際のコード。内部実装であったり、使い方を説明するために利用"
                }
              },
              "required": %w[reply code]
            }
          }
        }
      ],
      tool_choice: {"type": "function", "function": {"name": "generate_code_ai_reply"}},
    )
    json = JSON.parse(res.raw_response.dig("choices",0,"message","tool_calls",0,"function","arguments"))
    "#{json['reply']}\n```ruby\n#{json['code']}\n```"
  end

  def generate_queries(query)
    queries = @llm.chat(messages: [
      {"role": "system", "content": "You are a helpful assistant that generates multiple search queries based on a single input query."},
      {"role": "user", "content": "Generate multiple search queries related to: #{query}"},
      {"role": "user", "content": "english (4 queries):"}
    ]).completion
    queries.strip.split("\n")
  end

  ## vector_searchから似ているコードを取ってくる。その中で参照すべき関数がまだあった場合は、再起的に次のメソッド・変数を呼び出す。そしてすべての結果を結合して返す
  def search_custom(question:, num:0)
    results = @vector_search.similarity_search(query: question, k: 1).map { |data| data['content'] }

    result = results[0]
    combined_results = result

    puts "================"
    puts num
    puts "================"

    if has_reference?(result,num)
      q = @llm.chat(messages: [
        {"role": "system", "content": "与えられたコードスニペットの中で定義されていない関数や実装を取り出します。exampleを参考にして出力してください\nexample) class:Hogehoge hugahuga"},
        {"role": "user", "content": result}
      ]).completion
      if q != question
        p "=========next search query========="
        p q
        p "================"
        combined_results += search_custom(question: q, num: num + 1)
      end
    end

    combined_results
  end

  def has_reference?(result, num)
    if num == 0
      return true
    end
    if num > 3
      return false
    end

    @llm.chat(messages: [
      {"role": "system", "content": "You are a helpful assistant that checks if a code snippet has a reference to another function or variable. If exist then return yes else return no"},
      {"role": "user", "content": result}
    ]).completion.include?("no")
  end

  # Reciprocal Rank Fusion algorithm
  def reciprocal_rank_fusion(search_results_dict, k = 60)
    fused_scores = {}

    puts "Initial individual search result ranks:"

    search_results_dict.each do |query, doc_scores|
      doc_scores.sort_by { |_, score| score.to_f }.reverse.each_with_index do |(doc, score), rank|
        fused_scores[doc] ||= 0
        previous_score = fused_scores[doc]
        fused_scores[doc] += 1.0 / (rank + k)
        puts "Updating score from #{previous_score} to #{fused_scores[doc]} based on rank #{rank} in query '#{query}'"
      end
    end

    reranked_results = fused_scores.sort_by { |_, score| -score }.to_h

    puts "Reranked documents: #{reranked_results.size}"
    reranked_results.each do |doc, score|
      puts '---'
      puts "RRF score: #{score}"
    end

    reranked_results
  end


  def generate_rank_hash(queries)
    rank_hash = {}
    queries.each do |query|
      rank_hash[query] = @vector_search.similarity_search(query: query, k: 5).map { |data| data['content'] }
    end
    rank_hash
  end

end