FROM jenkinsci/jnlp-slave:2.62

ARG KUBECTL_VERSION=v1.5.2

USER root

RUN usermod -G users jenkins

RUN curl -LO https://dl.k8s.io/${KUBECTL_VERSION}/kubernetes-client-linux-amd64.tar.gz \
	&& tar xzf https://dl.k8s.io/${KUBECTL_VERSION}/kubernetes-client-linux-amd64.tar.gz \
	&& rm https://dl.k8s.io/${KUBECTL_VERSION}/kubernetes-client-linux-amd64.tar.gz \
	&& chmod +x ./kubernetes/client/binkubectl \
	&& mv ./kubernetes/client/bin/kubectl /usr/local/bin/kubectl \
	&& rm -Rf ./kubernetes

USER jenkins
