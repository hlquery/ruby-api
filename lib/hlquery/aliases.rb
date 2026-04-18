require "cgi"

module Hlquery
  class Aliases
    def initialize(request)
      @request = request
    end

    def list
      @request.execute("GET", "/aliases")
    end

    def get(name)
      Utils::Validator.validate_alias_name(name)
      @request.execute("GET", "/aliases/#{CGI.escape(name)}")
    end

    def create(name, params)
      Utils::Validator.validate_alias_name(name)
      @request.execute("POST", "/aliases/#{CGI.escape(name)}", params || {})
    end

    def update(name, params)
      Utils::Validator.validate_alias_name(name)
      @request.execute("PUT", "/aliases/#{CGI.escape(name)}", params || {})
    end

    def upsert(name, params)
      create(name, params)
    end

    def delete(name)
      Utils::Validator.validate_alias_name(name)
      @request.execute("DELETE", "/aliases/#{CGI.escape(name)}")
    end
  end
end
