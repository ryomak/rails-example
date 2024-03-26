require_relative '../app/lib/llm/llm.rb'

class TestOpenAI

  def initialize
    @client = LLM::Client.new
  end

  def list
    puts @client.test_chat("What is the capital of France?")
  end
end

TestOpenAI.new.list
