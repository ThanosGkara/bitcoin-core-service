job "bitcoin-core" {
  datacenters = ["dc1"]
  type        = "service"

  group "bitcoin-core" {
    count = 1

# https://www.nomadproject.io/docs/job-specification/volume
    volume "home-nonroot" {
      type      = "host"
      read_only = false
      source    = "general-volume"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "bitcoin-core" {
      driver = "docker"

# https://www.nomadproject.io/docs/job-specification/volume_mount
      volume_mount {
        volume      = "general-volume"
        destination = "/home/nonroot/"
        read_only   = false
      }

      env = {}

      config {
        image = "docker.io/thanosgkara/bitcoin-core-service:22.0"

        ports = ["rest-interface", "p2p-maninet", "p2p-testnet", "p2p-regnet", "rpc-maninet", "rpc-testnet", "rpc-regnet", "zmq-transactions", "zmq-blocks"]
      }

      resources {
        cpu    = 500
        memory = 2560
      }

# We need HashiCorp Consul for this part of the job
# https://www.nomadproject.io/docs/job-specification/service
      service {
        name = "bitcoin-core-rest-interface"
        port = "rest-interface"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
      service {
        name = "bitcoin-core-p2p-maninet"
        port = "p2p-maninet"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
      service {
        name = "bitcoin-core-p2p-testnet"
        port = "p2p-testnet"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
      service {
        name = "bitcoin-core-p2p-regnet"
        port = "p2p-regnet"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
      service {
        name = "bitcoin-core-rpc-maninet"
        port = "rpc-maninet"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
      service {
        name = "bitcoin-core-rpc-testnet"
        port = "rpc-testnet"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
      service {
        name = "bitcoin-core-rpc-regnet"
        port = "rpc-regnet"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
      service {
        name = "bitcoin-core-zmq-transactions"
        port = "zmq-transactions"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
      service {
        name = "bitcoin-core-zmq-blocks"
        port = "zmq-blocks"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    network {
      port "rest-interface" {
        static = 8080
      }
      port "p2p-maninet"{
        static = 8333
      }
      port "p2p-testnet"{
        static = 18333
      }
      port "p2p-regnet"{
        static = 18444
      }
      port "rpc-maninet"{
        static = 8332
      }
      port "rpc-testnet"{
        static = 18332
      }
      port "rpc-regnet"{
        static = 18443
      }
      port "zmq-transactions"{
        static = 28332
      }
      port "zmq-blocks"{
        static = 28333
      }
    }
  }
}
