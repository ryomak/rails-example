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
    docs = converter.load_from_dir(args[:dir] || "tmp/code") do |file, raw_data|
      summary = converter.summarize_for_input(file, raw_data)
      converter.save_vector([summary])
    end

    ##converter.save_vector(docs)

    code_converter = FileToVectorConverter.new index: ENV["WEAVIATE_INDEX_CODE_CUSTOM"]
    docs = code_converter.load_from_dir(args[:dir] || "tmp/code")
    code_converter.save_vector(docs)
    Rails.logger.info '===============End==============='
  end
end
