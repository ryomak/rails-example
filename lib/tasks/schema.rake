namespace :schema do
  desc <<~MSG
    スキーマ関連タスク
  MSG

  task create: :environment do
    begin
      client = VectorStore::Client.new
      client.create_schema
    rescue => e
      Rails.logger.error e
    end

    begin
      ai = CodeAi.new
      ai.create_schema
    rescue => e
      Rails.logger.error e
    end
  end
end
