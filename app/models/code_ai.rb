class CodeAi

  def initialize(custom: false)
    @llm = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"])
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
    response.completion
  end

  def ask_rag_fusion(question)
    vector_search = @code_vector_search
    ## 質問を元に複数の検索クエリを生成
    queries = generate_queries(question)
    ## 検索クエリ毎に関連情報をとってくる
    rank_hash = generate_rank_hash(queries,vector_search)
    ## Reciprocal Rank Fusion(RRF)で結果を統合
    context = reciprocal_rank_fusion(rank_hash)

    ask_base(question, context)
  end

  def ask_custom(question)
    code_data = @code_vector_search.similarity_search(query: question, k: 3).map { |data| data['content'] }
    summary_data = @summary_vector_search.similarity_search(query: question, k: 1).map { |data| data['content'] }
    context = %Q{
### サマリ
  #{summary_data.join("\n")}
### コード
  #{code_data.join("\n")}
    }

    puts context

    ask_base(question, context)
  end

  private

  ## helper methods
  def ask_base(question, context)

    prompt_template = %Q{あなたは、クロちゃんです。
下記、制約を厳守しながら、コンテキストの情報から質問に回答してください。
また、出力は出力例に従うこと

## 制約
- コンテキストを元に回答すること
- 対象のファイル名やクラス名は必ず明記すること
- 日本語で回答すること
- 語尾に必ず「だしん」や「しん」をつけること。説明中にもつけること
- 一定の確率で、「わわわわー」や「なんなのぉー」と冒頭で言うこと

## 出力例
説明)
- hogehoge
使い方)
```ruby
aaaaaa.bbbbbb
```


## コンテキスト
```
{context}
```
}
    prompt = Langchain::Prompt::PromptTemplate.new(
      template: prompt_template,
      input_variables: ["context"]
    ).format(context: context)
    #prompt = Langchain::Vectorsearch::Base.new(llm: @llm).generate_rag_prompt(question: question, context: context)
    puts context
    @llm.chat(
      messages: [{role: "system", content: prompt},{role:"user", content:question}],
    ).completion
  end

  def chat_custom(prompt, question)
    @llm.chat(
      messages: [{role: "system", content: prompt},{role:"user", content:question}],
    ).completion
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

    search_results_dict.each do |query, docs|
      docs.each_with_index do |doc, rank|
        fused_scores[doc] ||= 0
        fused_scores[doc] += 1.0 / (rank + k)
      end
    end

    reranked_results = fused_scores.sort_by { |_, score| -score }.to_h

    puts "Reranked documents: #{reranked_results.size}"
    reranked_results.each do |doc, score|
      puts '---'
      puts "RRF score: #{score}"
    end

    reranked_results.keys[0..3].join("\n\n---\n\n")
  end


  def generate_rank_hash(queries,search)
    rank_hash = {}
    queries.each do |query|
      rank_hash[query] = search.similarity_search(query: query, k: 5).map { |data| data['content'] }
    end
    rank_hash
  end



end