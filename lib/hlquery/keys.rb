require "cgi"

module Hlquery
  class Keys
    def initialize(request)
      @request = request
    end

    def list
      @request.execute("GET", "/keys")
    end

    def get(id)
      validate_id(id)
      @request.execute("GET", "/keys/#{CGI.escape(id)}")
    end

    def create(params)
      params ||= {}
      collections = params[:collections] || params["collections"]
      actions = params[:actions] || params["actions"]
      raise ValidationException, "Collections array is required" unless collections.is_a?(Array) && !collections.empty?
      raise ValidationException, "Actions array is required" unless actions.is_a?(Array) && !actions.empty?

      @request.execute("POST", "/keys", params)
    end

    def update(id, params)
      validate_id(id)
      @request.execute("PUT", "/keys/#{CGI.escape(id)}", params || {})
    end

    def delete(id)
      validate_id(id)
      @request.execute("DELETE", "/keys/#{CGI.escape(id)}")
    end

    private

    def validate_id(id)
      raise ValidationException, "Key ID is required" unless id.is_a?(String) && !id.strip.empty?
    end
  end
end
