class FileToVectorConverter
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

  def save_vector(texts)
    @vector_search.add_texts(texts: texts)
  end

  def load_from_dir(path, extensions:['rb','md','erb'], &block)
    Dir.glob(File.join(path, "**/*")).map do |file|
      next unless extensions.include?(File.extname(file).delete('.'))
      if block_given?
        raw_data = File.read(file)
        block.call(file, raw_data)
      else
        Langchain::Loader.load(file) do |raw_data, options|
          "file:\n#{file} code:\n#{raw_data}"
        end.chunks.map(&:text)
      end
    rescue => e
      puts e
      nil
    end.flatten.compact
  end

  def summarize_for_input(file, raw_data)
    @llm.chat(messages: [
      {"role": "user", "content": %Q{#{file}のコードです。処理を200文字程度で要約してください。具体的な処理が不明な場合は推測してください。
また、複数のクラスや関数がある場合は、簡単な処理をリストアップしてください。関数名・引数やクラスの変数なども記載してください。出力例に従って記載してください。

```ruby[#{file}]
#{raw_data}
```

出力例)
- ファイル名: hoge.rb
- 関数・クラス名: hogehoe
- 処理: hugahuga
- 引数: xxx　意図: xxxx
- 出力: hogehoge
}},
    ]).completion
  end
end