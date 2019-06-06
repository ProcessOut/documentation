ENVIRONMENT=staging
BUCKET=docs.processout.ninja
DISTRIBUTION=E3GA5RMWGG0DB3

.PHONY: build
build:
	bundle exec middleman build

.PHONY: test
test:
	bundle exec middleman

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