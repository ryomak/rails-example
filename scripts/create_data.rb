require_relative '../app/lib/vector_store/client.rb'
require_relative '../app/lib/llm/client.rb'

class Schema
  def self.execute
    client = VectorStore::Client.new
    llm = LLM::Client.new
    key = "メモ"

    client.create_data(key, "メモには120文字以上の文章をいれることができません", llm.create_vector(key).dig("data", 0, "embedding"))
  end
end

Schema.execute
