FROM jenkins/jnlp-slave:3.29-1

ARG KUBECTL_VERSION=v1.17.3
ARG HELM_VERSION=v3.3.4
ARG PROMETHEUS_VERSION=2.3.2
ARG LEIN_VERSION=2.8.1
ARG PYTHON_3_8_DIR_VERSION=3.8.0
ARG PYTHON_3_8_TAR_VERSION=3.8.0b3

USER root
RUN rm -rf /var/lib/apt/lists/* && apt update
RUN apt-get update && apt-get install -y make && apt-get install -y build-essential g++ python-pip python3-pip jq libyaml-dev libpython2.7-dev libpython-dev python-virtualenv python3 python3 python3-venv libpython3-dev python3-nose mysql-client flake8
RUN pip install awscli

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
	&& chmod +x ./kubectl \
	&& mv ./kubectl /usr/local/bin/kubectl

RUN curl -LO https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
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

# Add other Python versions next to the default python 3.5
# https://unix.stackexchange.com/a/332658
# Install build dependencies
RUN apt-get update && apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev


# Python 3.8
RUN wget https://www.python.org/ftp/python/${PYTHON_3_8_DIR_VERSION}/Python-${PYTHON_3_8_TAR_VERSION}.tgz \
  && tar xvf Python-${PYTHON_3_8_TAR_VERSION}.tgz \
  && cd Python-${PYTHON_3_8_TAR_VERSION} \
  # && ./configure --enable-optimizations --enable-shared --with-ensurepip=install \
  && ./configure --enable-shared --with-ensurepip=install \
  && make -j8 \
  && make altinstall \
  && ldconfig \
  && cd .. \
  && rm -rf Python-${PYTHON_3_8_TAR_VERSION}

# Set default Python to Python 3.8
RUN update-alternatives && update-alternatives --install /usr/bin/python3 python3 `which python3.8` 50 \
  && update-alternatives --display python3

# Explicit whichlist for debugging
RUN which python \
  && which python3 \
  && which python3.8
