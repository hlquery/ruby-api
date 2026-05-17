# frozen_string_literal: true

module Hlquery
  class Collections
    def initialize(request)
      @request = request
    end

    def list(offset = 0, limit = 10)
      @request.execute("GET", "/collections", nil, { offset: offset, limit: limit })
    end

    def get(name)
      @request.execute("GET", "/collections/#{escape(name)}")
    end

    def create(name, schema)
      payload = { name: name }.merge(stringify_keys(schema || {}))
      @request.execute("POST", "/collections", payload)
    end

    def delete(name)
      @request.execute("DELETE", "/collections/#{escape(name)}")
    end

    private

    def escape(value)
      require "cgi"
      CGI.escape(value.to_s)
    end

    def stringify_keys(obj)
      return obj unless obj.is_a?(Hash)

      obj.each_with_object({}) do |(k, v), out|
        out[k.to_s] = v
      end
    end
  end
end

