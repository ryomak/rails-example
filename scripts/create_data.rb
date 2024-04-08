require_relative '../app/lib/vector_store/client.rb'
require_relative '../app/lib/llm/client.rb'

class Schema
  def self.execute
    client = VectorStore::Client.new
    llm = LLM::Client.new
    key = "メモ"

    client.create_data(key, "メモには120文字以上の文章をいれることができません", llm.create_vector(key))


    langchain = Qa.new
    langchain.input(["メモには120文字以上の文章をいれることができません"])
  end
end

Schema.execute
