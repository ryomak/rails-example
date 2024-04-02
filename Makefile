.PHONY: test-openai create-schema create-data

RAILS_RUNNER := ./bin/rails runner

test-openai:
	$(RAILS_RUNNER) scripts/test_openai.rb

create-schema:
	$(RAILS_RUNNER) scripts/create_schema.rb

create-data:
	$(RAILS_RUNNER) scripts/create_data.rb