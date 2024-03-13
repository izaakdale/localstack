dynamo:
	aws dynamodb create-table --endpoint-url=http://127.0.0.1:4566 --table-name orders --region=eu-west-2 --attribute-definitions AttributeName=PK,AttributeType=S AttributeName=SK,AttributeType=S --key-schema AttributeName=PK,KeyType=HASH AttributeName=SK,KeyType=RANGE --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --table-class STANDARD --output table | cat
dynamodown:
	aws dynamodb delete-table --endpoint-url=http://localhost:4566 --table-name orders --region=eu-west-2
placed-queue:
	aws sqs create-queue --endpoint-url=http://localhost:4566 --region=eu-west-2 --queue-name=order-placed-queue --profile=localstack  --output table | cat
placed-events:
	aws sns create-topic --endpoint-url=http://localhost:4566 --name order-placed-events --region eu-west-2 --profile=localstack --output table | cat
placed-sub:
	aws sns subscribe --endpoint-url=http://localhost:4566 --topic-arn=arn:aws:sns:eu-west-2:000000000000:order-placed-events --region=eu-west-2 --profile=localstack  --protocol=sqs --notification-endpoint=arn:aws:sqs:eu-west-2:000000000000:order-placed-queue --output table | cat
stored-queue:
	aws sqs create-queue --endpoint-url=http://localhost:4566 --region=eu-west-2 --queue-name=order-stored-queue --profile=localstack  --output table | cat
stored-events:
	aws sns create-topic --endpoint-url=http://localhost:4566 --name order-stored-events --region eu-west-2 --profile=localstack --output table | cat
stored-sub:
	aws sns subscribe --endpoint-url=http://localhost:4566 --topic-arn=arn:aws:sns:eu-west-2:000000000000:order-stored-events --region=eu-west-2 --profile=localstack  --protocol=sqs --notification-endpoint=arn:aws:sqs:eu-west-2:000000000000:order-stored-queue --output table | cat
placed-delete:
	aws sqs delete-message --endpoint-url=http://localhost:4566 --queue-url http://localhost:4566/000000000000/order-placed-queue --profile localstack --region=eu-west-2 --receipt-handle=$(receipt)
stored-delete:
	aws sqs delete-message --endpoint-url=http://localhost:4566 --queue-url http://localhost:4566/000000000000/order-stored-queue --profile localstack --region=eu-west-2 --receipt-handle=$(receipt)
placed-rcx:
	aws sqs receive-message --endpoint-url=http://localhost:4566 --queue-url http://localhost:4566/000000000000/order-placed-queue --profile localstack --region eu-west-2 --output json | cat
stored-rcx:
	aws sqs receive-message --endpoint-url=http://localhost:4566 --queue-url http://localhost:4566/000000000000/order-stored-queue --profile localstack --region eu-west-2 --output json | cat
publish:
	aws sns publish --endpoint-url=http://localhost:4566 --topic-arn arn:aws:sns:eu-west-2:000000000000:order-placed-events --message=$(message)
scan:
	aws dynamodb scan --endpoint-url=http://localhost:4566 --table-name orders
list-sns:
	aws sns list-topics --endpoint-url=http://localhost:4566 --region=eu-west-2

build:
	make dynamo; \
	make placed-events; \
	make placed-queue; \
	make placed-sub; \
	make stored-events; \
	make stored-queue; \
	make stored-sub;