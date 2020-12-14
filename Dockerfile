FROM jenkins/jnlp-slave:3.40-1-jdk11

ARG KUBECTL_VERSION=v1.17.3
ARG HELM_VERSION=v2.14.1
ARG PROMETHEUS_VERSION=2.3.2
ARG LEIN_VERSION=2.8.1
ARG PYTHON_3_6_VERSION=3.6.9
ARG PYTHON_3_7_VERSION=3.7.4
ARG PYTHON_3_8_DIR_VERSION=3.8.0
ARG PYTHON_3_8_TAR_VERSION=3.8.0b3

USER root

RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-2.32-r0.apk && \
wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-bin-2.32-r0.apk && \
wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-i18n-2.32-r0.apk && \
apk add glibc-bin-2.32-r0.apk glibc-i18n-2.32-r0.apk glibc-2.32-r0.apk

RUN echo "deb http://cdn-aws.deb.debian.org/debian stable main\ndeb http://cdn-aws.deb.debian.org/debian-security stable/updates main" > /etc/apt/sources.list.d/debian-aws.list
RUN rm -rf /var/lib/apt/lists/* && apt update
RUN apt-get update && apt-get install -y make && apt-get install -y build-essential g++ python-pip python3-pip jq libyaml-dev libpython2.7-dev libpython-dev python-virtualenv python3 python3 python3-venv libpython3-dev python3-nose mysql-client flake8
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

# Add other Python versions next to the default python 3.5
# https://unix.stackexchange.com/a/332658
# Install build dependencies
RUN apt-get update && apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev

# Python 3.6
RUN wget https://www.python.org/ftp/python/${PYTHON_3_6_VERSION}/Python-${PYTHON_3_6_VERSION}.tgz \
  && tar xvf Python-${PYTHON_3_6_VERSION}.tgz \
  && cd Python-${PYTHON_3_6_VERSION} \
  && ./configure --enable-optimizations --enable-shared --with-ensurepip=install \
  && make -j8 \
  && make altinstall \
  && ldconfig \
  && cd .. \
  && rm -rf Python-${PYTHON_3_6_VERSION}

# Python 3.7
RUN wget https://www.python.org/ftp/python/${PYTHON_3_7_VERSION}/Python-${PYTHON_3_7_VERSION}.tgz \
  && tar xvf Python-${PYTHON_3_7_VERSION}.tgz \
  && cd Python-${PYTHON_3_7_VERSION} \
  # && ./configure --enable-optimizations --enable-shared --with-ensurepip=install \
  && ./configure --enable-shared --with-ensurepip=install \
  && make -j8 \
  && make altinstall \
  && ldconfig \
  && cd .. \
  && rm -rf Python-${PYTHON_3_7_VERSION}

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

# Set default Python to Python 3.5
RUN update-alternatives --install /usr/bin/python3 python3 `which python3.5` 80 \
  && update-alternatives --install /usr/bin/python3 python3 `which python3.6` 70 \
  && update-alternatives --install /usr/bin/python3 python3 `which python3.7` 60 \
  && update-alternatives --install /usr/bin/python3 python3 `which python3.8` 50 \
  && update-alternatives --display python3

# Explicit whichlist for debugging
RUN which python \
  && which python3 \
  && which python3.5 \
  && which python3.6 \
  && which python3.7 \
  && which python3.8
