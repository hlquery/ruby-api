module Hlquery
  class Client
    attr_reader :request

    def initialize(base_url = nil, options = {})
      opts = Utils::Config.merge_defaults(options || {})
      base = Utils::Config.normalize_url(base_url || opts[:base_url])
      raise ValidationException, "Invalid base URL: #{base}" unless Utils::Config.valid_url?(base)

      @request = Request.new(base, opts[:timeout], opts[:token], opts[:auth_method])
      @collections_api = Collections.new(@request)
      @documents_api = Documents.new(@request)
      @search_api = Search.new(@request, @collections_api)
      @keys_api = Keys.new(@request)
      @aliases_api = Aliases.new(@request)
      @overrides_api = Overrides.new(@request)
      @synonyms_api = Synonyms.new(@request)
      @stopwords_api = Stopwords.new(@request)
      @system_api = System.new(@request)
    end

    def set_auth_token(token, method = "bearer")
      @request.set_auth_token(token, method)
      self
    end

    def clear_auth
      @request.clear_auth
      self
    end

    def execute_request(method, path, body = nil, query_params = {})
      @request.execute(method, path, body, query_params)
    end

    def collections
      @collections_api
    end

    def documents
      @documents_api
    end

    def search_api
      @search_api
    end

    def keys
      @keys_api
    end

    def aliases
      @aliases_api
    end

    def overrides
      @overrides_api
    end

    def synonyms
      @synonyms_api
    end

    def stopwords
      @stopwords_api
    end

    def health
      @system_api.health
    end

    def status
      @system_api.status
    end

    def startup
      @system_api.startup
    end

    def boot_status
      @system_api.boot_status
    end

    def info
      @system_api.info
    end

    def stats
      @system_api.stats
    end

    def metrics
      @system_api.metrics
    end

    def metrics_json
      @system_api.metrics_json
    end

    def connections
      @system_api.connections
    end

    def rocksdb
      @system_api.rocksdb
    end

    def rocksdb_internal
      @system_api.rocksdb_internal
    end

    def doc_total
      @system_api.doc_total
    end

    def etc
      @system_api.etc
    end

    def ping
      @system_api.ping
    end

    def flush
      @system_api.flush
    end

    def integrity
      @system_api.integrity
    end

    def consistency
      @system_api.consistency
    end

    def self_check
      @system_api.self_check
    end

    def storage_status
      @system_api.storage_status
    end

    def list_collections(offset = 0, limit = 10)
      @collections_api.list(offset, limit)
    end

    def get_collection(name)
      @collections_api.get(name)
    end

    def get_collection_fields(name)
      @collections_api.get_fields(name)
    end

    def list_documents(collection_name, params = {})
      @documents_api.list(collection_name, params)
    end

    def get_document(collection_name, document_id)
      @documents_api.get(collection_name, document_id)
    end

    def search(collection_name, params = {})
      @search_api.search(collection_name, params)
    end

    def vector_search(collection_name, params = {})
      @search_api.vector_search(collection_name, params)
    end

    alias setAuthToken set_auth_token
    alias clearAuth clear_auth
    alias executeRequest execute_request
    alias collectionsApi collections
    alias documentsApi documents
    alias listCollections list_collections
    alias getCollection get_collection
    alias getCollectionFields get_collection_fields
    alias listDocuments list_documents
    alias getDocument get_document
    alias vectorSearch vector_search
    alias bootStatus boot_status
    alias metricsJson metrics_json
    alias rocksdbInternal rocksdb_internal
    alias docTotal doc_total
    alias selfCheck self_check
    alias storageStatus storage_status
  end
end
