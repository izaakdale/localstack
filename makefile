dynamo:
    aws dynamodb create-table --endpoint-url=http://localhost:4566 --table-name $(DB_NAME) --region=$(AWS_REGION) --attribute-definitions AttributeName=PK,AttributeType=S AttributeName=SK,AttributeType=S --key-schema AttributeName=PK,KeyType=HASH AttributeName=SK,KeyType=RANGE --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --table-class STANDARD --output table | cat
dynamodown:
    aws dynamodb delete-table --endpoint-url=http://localhost:4566 --table-name $(DB_NAME) --region=$(AWS_REGION)
queue:
    aws sqs create-queue --endpoint-url=http://localhost:4566 --region=$(AWS_REGION) --queue-name=$(QUEUE_NAME) --output table | cat
queuedown:
    aws sqs delete-queue --endpoint-url=http://localhost:4566 --region=$(AWS_REGION) --queue-url=http://sqs.$(AWS_REGION).localhost.localstack.cloud:4566/000000000000/$(QUEUE_NAME)
notifier:
    aws sns create-topic --endpoint-url=http://localhost:4566 --region $(AWS_REGION) --name $(NOTIFIER_NAME) --output table | cat
notifierdown:
    aws sns delete-topic --endpoint-url=http://localhost:4566 --region $(AWS_REGION) --topic-arn arn:aws:sns:$(AWS_REGION):000000000000:$(NOTIFIER_NAME)
sub:
    aws sns subscribe --endpoint-url=http://localhost:4566 --topic-arn=arn:aws:sns:$(AWS_REGION):000000000000:$(NOTIFIER_NAME) --region=$(AWS_REGION) --protocol=sqs --notification-endpoint=arn:aws:sqs:$(AWS_REGION):000000000000:$(QUEUE_NAME) --output table | cat
subdown:
    @if [ $(SUB_ID) != "" ]; then\
        aws sns unsubscribe --endpoint-url=http://localhost:4566 --subscription-arn=arn:aws:sns:$(AWS_REGION):000000000000:$(NOTIFIER_NAME):$(SUB_ID);\
    else\
        echo "Subscription ID / SUB_ID not found";\
    fi
rcx:
    aws sqs receive-message --endpoint-url=http://localhost:4566 --queue-url http://localhost:4566/000000000000/$(QUEUE_NAME) --region $(AWS_REGION) --output json | cat
publish:
    aws sns publish --endpoint-url=http://localhost:4566 --topic-arn arn:aws:sns:$(AWS_REGION):000000000000:$(NOTIFIER_NAME) --message=$(MESSAGE)
scan:
    aws dynamodb scan --endpoint-url=http://localhost:4566 --table-name $(DB_NAME)
list-sns:
    aws sns list-topics --endpoint-url=http://localhost:4566 --region=$(AWS_REGION)
 
up:
    make dynamo; \
    make queue; \
    make notifier; \
    make sub;
 
down:
    make dynamodown; \
    make queuedown; \
    make notifierdown;