.PHONY: test-openai
test-openai:
    ./bin/rails runner scripts/test_openai.rb
.PHONY: create-schema
create-schema:
    ./bin/rails runner scripts/create_schema.rb