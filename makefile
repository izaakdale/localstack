dynamo:
	aws dynamodb create-table --endpoint-url=http://localhost:4566 --table-name $(DB_NAME) --region=eu-west-2 --attribute-definitions AttributeName=PK,AttributeType=S AttributeName=SK,AttributeType=S --key-schema AttributeName=PK,KeyType=HASH AttributeName=SK,KeyType=RANGE --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --table-class STANDARD --output table | cat
dynamodown:
	aws dynamodb delete-table --endpoint-url=http://localhost:4566 --table-name $(DB_NAME) --region=eu-west-2
queue:
	aws sqs create-queue --endpoint-url=http://localhost:4566 --region=eu-west-2 --queue-name=$(QUEUE_NAME) --profile=localstack  --output table | cat
notifier:
	aws sns create-topic --endpoint-url=http://localhost:4566 --name $(NOTIFIER_NAME) --region eu-west-2 --profile=localstack --output table | cat
sub:
	aws sns subscribe --endpoint-url=http://localhost:4566 --topic-arn=arn:aws:sns:eu-west-2:000000000000:$(NOTIFIER_NAME) --region=eu-west-2 --profile=localstack  --protocol=sqs --notification-endpoint=arn:aws:sqs:eu-west-2:000000000000:$(QUEUE_NAME) --output table | cat
rcx:
	aws sqs receive-message --endpoint-url=http://localhost:4566 --queue-url http://localhost:4566/000000000000/$(QUEUE_NAME) --profile localstack --region eu-west-2 --output json | cat
publish:
	aws sns publish --endpoint-url=http://localhost:4566 --topic-arn arn:aws:sns:eu-west-2:000000000000:$(NOTIFIER_NAME) --message=$(MESSAGE)
scan:
	aws dynamodb scan --endpoint-url=http://localhost:4566 --table-name $(DB_NAME)
list-sns:
	aws sns list-topics --endpoint-url=http://localhost:4566 --region=eu-west-2

# build:
# 	make dynamo; \
# 	make placed-events; \
# 	make placed-queue; \
# 	make placed-sub; \
# 	make stored-events; \
# 	make stored-queue; \
# 	make stored-sub;