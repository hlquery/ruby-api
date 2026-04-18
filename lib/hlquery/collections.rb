require "cgi"

module Hlquery
  class Collections
    def initialize(request)
      @request = request
    end

    def list(offset = 0, limit = 10)
      Utils::Validator.validate_pagination(offset.to_i, limit.to_i)
      @request.execute("GET", "/collections", nil, { offset: offset.to_i, limit: limit.to_i })
    end

    def get(name)
      Utils::Validator.validate_collection_name(name)
      @request.execute("GET", "/collections/#{CGI.escape(name)}")
    end

    def create(name, schema)
      Utils::Validator.validate_collection_name(name)
      payload = (schema || {}).dup
      payload["name"] = name
      @request.execute("POST", "/collections", payload)
    end

    def delete(name)
      Utils::Validator.validate_collection_name(name)
      @request.execute("DELETE", "/collections/#{CGI.escape(name)}")
    end

    def update(name, schema)
      Utils::Validator.validate_collection_name(name)
      @request.execute("POST", "/collections/#{CGI.escape(name)}/update", schema || {})
    end

    def get_fields(name)
      response = get(name)
      return response unless response.status_code == 200 && response.body.is_a?(Hash)

      body = response.body
      all_fields = []
      field_types = {}

      {
        "searchable_fields" => "searchable",
        "filterable_fields" => "filterable",
        "sortable_fields" => "sortable"
      }.each do |key, label|
        Array(body[key]).each do |field|
          all_fields << field unless all_fields.include?(field)
          field_types[field] ||= []
          field_types[field] << label
        end
      end

      fields = all_fields.map do |field|
        { "name" => field, "type" => field_types[field].join(", ") }
      end

      Response.new(
        200,
        {
          "collection" => name,
          "fields" => fields,
          "field_count" => fields.length,
          "searchable_fields" => body["searchable_fields"] || [],
          "filterable_fields" => body["filterable_fields"] || [],
          "sortable_fields" => body["sortable_fields"] || []
        }
      )
    end

    alias getFields get_fields
  end
end
