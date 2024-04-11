.PHONY: create-schema create-data

create-schema:
    ./bin/rake schema:create

create-data:
    ./bin/rake vector:insert['tmp/code']