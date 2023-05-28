# HashiCorp Vault Kubernetes Setup

This is a simple proof-of-concept project that provides instructions on how to configure [HashiCorp Vault](https://www.vaultproject.io/) with [Kubernetes authentication](https://developer.hashicorp.com/vault/docs/auth/kubernetes) using [Minikube](https://minikube.sigs.k8s.io/docs/start/). The purpose of it is to establish trust between Kubernetes and Vault, allowing containers to prove their identity and access only a narrow set of allowed secrets.

## Prerequisites

- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [HELM](https://helm.sh/)
- [Make](https://www.gnu.org/software/make/)
- [HashiCorp Vault](https://www.vaultproject.io/)
- [K9s](https://k9scli.io/) _Optional_

## Guide

```bash
# start local Kubernetes cluster
minikube start

# start containers
make up

# expose Vault to localhost
kubectl port-forward service/vault 8200:8200 &

# manually create a long-lived API token for the vault ServiceAccount
# raised feature request is still pending https://github.com/hashicorp/vault-helm/issues/883
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: vault-agent-token
  annotations:
    kubernetes.io/service-account.name: vault
type: kubernetes.io/service-account-token
EOF

# get secret values. The values needs to be base64 decoded before using
kubectl get secret/vault-agent-token -o yaml

# decode token
kubectl get secret vault-agent-token -o yaml | grep "token:" | awk {'print $2'} | base64 -d

# create .env file
make .env

# update value in the .env file used for Vault configuration
KUBERNETES_TOKEN_REVIEWER=ey...

# update minikube.crt file from "ca.crt: ..." value
kubectl get secret vault-agent-token -o yaml | grep "ca.crt:" | awk {'print $2'} | base64 -d > terraform/minikube.crt

# apply Vault configuration
make apply-config

# restart demo application
make restart-app

# get demo pod name
DEMO_POD=$(kubectl get pods --namespace demo-app | grep demo-app | awk {'print $1'})

# get pod logs
kubectl logs $DEMO_POD --namespace demo-app

# get container Vault access token
kubectl exec -it $DEMO_POD --namespace demo-app -- /bin/sh -c "cat /vault/secrets/token"

# set Vault context locally for further testing
export VAULT_TOKEN=hvs.CAESIKTJoFLaG....
export VAULT_ADDR=http://localhost:8200

# get details about the token
vault token lookup

# get secrets allowed for Kubernetes role
vault kv get secret/kubernetes/demo/credentials

# attempt to get other secrets from Vault
vault kv get secret/user/credentials
# this should fail dues to insufficient access permissions provided to the machine identity

# set back the root token
export VAULT_TOKEN=root

# get secret
vault kv get secret/user/credentials

# remove everything
make down
```

## Notes

```bash
# change logging level to debug
curl -X POST \
    -H "X-Vault-Token: root" \
    -H "Content-Type: application/json" \
    -d '{"level": "debug"}'\
    http://127.0.0.1:8200/v1/sys/loggers
```

## References

- [Manually create an API token for a ServiceAccount](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-an-api-token-for-a-serviceaccount)
- [Vault Agent with Kubernetes](https://developer.hashicorp.com/vault/tutorials/kubernetes/agent-kubernetes)
- [Vault Agent Sidecar Injector Annotations](https://developer.hashicorp.com/vault/docs/platform/k8s/injector/annotations)
- [Vault Terraform Provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
