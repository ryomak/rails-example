class CodeAi

  def initialize(custom: false)
    @llm = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"], llm_options:{
      model: "gpt-4",
    })
    @code_vector_search =  Langchain::Vectorsearch::Weaviate.new(
      url: 'http://localhost:8080',
      api_key: '',
      index_name: custom ? ENV["WEAVIATE_INDEX_CODE_CUSTOM"] : ENV["WEAVIATE_INDEX_CODE"],
      llm: @llm,
    )
    @summary_vector_search = Langchain::Vectorsearch::Weaviate.new(
      url: 'http://localhost:8080',
      api_key: '',
      index_name: custom ? ENV["WEAVIATE_INDEX_SUMMARY_CUSTOM"] : ENV["WEAVIATE_INDEX_SUMMARY"],
      llm: @llm,
    )
  end

  def ask_normal(question)
    response = @code_vector_search.ask(question: question)
    response.raw_response.dig("choices", 0, "message", "content")
  end

  def ask_rag_fusion(question)
    vector_search = @code_vector_search
    queries = generate_queries(question)
    rank_hash = generate_rank_hash(queries,vector_search)
    ranked_queries = reciprocal_rank_fusion(rank_hash)

    context = ranked_queries.map { |doc, _| doc }.join("\n- ")
    ask_base(question, context)
  end

  def ask_custom(question)
    code_data = @code_vector_search.similarity_search(query: question, k: 3).map { |data| data['content'] }
    summary_data = @summary_vector_search.similarity_search(query: question, k: 3).map { |data| data['content'] }
    context = %Q{
- サマリ
  #{summary_data.join("\n")}
- コード
  #{code_data.join("\n")}
    }


    ask_base(question, context)
  end

  private

  ## helper methods
  def ask_base(question, context)

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

  ####
  # rag fusion
  ###
  def generate_queries(query)
    queries = @llm.chat(messages: [
      {"role": "system", "content": "You are a helpful assistant that generates multiple search queries based on a single input query."},
      {"role": "user", "content": "Generate multiple search queries related to: #{query}"},
      {"role": "user", "content": "english (4 queries):"}
    ]).completion
    queries.strip.split("\n")
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


  def generate_rank_hash(queries,search)
    rank_hash = {}
    queries.each do |query|
      rank_hash[query] = search.similarity_search(query: query, k: 5).map { |data| data['content'] }
    end
    rank_hash
  end

end