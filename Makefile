ENVIRONMENT=staging
BUCKET=docs.processout.ninja
DISTRIBUTION=E3GA5RMWGG0DB3

.PHONY: build
build:
	docker run -v $(shell pwd):/usr/src/app -p 4567:4567 -p 1234:1234 -it $(shell docker build -q .) middleman build

.PHONY: test
test:
	@echo "####################################################"
	@echo "## SERVER WILL BE HOSTED ON http://127.0.0.1:4567 ##"
	@echo "####################################################"
	docker run -v $(shell pwd):/usr/src/app -p 4567:4567 -p 1234:1234 -it $(shell docker build -q .) middleman server

.PHONY: deploy-staging
deploy-staging: deploy

.PHONY: deploy-production
deploy-production: ENVIRONMENT=production
deploy-production: BUCKET=docs.processout.com
deploy-production: DISTRIBUTION=EX89GBCWQ9F9S
deploy-production: deploy

.PHONY: deploy
deploy: build sync invalidate

.PHONY: sync
sync:
	aws-vault exec ${ENVIRONMENT}Admin -- aws s3 sync build/ s3://${BUCKET}/ --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers

.PHONY: invalidate
invalidate:
	aws-vault exec ${ENVIRONMENT}Admin -- aws cloudfront create-invalidation --distribution-id=${DISTRIBUTION} --paths '/*'