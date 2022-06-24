# bitcoin-core-service
This is demo repo of running bitcon-core as a service 

## Docker image links
https://github.com/kylemanna/docker-bitcoind/blob/master/Dockerfile
https://github.com/lncm/docker-bitcoind/blob/master/23.0/Dockerfile
https://github.com/FelixWeis/docker-bitcoind/blob/master/0.15/Dockerfile
https://github.com/anchore

### Scanners

 curl -s https://ci-tools.anchore.io/inline_scan-v0.10.2 | bash -s -- -p docker.io/thanosgkara/bitcoin-core-service:22.0

 /tmp/grype docker.io/thanosgkara/bitcoin-core-service:22.0

 # kind
 https://github.com/kubernetes-sigs/kind/blob/main/site/content/docs/user/kind-example-config.yaml