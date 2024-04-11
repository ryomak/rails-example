class CodeAi

  def initialize
    @llm = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"], llm_options:{
      model: "gpt-4-vision-preview",
    })
    @vector_search =  Langchain::Vectorsearch::Weaviate.new(
      url: 'http://localhost:8080',
      api_key: '',
      index_name: "Langchain",
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
      Langchain::Loader.load(file, {source: file}) do |raw_data, options|
        "file:\n#{file} code:\n#{raw_data}"
      end
    rescue
      nil
    end.flatten.compact
  end

  def ask_normal(question)
    @vector_search.ask(question: question)
  end

  def ask_custom(question)
    summary = @llm.complete(prompt: "下記内容から重要なファイル名や関数名を書き出して.\n内容) #{question}").completion
    similar = @vector_search.similarity_search(query: summary, k: 3)

    ## function callings(tool)を使ってみるとアウトプットはもうちょっと固定できそう
    prompt = %Q{あなたは優秀なプログラマーです。
下記、制約を厳守しながら、コンテキストからユーザの質問に関西弁の日本語で答えてください。

制約)
- コンテキストを元に回答すること
- 対象のファイル名やクラス名は必ず明記すること
- 最後に具体的な実装方法を記載すること

コンテキスト)
- #{similar.map { |data| data['content'] }.join("\n- ")}}
    @llm.chat(messages: [{role: "system", content: prompt},{role:"user", content:question}]).completion
  end

end