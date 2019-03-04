FROM jenkins/jnlp-slave:3.27-1

ARG KUBECTL_VERSION=v1.12.6
ARG HELM_VERSION=v2.12.2
ARG PROMETHEUS_VERSION=2.3.2
ARG LEIN_VERSION=2.8.1

USER root

RUN apt-get update && apt-get install -y make && apt-get install -y build-essential g++ python-pip python3-pip jq libyaml-dev libpython2.7-dev libpython-dev python-virtualenv python3 python3 python3-venv libpython3-dev python3-nose mysql-client
RUN pip install awscli

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
	&& chmod +x ./kubectl \
	&& mv ./kubectl /usr/local/bin/kubectl

RUN curl -LO https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz \
	&& tar xzf helm-${HELM_VERSION}-linux-amd64.tar.gz \
	&& rm helm-${HELM_VERSION}-linux-amd64.tar.gz \
	&& mv ./linux-amd64/helm /usr/local/bin/helm \
	&& rm -Rf ./linux-amd64

# Add promtool (for verifying prometheus rules)
RUN curl -LO https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
  && tar xzf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
  && mv ./prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/promtool \
	&& chmod +x /usr/local/bin/promtool \
  && rm -Rf ./prometheus-${PROMETHEUS_VERSION}.linux-amd64

# Add leiningen (for Clojure development)
RUN curl -LO https://raw.githubusercontent.com/technomancy/leiningen/${LEIN_VERSION}/bin/lein \
  && mv ./lein /usr/local/bin/lein \
  && chmod a+x /usr/local/bin/lein \
  && lein version
