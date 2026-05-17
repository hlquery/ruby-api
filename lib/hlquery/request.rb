# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Hlquery
  class Request
    def initialize(base_url, timeout: 10, token: nil, auth_method: "bearer")
      @base_url = normalize_base_url(base_url)
      @timeout = timeout.to_i
      @token = token
      @auth_method = auth_method
    end

    def set_auth_token(token, method = "bearer")
      @token = token
      @auth_method = method
    end

    def clear_auth
      @token = nil
      @auth_method = "bearer"
    end

    def execute(method, path, body = nil, query = {})
      uri = build_uri(path, query || {})
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @timeout
      http.read_timeout = @timeout

      request = build_request(method, uri, body)
      response = http.request(request)

      headers = {}
      response.each_header { |k, v| headers[k] = v }
      Hlquery::Response.new(response.code.to_i, headers, response.body)
    end

    private

    def normalize_base_url(url)
      raise ArgumentError, "base_url is required" if url.nil? || url.strip == ""

      u = url.strip
      u = "http://#{u}" unless u.start_with?("http://", "https://")
      u.chomp("/")
    end

    def build_uri(path, query)
      path = "/#{path}" unless path.start_with?("/")
      uri = URI.parse("#{@base_url}#{path}")

      query_hash = normalize_query(query)
      uri.query = URI.encode_www_form(query_hash) unless query_hash.empty?
      uri
    end

    def normalize_query(query)
      out = {}
      query.each do |k, v|
        next if v.nil?

        key = k.to_s
        out[key] =
          if v.is_a?(Array)
            v.join(",")
          elsif v.is_a?(Hash)
            JSON.generate(v)
          else
            v
          end
      end
      out
    end

    def build_request(method, uri, body)
      klass =
        case method.to_s.upcase
        when "GET" then Net::HTTP::Get
        when "POST" then Net::HTTP::Post
        when "PUT" then Net::HTTP::Put
        when "PATCH" then Net::HTTP::Patch
        when "DELETE" then Net::HTTP::Delete
        else
          raise ArgumentError, "Unsupported HTTP method: #{method}"
        end

      request = klass.new(uri.request_uri)
      request["Accept"] = "application/json"

      apply_auth_headers(request)

      if body != nil && method.to_s.upcase != "GET"
        request["Content-Type"] = "application/json"
        request.body = body.is_a?(String) ? body : JSON.generate(body)
      end

      request
    end

    def apply_auth_headers(request)
      return if @token.nil? || @token.to_s.strip == ""

      method = (@auth_method || "bearer").to_s.downcase
      case method
      when "bearer"
        request["Authorization"] = "Bearer #{@token}"
      when "api-key", "api_key", "apikey"
        request["X-API-Key"] = @token.to_s
      else
        request["Authorization"] = "#{@auth_method} #{@token}"
      end
    end
  end
end

