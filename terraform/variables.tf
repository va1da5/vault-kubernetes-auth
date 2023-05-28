variable "kubernetes_namespace" {
  type    = string
  default = "demo-app"
}

variable "kubernetes_host" {
  type        = string
  description = "Host must be a host string, a host:port pair, or a URL to the base of the Kubernetes API server"
}

variable "kubernetes_ca_cert" {
  default     = "minikube.crt"
  type        = string
  description = "PEM encoded CA cert for use by the TLS client used to talk with the Kubernetes API"
}

variable "kubernetes_token_reviewer" {
  type        = string
  description = "A service account JWT used to access the TokenReview API to validate other JWTs during login. If not set the JWT used for login will be used to access the API"
}
