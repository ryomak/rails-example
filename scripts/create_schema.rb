require_relative '../app/lib/vector_store/client.rb'

class Schema
  def self.execute
    client = VectorStore::Client.new
    client.create_schema
    puts client.list
  end
end

Schema.execute
