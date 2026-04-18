module Hlquery
  class System
    def initialize(request)
      @request = request
    end

    def health
      @request.execute("GET", "/health")
    end

    def status
      @request.execute("GET", "/status")
    end

    def startup
      @request.execute("GET", "/startup")
    end

    def boot_status
      @request.execute("GET", "/boot-status")
    end

    def info
      @request.execute("GET", "/")
    end

    def stats
      @request.execute("GET", "/stats")
    end

    def metrics
      @request.execute("GET", "/metrics")
    end

    def metrics_json
      @request.execute("GET", "/metrics.json")
    end

    def connections
      @request.execute("GET", "/connections")
    end

    def rocksdb
      @request.execute("GET", "/rocksdb")
    end

    def rocksdb_internal
      @request.execute("GET", "/_rocksdb")
    end

    def doc_total
      @request.execute("GET", "/doctotal")
    end

    def etc
      @request.execute("GET", "/etc")
    end

    def ping
      @request.execute("GET", "/ping")
    end

    def flush
      @request.execute("POST", "/flush")
    end

    def integrity
      @request.execute("GET", "/integrity")
    end

    def consistency
      @request.execute("GET", "/consistency")
    end

    def self_check
      @request.execute("GET", "/self-check")
    end

    def storage_status
      @request.execute("GET", "/admin/storage_status")
    end

    alias bootStatus boot_status
    alias metricsJson metrics_json
    alias rocksdbInternal rocksdb_internal
    alias docTotal doc_total
    alias selfCheck self_check
    alias storageStatus storage_status
  end
end
