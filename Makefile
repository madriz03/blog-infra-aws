empty:
	@echo "Comando equivocado"

deploy-stack:
	aws cloudformation deploy --template-file ./blog-infra-aws.yaml --stack-name blog-infra \
	--parameter-overrides CidrVpc=10.0.0.0/24 CidrPublicOne=10.0.0.0/26 CidrPublicTwo=10.0.0.64/26 \
	CidrPrivateOne=10.0.0.128/26 CidrPrivateTwo=10.0.0.192/26 DbName=blogdb DbUsername=javidev \
	DbMasterUserPassword=hiphop03 AsgImageId=ami-0af9efaeeaf6bb32c AsgKeyName=key-learn \
	--capabilities CAPABILITY_NAMED_IAM \
	--profile learn \
	--region us-east-2

delete-stack:
	aws cloudformation delete-stack --stack-name blog-infra \
	--profile learn \
	--region us-east-2