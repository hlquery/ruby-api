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
      raise ArgumentError, "Schema name must match collection name" if payload.key?("name") && payload["name"].to_s != name.to_s

      @request.execute("POST", "/collections", payload)
    end

    def delete(name)
      @request.execute("DELETE", "/collections/#{escape(name)}")
    end

    def update(name, schema)
      @request.execute("POST", "/collections/#{escape(name)}/update", schema || {})
    end

    def fields(name)
      response = get(name)
      return response unless response.success? && response.body.is_a?(Hash)

      body = response.body
      explicit_fields = Array(body["fields"]).map { |field| stringify_keys(field) }
      all = explicit_fields.map { |field| field["name"] }.compact
      field_types = {}

      {
        "searchable" => body["searchable_fields"],
        "filterable" => body["filterable_fields"],
        "sortable" => body["sortable_fields"]
      }.each do |type, fields|
        Array(fields).each do |field|
          all << field unless all.include?(field)
          field_types[field] ||= []
          field_types[field] << type
        end
      end

      fields = all.map do |field|
        explicit_fields.find { |item| item["name"] == field } || { "name" => field, "type" => Array(field_types[field]).join(", ") }
      end

      Hlquery::Response.new(200, {}, JSON.generate({
        collection: name,
        fields: fields,
        field_count: fields.length,
        searchable_fields: body["searchable_fields"] || [],
        filterable_fields: body["filterable_fields"] || [],
        sortable_fields: body["sortable_fields"] || []
      }))
    end

    alias get_fields fields

    def language(name)
      @request.execute("GET", "/collections/#{escape(name)}/lang")
    end

    alias get_language language

    private

    def escape(value)
      require "cgi"
      CGI.escape(value.to_s).gsub("+", "%20")
    end

    def stringify_keys(obj)
      return obj unless obj.is_a?(Hash)

      obj.each_with_object({}) do |(k, v), out|
        out[k.to_s] = v
      end
    end
  end
end
