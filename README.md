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
### 環境変数
```
OPENAI_API_KEY='hogehoge'
WEAVIATE_INDEX_CODE='CodeVectorAlba'
WEAVIATE_INDEX_SUMMARY='SummaryVectorAlba'
WEAVIATE_INDEX_CODE_CUSTOM='CodeVectorCustomAlba'
WEAVIATE_INDEX_SUMMARY_CUSTOM='SummaryVectorDataCustomAlba'
WEAVIATE_INDEX_WEB="WebVectorIndexAlba"
```

### 実行
```
$ ./bin/rake search:normal['これはなんですか？']
```
