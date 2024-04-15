namespace :schema do
  desc <<~MSG
    スキーマ関連タスク
  MSG

  task create: :environment do
    ## service example
    ##begin
    ##  client = VectorStore::Client.new
    ##  client.create_schema
    ##rescue => e
    ##  Rails.logger.error e
    ##end

    begin
      [ENV['WEAVIATE_INDEX_CODE'], ENV["WEAVIATE_INDEX_SUMMARY"], ENV["WEAVIATE_INDEX_CODE_CUSTOM"], ENV["WEAVIATE_INDEX_SUMMARY_CUSTOM"]].each do |index|
        pp index
        vector_search = FileToVectorConverter.new index: index
        pp vector_search.create_schema
      end
    rescue => e
      Rails.logger.error e
    end
  end
end
