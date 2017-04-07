FROM jenkinsci/jnlp-slave:2.62

ARG KUBECTL_VERSION=v1.5.6
ARG HELM_VERSION=v2.3.0

USER root

RUN apt-get update && apt-get install -y make && apt-get install -y build-essential g++

RUN curl -LO https://dl.k8s.io/${KUBECTL_VERSION}/kubernetes-client-linux-amd64.tar.gz \
	&& tar xzf kubernetes-client-linux-amd64.tar.gz \
	&& rm kubernetes-client-linux-amd64.tar.gz \
	&& chmod +x ./kubernetes/client/bin/kubectl \
	&& mv ./kubernetes/client/bin/kubectl /usr/local/bin/kubectl \
	&& rm -Rf ./kubernetes

RUN curl -LO https://kubernetes-helm.storage.googleapis.com/helm-${HELM_VERSION}-linux-amd64.tar.gz \
	&& tar xzf helm-${HELM_VERSION}-linux-amd64.tar.gz \
	&& rm helm-${HELM_VERSION}-linux-amd64.tar.gz \
	&& mv ./linux-amd64/helm /usr/local/bin/helm \
	&& rm -Rf ./linux-amd64
