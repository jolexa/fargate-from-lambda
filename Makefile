STACKNAME_BASE="fargate-from-lambda"
# This is a region that supports AWS Fargate
REGION="us-east-1"
# Bucket in REGION that is used for deployment
BUCKET=$(STACKNAME_BASE)
MD5=$(shell md5sum lambda/*.py | md5sum | cut -d ' ' -f 1)

deploy:
	cd lambda && \
		zip -r9 /tmp/deployment.zip *.py && \
		aws s3 cp --region $(REGION) /tmp/deployment.zip \
			s3://$(BUCKET)/$(MD5).zip && \
		rm -rf /tmp/deployment.zip
	aws cloudformation deploy \
		--template-file deployment.yml \
		--stack-name $(STACKNAME_BASE) \
		--region $(REGION) \
		--parameter-overrides \
		"Bucket=$(BUCKET)" \
		"md5=$(MD5)" \
		--capabilities CAPABILITY_IAM || exit 0

retag:
	docker pull jolexa/echo-10:latest
	docker tag jolexa/echo-10:latest \
		$(shell aws cloudformation --region $(REGION) describe-stacks --stack-name $(STACKNAME_BASE) --query Stacks[0].Outputs[0].OutputValue):latest
	@exec $(shell aws ecr --region $(REGION) get-login --no-include-email)
	docker push $(shell aws cloudformation --region $(REGION) describe-stacks --stack-name $(STACKNAME_BASE) --query Stacks[0].Outputs[0].OutputValue):latest
