module Hlquery
  module Utils
    module Validator
      module_function

      def validate_collection_name(name)
        require_non_empty_string(name, "Collection name")

        if name.length > 64
          raise ValidationException, "Collection name must be between 1 and 64 characters"
        end

        if name.match?(/[^a-zA-Z0-9_-]/)
          raise ValidationException, "Collection name contains invalid characters. Use only letters, numbers, underscores, and hyphens"
        end

        first = name[0]
        return if first.match?(/[A-Za-z_]/)

        raise ValidationException, "Collection name must start with a letter or underscore"
      end

      def validate_document_id(id)
        require_non_empty_string(id, "Document ID")

        if id.length > 256
          raise ValidationException, "Document ID must be between 1 and 256 characters"
        end

        if id.match?(/[^a-zA-Z0-9_.-]/)
          raise ValidationException, "Document ID contains invalid characters. Use only letters, numbers, underscores, hyphens, and dots"
        end
      end

      def validate_alias_name(name)
        require_non_empty_string(name, "Alias name")

        if name.length > 64
          raise ValidationException, "Alias name must be between 1 and 64 characters"
        end

        if name.match?(/[^a-zA-Z0-9_.-]/)
          raise ValidationException, "Alias name contains invalid characters. Use only letters, numbers, underscores, hyphens, and dots"
        end

        first = name[0]
        return if first.match?(/[A-Za-z_]/)

        raise ValidationException, "Alias name must start with a letter or underscore"
      end

      def validate_pagination(offset, limit)
        raise ValidationException, "Offset must be a non-negative integer" unless offset.is_a?(Integer) && offset >= 0
        raise ValidationException, "Limit must be a positive integer" unless limit.is_a?(Integer) && limit >= 1
        raise ValidationException, "Limit cannot exceed 1000" if limit > 1000
      end

      def validate_search_params(params)
        raise ValidationException, "Search params must be a hash" unless params.is_a?(Hash)

        validate_int(params[:limit] || params["limit"], "Limit", min: 1) if params.key?(:limit) || params.key?("limit")
        validate_int(params[:offset] || params["offset"], "Offset", min: 0) if params.key?(:offset) || params.key?("offset")
        validate_int(params[:page] || params["page"], "Page", min: 1) if params.key?(:page) || params.key?("page")
      end

      def validate_document_fields(document)
        return if document.nil?
        return unless document.is_a?(Hash)

        document.each do |key, value|
          next if key.to_s == "id"

          if value.is_a?(String) && value.include?(",")
            next if key.to_s == "embedding" || key.to_s.end_with?("_vector")

            raise ValidationException,
                  "Field '#{key}' contains invalid character: comma (`,`). Commas are not allowed in field values. Use underscores (_) or spaces instead, or use arrays for multiple values."
          end

          next unless value.is_a?(Array)

          value.each do |item|
            next unless item.is_a?(String) && item.include?(",")

            raise ValidationException,
                  "Field '#{key}' contains invalid character: comma (`,`). Array items cannot contain commas. Use underscores (_) or spaces instead."
          end
        end
      end

      def require_non_empty_string(value, field_name)
        unless value.is_a?(String) && !value.strip.empty?
          raise ValidationException, "#{field_name} must be a non-empty string"
        end
      end

      def validate_int(value, field_name, min:)
        unless value.is_a?(Integer) && value >= min
          raise ValidationException, "#{field_name} must be a #{min.zero? ? 'non-negative' : 'positive'} integer"
        end
      end
    end
  end
end
