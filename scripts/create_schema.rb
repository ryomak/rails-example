require_relative '../app/lib/vector_store/client.rb'

class Schema
  def self.execute
    try do
      client = VectorStore::Client.new
      client.create_schema
    end

    try do
      langchain = CodeAi.new
      langchain.create_schema
    end
  end
end

Schema.execute
