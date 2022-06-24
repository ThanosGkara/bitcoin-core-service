NAME = bitcoin-core-service
DOCKER_IMAGE_NAME = docker.io/thanosgkara/${NAME}
VERSION = 22.0
DOCKER_IMAGE=${DOCKER_IMAGE_NAME}:${VERSION}

help:
	@echo "Please use 'make <target>' where <target> is one of the following:"
	@echo "  build-image         to build the app container image."
	@echo "  run-image           to run the app container."
	@echo "  image-scan  		 to run the Anchore container image security test."
	@echo "  deploy-to-kind      to create a new Kind cluster."
	@echo "  kind-delete         to delete the Kind cluster."
	@echo "  script-kiddies		 script to count ip frequency in a log file"
	@echo "  script-grownups	 python script to count ip frequency in a log file"

build-image:
	docker build -t ${DOCKER_IMAGE} .


run-image:
	docker run --rm --name bitcoin-core -it ${DOCKER_IMAGE}


image-scan:
	curl -s https://ci-tools.anchore.io/inline_scan-latest | bash -s -- -r ${DOCKER_IMAGE}


deploy-to-kind:
	kind create cluster --name bitcoin-k8s-cluster --image docker.io/kindest/node:v1.24.2 --config=kind-resources/kind-cluster-config.yaml
	kubectl cluster-info --context kind-bitcoin-k8s-cluster
	kubectl apply -f kubernetes-resources/

kind-delete:
	kind delete cluster --name bitcoin-k8s-cluster


script-kiddies:
	cd webserver-log && ./ip-frequency.sh sample-web-log.log


script-grownups:
	cd webserver-log && python3 ip-freq.py sample-web-log.log


revert-all:
	-kind delete cluster --name bitcoin-k8s-cluster
	-docker rm $(shell docker stop $(shell docker ps -a -q --filter ancestor=${DOCKER_IMAGE} --format="{{.ID}}"))
	-docker rmi $(shell docker images '${DOCKER_IMAGE}' -a -q)
	-docker rm $(shell docker stop $(shell docker ps -a -q --filter ancestor=anchore/inline-scan --format="{{.ID}}"))
	-docker rm $(shell docker stop $(shell docker ps -a -q --filter ancestor=anchore/anchore-engine --format="{{.ID}}"))
	-docker rmi $(shell docker images 'anchore/inline-scan' -a -q)
	-docker rmi $(shell docker images 'anchore/anchore-engine' -a -q)


.PHONY: \
	build-image \
    run-image \
    image-scan \
    deploy-to-kind \
    kind-delete \
    script-kiddies \
    script-grownups \
    revert-all