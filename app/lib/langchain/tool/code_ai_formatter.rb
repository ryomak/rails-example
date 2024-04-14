# frozen_string_literal: true

module Langchain::Tool
  class CodeAiFormatter < Base
    #
    # code_ai
    #
    NAME = "code_ai_formatter"
    ANNOTATIONS_PATH = "#{__dir__}/code_ai_formatter.json"

    def initialize()
    end

    def execute(reply:,code:)
      "#{reply}\n```ruby#{code}```"

    end
  end
end