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

  def load_from_dir(path, extensions:['rb'], &block)
    Dir.glob(File.join(path, "**/*")).map do |file|
      next unless extensions.include?(File.extname(file).delete('.'))
      if block_given?
        raw_data = File.read(file)
        block.call(file, raw_data)
      else
        Langchain::Loader.load(file) do |raw_data, options|
          "file:\n#{file} code:\n#{raw_data}"
        end.value
      end
    rescue => e
      puts e
      nil
    end.flatten.compact
  end

  def summarize_for_input(file, raw_data)
    @llm.chat(messages: [
      {"role": "user", "content": %Q{#{file}のコードです。コードの内容を多くても２００文字程度で要約してください。そしてフォーマットに沿って出力してください。
また、複数のクラスや関数がある場合は、簡単な処理をリストアップしてください。関数の時は、引数や返り値も記載してください。

フォーマット)
### ファイル名
xxx.rb
### 要約
yyyy,xxxx
### 使い方
zzzzzz.
### クラスや関数一覧
AAAA:BBBB  CCCCという機能を提供する関数です。引数はDDDDで、返り値はEEEEです。

コード)
```ruby[#{file}]
#{raw_data}
```
}},
    ]).completion
  end
end