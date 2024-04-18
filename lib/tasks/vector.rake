namespace :vector do
  desc <<~MSG
    dataをvectorに入れる
  MSG

  task :insert, ['dir'] => :environment do |task, args|
    Rails.logger.info '===============vector:inert Start==============='
    converter = FileToVectorConverter.new index: ENV["WEAVIATE_INDEX_CODE"]
    docs = converter.load_from_dir(args[:dir] || "tmp/code")
    converter.save_vector(docs)
    Rails.logger.info '===============End==============='
  end

  task :insert_custom, ['dir'] => :environment do |task, args|
    Rails.logger.info '===============vector:inert_custom Start==============='
    converter = FileToVectorConverter.new index: ENV["WEAVIATE_INDEX_SUMMARY_CUSTOM"]
    converter.load_from_dir(args[:dir] || "tmp/code") do |file, raw_data|
      summary = converter.summarize_for_input(file, raw_data)
      converter.save_vector([summary])
      raw_data
    end

    code_converter = FileToVectorConverter.new index: ENV["WEAVIATE_INDEX_CODE_CUSTOM"]
    docs = code_converter.load_from_dir(args[:dir] || "tmp/code")
    code_converter.save_vector(docs)
    Rails.logger.info '===============End==============='
  end

  task :insert_web, ['dir'] => :environment do |task, args|
    Rails.logger.info '===============vector:inert_web Start==============='
    @llm = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"], llm_options:{
      model: "gpt-4",
    })
    @vector_search =  Langchain::Vectorsearch::Weaviate.new(
      url: 'http://localhost:8080',
      api_key: '',
      index_name: ENV["WEAVIATE_INDEX_WEB"],
      llm: @llm,
    )
    begin
      ## 拡張子にrbが含まれているので、blockで処理を行う
      res = Langchain::Loader.load args[:dir] do |raw_data, options|
        raw_data
      end.map(&:value)
      puts res.length
    rescue => e

    end
    @vector_search.add_texts(texts: res)
    Rails.logger.info '===============End==============='
  end
end

#https://ruby-style-guide.shopify.dev/