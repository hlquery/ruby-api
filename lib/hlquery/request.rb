require "json"
require "net/http"
require "openssl"
require "timeout"
require "uri"

module Hlquery
  class Request
    def initialize(base_url, timeout = 30, auth_token = nil, auth_method = "bearer")
      @base_url = base_url.to_s.sub(%r{/+\z}, "")
      @timeout = [timeout.to_i, 1].max
      @auth_token = auth_token
      @auth_method = normalize_auth_method(auth_method)
    end

    def set_auth_token(token, method = "bearer")
      if !token.nil? && (!token.is_a?(String) || token.strip.empty?)
        raise ValidationException, "Authentication token must be a non-empty string"
      end

      @auth_token = token
      @auth_method = normalize_auth_method(method)
    end

    def clear_auth
      @auth_token = nil
      @auth_method = "bearer"
    end

    def execute(method, path, body = nil, query_params = {})
      http_method = normalize_method(method)
      normalized_path = normalize_path(path)
      uri = URI.parse(@base_url + normalized_path)
      query = build_query_string(query_params)
      uri.query = query unless query.empty?

      request_class = case http_method
                      when "GET" then Net::HTTP::Get
                      when "POST" then Net::HTTP::Post
                      when "PUT" then Net::HTTP::Put
                      when "DELETE" then Net::HTTP::Delete
                      when "PATCH" then Net::HTTP::Patch
                      else
                        raise ValidationException, "Unsupported HTTP method: #{http_method}"
                      end

      request = request_class.new(uri)
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"

      if @auth_token
        if @auth_method == "api-key"
          request["X-API-Key"] = @auth_token
        else
          request["Authorization"] = "Bearer #{@auth_token}"
        end
      end

      if !body.nil?
        payload = body.is_a?(String) ? body : JSON.generate(body)
        request.body = payload
      end

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = [@timeout, 10].min
      http.read_timeout = @timeout
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?

      raw_response = http.request(request)
      raw_body = raw_response.body.to_s
      parsed_body = decode_body(raw_body, raw_response["Content-Type"])

      Response.new(
        raw_response.code.to_i,
        parsed_body,
        stringify_headers(raw_response.each_header.to_h),
        raw_body
      )
    rescue JSON::GeneratorError => e
      raise RequestException, "Failed to encode request body: #{e.message}"
    rescue IOError, SystemCallError, SocketError, OpenSSL::SSL::SSLError, Net::OpenTimeout, Net::ReadTimeout, Timeout::Error => e
      Response.new(0, nil, {}, "", e.message)
    end

    private

    def normalize_method(method)
      unless method.is_a?(String) && !method.strip.empty?
        raise ValidationException, "HTTP method must be a non-empty string"
      end

      method.strip.upcase
    end

    def normalize_path(path)
      unless path.is_a?(String) && !path.empty?
        raise ValidationException, "Request path must be a non-empty string"
      end

      raise ValidationException, "Request path must start with /" unless path.start_with?("/")

      path
    end

    def normalize_auth_method(method)
      normalized = method.to_s.strip.downcase
      return "bearer" if normalized.empty? || normalized == "bearer"
      return "api-key" if normalized == "api-key"

      raise ValidationException, "Authentication method must be bearer or api-key"
    end

    def build_query_string(query_params)
      return "" unless query_params.is_a?(Hash) && !query_params.empty?

      normalized = query_params.each_with_object({}) do |(key, value), memo|
        next if value.nil?

        memo[key] =
          case value
          when TrueClass then "true"
          when FalseClass then "false"
          when Array, Hash then JSON.generate(value)
          else value.to_s
          end
      end

      URI.encode_www_form(normalized)
    end

    def decode_body(raw_body, content_type)
      return nil if raw_body.nil? || raw_body.empty?

      looks_like_json = raw_body.start_with?("{", "[")
      if (content_type && content_type.downcase.include?("application/json")) || looks_like_json
        JSON.parse(raw_body)
      else
        raw_body
      end
    rescue JSON::ParserError
      raw_body
    end

    def stringify_headers(headers)
      headers.each_with_object({}) do |(key, value), memo|
        memo[key.to_s.downcase] = value
      end
    end
  end
end
