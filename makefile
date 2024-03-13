dynamo:
	aws dynamodb create-table --endpoint-url=http://localhost:4566 --table-name $(DB_NAME) --region=$(AWS_REGION) --attribute-definitions AttributeName=PK,AttributeType=S AttributeName=SK,AttributeType=S --key-schema AttributeName=PK,KeyType=HASH AttributeName=SK,KeyType=RANGE --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --table-class STANDARD --output table | cat
dynamodown:
	aws dynamodb delete-table --endpoint-url=http://localhost:4566 --table-name $(DB_NAME) --region=$(AWS_REGION)
queue:
	aws sqs create-queue --endpoint-url=http://localhost:4566 --region=$(AWS_REGION) --queue-name=$(QUEUE_NAME) --profile=localstack  --output table | cat
notifier:
	aws sns create-topic --endpoint-url=http://localhost:4566 --name $(NOTIFIER_NAME) --region $(AWS_REGION) --profile=localstack --output table | cat
sub:
	aws sns subscribe --endpoint-url=http://localhost:4566 --topic-arn=arn:aws:sns:$(AWS_REGION):000000000000:$(NOTIFIER_NAME) --region=$(AWS_REGION) --profile=localstack  --protocol=sqs --notification-endpoint=arn:aws:sqs:$(AWS_REGION):000000000000:$(QUEUE_NAME) --output table | cat
rcx:
	aws sqs receive-message --endpoint-url=http://localhost:4566 --queue-url http://localhost:4566/000000000000/$(QUEUE_NAME) --profile localstack --region $(AWS_REGION) --output json | cat
publish:
	aws sns publish --endpoint-url=http://localhost:4566 --topic-arn arn:aws:sns:$(AWS_REGION):000000000000:$(NOTIFIER_NAME) --message=$(MESSAGE)
scan:
	aws dynamodb scan --endpoint-url=http://localhost:4566 --table-name $(DB_NAME)
list-sns:
	aws sns list-topics --endpoint-url=http://localhost:4566 --region=$(AWS_REGION)

# build:
# 	make dynamo; \
# 	make placed-events; \
# 	make placed-queue; \
# 	make placed-sub; \
# 	make stored-events; \
# 	make stored-queue; \
# 	make stored-sub;