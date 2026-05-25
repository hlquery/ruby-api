# frozen_string_literal: true

require "cgi"
require "json"

module Hlquery
  module Helpers
    module_function

    def escape(value)
      CGI.escape(value.to_s).gsub("+", "%20")
    end

    def stringify_keys(obj)
      return obj unless obj.is_a?(Hash)

      obj.each_with_object({}) { |(k, v), out| out[k.to_s] = v }
    end

    def require_string(value, label)
      raise ArgumentError, "#{label} must be a non-empty string" if value.nil? || value.to_s.strip.empty?
    end
  end

  class System
    def initialize(request) = @request = request

    {
      health: "/health", ready: "/ready", status: "/status", query: "/query",
      startup: "/startup", boot_status: "/boot-status", info: "/", stats: "/stats",
      metrics: "/metrics", metrics_json: "/metrics.json", connections: "/connections",
      rocksdb: "/rocksdb", rocksdb_internal: "/_rocksdb", doc_total: "/doctotal",
      etc: "/etc", ping: "/ping", integrity: "/integrity", consistency: "/consistency",
      self_check: "/self-check", storage_status: "/admin/storage_status",
      search_config: "/search-config", llm: "/llm"
    }.each do |name, path|
      define_method(name) { @request.execute("GET", path) }
    end

    def update_counters(params = {}) = @request.execute("GET", "/update-counters", nil, params || {})
    def repair(params = {}) = @request.execute("GET", "/repair", nil, params || {})
    def update_counters_post(body = {}) = @request.execute("POST", "/update-counters", body || {})
    def repair_post(body = {}) = @request.execute("POST", "/repair", body || {})

    def sql(sql, params = {})
      Helpers.require_string(sql, "SQL query")
      @request.execute("GET", "/sql", nil, Helpers.stringify_keys(params || {}).merge("sql" => sql))
    end

    def exec_sql(sql)
      Helpers.require_string(sql, "SQL query")
      @request.execute("POST", "/sql", { exec: sql })
    end
  end

  class SAM
    def initialize(request) = @request = request

    def search(collection_name, query, params = {})
      Helpers.require_string(query, "SAM query")
      q = Helpers.stringify_keys(params || {}).merge("q" => query)
      if collection_name && collection_name.to_s != ""
        q["collection"] = collection_name
      elsif !q["all"] && !q["collections"]
        raise ArgumentError, "Collection name is required unless all=true or collections is provided"
      end
      @request.execute("GET", "/sam/search", nil, q)
    end

    def search_all(query, params = {}) = search(nil, query, Helpers.stringify_keys(params || {}).merge("all" => true))
    def rebuild(collection_name, params = {}) = @request.execute("POST", "/sam/rebuild", nil, Helpers.stringify_keys(params || {}).merge("collection" => collection_name))
    def status(collection_name = nil, params = {}) = scoped_get("/sam/status", collection_name, params)
    def debug(collection_name = nil, params = {}) = scoped_get("/sam/debug", collection_name, params)
    def history(collection_name = nil, limit = 100, params = {}) = scoped_get("/sam/history", collection_name, Helpers.stringify_keys(params || {}).merge("limit" => limit))

    def pause(pause_until_ms, params = {})
      pause = Integer(pause_until_ms)
      raise ArgumentError, "SAM pause value must be non-negative" if pause.negative?

      @request.execute("POST", "/sam/pause", nil, Helpers.stringify_keys(params || {}).merge("pause" => pause))
    end

    def clear_pause(params = {}) = pause(0, params)
    def improve(params = {}) = @request.execute("POST", "/sam/improve", params || {})
    def flush_actor_metadata(params = {}) = @request.execute("POST", "/sam/flush_actor_metadata", params || {})

    def add_label(collection_name, document_id, label, params = {})
      Helpers.require_string(label, "SAM label")
      @request.execute("POST", "/sam/label/add/#{Helpers.escape(collection_name)}/#{Helpers.escape(document_id)}/#{Helpers.escape(label)}", params || {})
    end

    def list_documents(collection_name, offset = 0, limit = 20, params = {})
      q = Helpers.stringify_keys(params || {}).merge("collection" => collection_name, "offset" => offset, "limit" => limit)
      @request.execute("GET", "/sam/documents", nil, q)
    end

    def get_document(collection_name, document_id, params = {})
      @request.execute("GET", "/sam/documents/#{Helpers.escape(collection_name)}/#{Helpers.escape(document_id)}", nil, params || {})
    end

    def open_document(collection_name, document_id, interaction_query = nil, params = {})
      q = Helpers.stringify_keys(params || {})
      q["interaction_query"] = interaction_query if interaction_query && interaction_query.to_s != ""
      get_document(collection_name, document_id, q)
    end

    private

    def scoped_get(path, collection_name, params)
      q = Helpers.stringify_keys(params || {})
      q["collection"] = collection_name if collection_name && collection_name.to_s != ""
      @request.execute("GET", path, nil, q)
    end
  end

  class Keys
    def initialize(request) = @request = request
    def list = @request.execute("GET", "/keys")
    def get(id) = @request.execute("GET", "/keys/#{Helpers.escape(id)}")
    def create(params) = @request.execute("POST", "/keys", params || {})
    def update(id, params) = @request.execute("PUT", "/keys/#{Helpers.escape(id)}", params || {})
    def delete(id) = @request.execute("DELETE", "/keys/#{Helpers.escape(id)}")
  end

  class Users
    def initialize(request) = @request = request
    def list = @request.execute("GET", "/users")
    def get(id) = @request.execute("GET", "/users/#{Helpers.escape(id)}")
    def create(params) = @request.execute("POST", "/users", params || {})
    def update(id, params) = @request.execute("PUT", "/users/#{Helpers.escape(id)}", params || {})
    def delete(id) = @request.execute("DELETE", "/users/#{Helpers.escape(id)}")
  end

  class Modules
    def initialize(request) = @request = request
    def list = @request.execute("GET", "/modules")
    def syntax(name) = @request.execute("GET", "/modules/#{Helpers.escape(name)}/syntax")

    def call(name, route = "", method = "GET", body = nil, params = {})
      suffix = route.to_s.sub(%r{\A/+}, "")
      path = "/modules/#{Helpers.escape(name)}"
      path = "#{path}/#{suffix}" unless suffix.empty?
      @request.execute(method, path, body, params || {})
    end
  end

  class Aliases
    def initialize(request) = @request = request
    def list = @request.execute("GET", "/aliases")
    def get(name) = @request.execute("GET", "/aliases/#{Helpers.escape(name)}")
    def create(name, params) = @request.execute("POST", "/aliases/#{Helpers.escape(name)}", params || {})
    def update(name, params) = @request.execute("PUT", "/aliases/#{Helpers.escape(name)}", params || {})
    def upsert(name, params) = create(name, params)
    def delete(name) = @request.execute("DELETE", "/aliases/#{Helpers.escape(name)}")
  end

  class CollectionResource
    def initialize(request, route)
      @request = request
      @route = route
    end

    def list(collection_name) = @request.execute("GET", path(collection_name))
    def get(collection_name, id) = @request.execute("GET", path(collection_name, id))
    def create(collection_name, id, payload) = @request.execute("POST", path(collection_name, id), payload || {})
    def update(collection_name, id, payload) = @request.execute("PUT", path(collection_name, id), payload || {})
    def upsert(collection_name, id, payload) = create(collection_name, id, payload)
    def delete(collection_name, id) = @request.execute("DELETE", path(collection_name, id))

    private

    def path(collection_name, id = nil)
      base = "/collections/#{Helpers.escape(collection_name)}/#{@route}"
      id.nil? ? base : "#{base}/#{Helpers.escape(id)}"
    end
  end

  class Overrides < CollectionResource
    def initialize(request) = super(request, "overrides")
  end

  class Synonyms < CollectionResource
    def initialize(request) = super(request, "synonyms")
    def list_all = @request.execute("GET", "/synonyms")
    def list_global = @request.execute("GET", "/synonyms/global")
    def get_global(id) = @request.execute("GET", "/synonyms/global/#{Helpers.escape(id)}")
    def create_global(id, synonym) = @request.execute("POST", "/synonyms/global/#{Helpers.escape(id)}", synonym || {})
    def update_global(id, synonym) = @request.execute("PUT", "/synonyms/global/#{Helpers.escape(id)}", synonym || {})
    def upsert_global(id, synonym) = create_global(id, synonym)
    def delete_global(id) = @request.execute("DELETE", "/synonyms/global/#{Helpers.escape(id)}")
  end

  class Stopwords
    def initialize(request) = @request = request
    def list(collection_name) = @request.execute("GET", "/collections/#{Helpers.escape(collection_name)}/stopwords")
    def create(collection_name, params) = @request.execute("POST", "/collections/#{Helpers.escape(collection_name)}/stopwords", params || {})
    def delete(collection_name, word) = @request.execute("DELETE", "/collections/#{Helpers.escape(collection_name)}/stopwords/#{Helpers.escape(word)}")
    def list_all = @request.execute("GET", "/stopwords")
    def list_global = @request.execute("GET", "/stopwords/global")
    def create_global(params) = @request.execute("POST", "/stopwords/global", params || {})
    def delete_global(word) = @request.execute("DELETE", "/stopwords/global/#{Helpers.escape(word)}")
  end
end
