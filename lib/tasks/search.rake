namespace :search do
  desc <<~MSG
    dataをvectorに入れる
  MSG

  task :normal, ['question'] => :environment do |task, args|
    Rails.logger.info '===============search normal Start==============='
    qa = CodeAi.new
    result = qa.ask_normal(args[:question])
    puts result
    Rails.logger.info '===============End==============='
  end

  task :fusion, ['question'] => :environment do |task, args|
    Rails.logger.info '===============search fusion Start==============='

    qa = CodeAi.new custom: true

    result = qa.ask_rag_fusion(args[:question])
    puts result
    Rails.logger.info '===============End==============='
  end

  task :custom, ['question'] => :environment do |task, args|
    Rails.logger.info '===============search custom Start==============='
    qa = CodeAi.new custom: true
    result = qa.ask_custom(args[:question])
    puts result
    Rails.logger.info '===============End==============='
  end

  task :web, ['question'] => :environment do |task, args|
    Rails.logger.info '===============search custom Start==============='
    @llm = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"], llm_options:{
      model: "gpt-4",
    })
    @vector_search =  Langchain::Vectorsearch::Weaviate.new(
      url: 'http://localhost:8080',
      api_key: '',
      index_name: ENV["WEAVIATE_INDEX_WEB"],
      llm: @llm,
    )
    puts @vector_search.ask(question: args[:question], k: 3).raw_response.dig("choices", 0, "message", "content")
    Rails.logger.info '===============End==============='
  end
end
