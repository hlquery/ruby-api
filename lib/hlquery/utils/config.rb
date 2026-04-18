require "uri"

module Hlquery
  module Utils
    module Config
      DEFAULT_TIMEOUT = 30
      DEFAULT_BASE_URL = "http://localhost:9200".freeze
      DEFAULT_AUTH_METHOD = "bearer".freeze

      module_function

      def merge_defaults(user_options = {})
        {
          timeout: DEFAULT_TIMEOUT,
          base_url: DEFAULT_BASE_URL,
          auth_method: DEFAULT_AUTH_METHOD,
          token: nil
        }.merge(symbolize_keys(user_options || {}))
      end

      def valid_url?(url)
        uri = URI.parse(url)
        uri.is_a?(URI::HTTP) && !uri.host.nil?
      rescue URI::InvalidURIError
        false
      end

      def normalize_url(url)
        url.to_s.sub(%r{/+\z}, "")
      end

      def symbolize_keys(hash)
        hash.each_with_object({}) do |(key, value), memo|
          memo[key.respond_to?(:to_sym) ? key.to_sym : key] = value
        end
      end
    end
  end
end
