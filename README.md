# README
Langchain.rbを試す用のレポジトリ

## Usage
### Weaviate準備
```
$ docker compose up
$ ./bin/rake schema:create

## target Repositoryをtmp/codeに入れる
$ ./bin/rake vector:insert
$ ./bin/rake vector:insert_custom
```

### 実行
```
$ ./bin/rake search:normal['これはなんですか？']
```