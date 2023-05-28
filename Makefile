VAULT_HELM_CHART_VERSION := 0.24.1
VAULT_HELM_CHART := https://github.com/hashicorp/vault-helm/archive/refs/tags/v$(VAULT_HELM_CHART_VERSION).zip

.PHONY: help
help:
	@echo

.PHONY: up
up:
	@cat kubernetes/* | kubectl apply -f -
	@helm repo add hashicorp https://helm.releases.hashicorp.com
	@helm install vault hashicorp/vault --values vault.values.yml

.env:
	cp sample.env .env

.PHONY: apply-config
apply-config: .env
	@export $$(cat .env | xargs); \
		cd terraform; \
		terraform init; terraform apply -auto-approve

.PHONY: restart-app
restart-app:
	kubectl delete -f kubernetes/demo-app.yml
	kubectl create -f kubernetes/demo-app.yml


.PHONY: restart-vault
restart-vault: clear
	kubectl delete -f kubernetes/vault.yml
	kubectl create -f kubernetes/vault.yml


.PHONY: clear
clear:
	@find terraform -type d -name ".terraform" -exec rm -rf {} \;
	@find terraform -type f -name "terraform.tfstate*" -exec rm -rf {} \;
	@find terraform -type f -name ".terraform.lock.hcl" -exec rm -rf {} \;

.PHONY: down
down: clear
	@helm uninstall vault
	@cat kubernetes/* | kubectl delete -f -

