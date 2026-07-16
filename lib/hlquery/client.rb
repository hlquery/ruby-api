# frozen_string_literal: true

module Hlquery
  class Client
    attr_reader :request

    def initialize(base_url = nil, options = {})
      opts = stringify_keys(options || {})
      base =
        base_url ||
        opts["base_url"] ||
        opts["baseUrl"] ||
        opts["url"] ||
        ENV["HLQ_BASE_URL"] ||
        ENV["HLQUERY_BASE_URL"] ||
        "http://localhost:9200"
      timeout = opts.fetch("timeout", 10)
      token = opts["token"]
      auth_method = opts.fetch("auth_method", opts.fetch("authMethod", "bearer"))
      headers = opts["headers"] || {}
      throw_on_error = opts["throw_on_error"] || opts["throwOnError"] || false

      @request = Hlquery::Request.new(base, timeout: timeout, token: token, auth_method: auth_method, headers: headers, throw_on_error: throw_on_error)
      @collections = Hlquery::Collections.new(@request)
      @documents = Hlquery::Documents.new(@request)
      @search = Hlquery::Search.new(@request, @collections)
      @system = Hlquery::System.new(@request)
      @keys = Hlquery::Keys.new(@request)
      @users = Hlquery::Users.new(@request)
      @modules = Hlquery::Modules.new(@request)
      @aliases = Hlquery::Aliases.new(@request)
      @overrides = Hlquery::Overrides.new(@request)
      @synonyms = Hlquery::Synonyms.new(@request)
      @stopwords = Hlquery::Stopwords.new(@request)
      @presets = Hlquery::Presets.new(@request)
    end

    def set_auth_token(token, method = "bearer")
      @request.set_auth_token(token, method)
      self
    end

    def clear_auth
      @request.clear_auth
      self
    end

    def execute_request(method, path, body = nil, query = {})
      @request.execute(method, path, body, query)
    end

    %i[
      health ready stats etc info status query startup boot_status metrics metrics_json
      connections rocksdb rocksdb_internal doc_total ping integrity consistency
      self_check storage_status search_config config_files cache metrics_history debug_counters
    ].each do |name|
      define_method(name) { @system.public_send(name) }
    end

    def update_counters(params = {}) = @system.update_counters(params)
    def repair(params = {}) = @system.repair(params)
    def update_counters_post(body = {}) = @system.update_counters_post(body)
    def repair_post(body = {}) = @system.repair_post(body)
    def sql(sql, params = {}) = @system.sql(sql, params)
    def exec_sql(sql) = @system.exec_sql(sql)
    alias execSql exec_sql

    def collections = @collections
    def documents = @documents
    def search_api = @search
    alias searchApi search_api
    def system = @system
    def keys = @keys
    def users = @users
    def modules = @modules
    def aliases = @aliases
    def overrides = @overrides
    def synonyms = @synonyms
    def stopwords = @stopwords
    def presets = @presets

    def list_collections(offset = 0, limit = 10) = @collections.list(offset, limit)
    def list_collections_distributed = @request.execute("GET", "/collections/distributed")
    def get_collection(name) = @collections.get(name)
    def get_collection_fields(name) = @collections.fields(name)
    alias getCollectionFields get_collection_fields
    def get_collection_language(name) = @collections.language(name)
    alias getCollectionLanguage get_collection_language
    def create_collection(name, schema) = @collections.create(name, schema)
    def delete_collection(name) = @collections.delete(name)
    def update_collection(name, schema) = @collections.update(name, schema)

    def list_documents(collection_name, params = {}) = @documents.list(collection_name, params)
    def get_document(collection_name, document_id) = @documents.get(collection_name, document_id)
    def add_document(collection_name, document) = @documents.add(collection_name, document)
    def update_document(collection_name, document_id, document) = @documents.update(collection_name, document_id, document)
    def delete_document(collection_name, document_id) = @documents.delete(collection_name, document_id)
    def import_documents(collection_name, documents) = @documents.import(collection_name, documents)
    def export_documents(collection_name, params = {}) = @documents.export(collection_name, params)
    def facet_counts(collection_name, params = {}) = @documents.facet_counts(collection_name, params)
    def maybe(collection_name, params = {}) = @documents.maybe(collection_name, params)
    def document_context(collection_name, document_id, params = {}) = @documents.context(collection_name, document_id, params)

    def search(collection_name, params = {}) = @search.search(collection_name, params)
    def sql_search(collection_name, sql, params = {}) = @search.sql(collection_name, sql, params)
    alias sqlSearch sql_search
    def vector_search(collection_name, params = {}) = @search.vector_search(collection_name, params)
    def global_search(params = {}) = @search.global_search(params)
    alias globalSearch global_search
    alias search_all global_search
    alias searchAll global_search
    def multi_search(searches) = @search.multi_search(searches)

    def cluster_health = health
    alias clusterHealth cluster_health
    def cluster_stats = stats
    alias clusterStats cluster_stats
    def cluster_nodes = links
    alias clusterNodes cluster_nodes
    def links = @request.execute("GET", "/links")
    def links_ping = @request.execute("GET", "/links/ping")
    def links_connect(endpoint_or_host, port = nil) = @request.execute("POST", "/links/connect", link_payload(endpoint_or_host, port))
    def links_disconnect(endpoint_or_host, port = nil) = @request.execute("POST", "/links/disconnect", link_payload(endpoint_or_host, port))
    def flush = @request.execute("POST", "/flush")

    def indices(params = {}) = list_collections(params[:offset] || params["offset"] || 0, params[:limit] || params["limit"] || 10)

    def get(params)
      index = params[:index] || params["index"]
      id = params[:id] || params["id"]
      return get_document(index, id) if index && !id.nil?
      return get_collection(index) if index

      raise ArgumentError, "Invalid parameters for get()"
    end

    def cat(type = "indices", params = {})
      return indices(params) if type.to_s == "indices"

      raise ArgumentError, "Unsupported cat type: #{type}"
    end

    private

    def link_payload(endpoint_or_host, port)
      port.nil? ? { endpoint: endpoint_or_host } : { host: endpoint_or_host, port: port }
    end

    def stringify_keys(obj)
      return obj unless obj.is_a?(Hash)

      obj.each_with_object({}) do |(k, v), out|
        out[k.to_s] = v
      end
    end
  end
end
