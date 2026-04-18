module Hlquery
  class HlqueryException < StandardError; end
  class AuthenticationException < HlqueryException; end
  class RequestException < HlqueryException; end
  class ValidationException < HlqueryException; end
  class CollectionException < HlqueryException; end
  class DocumentException < HlqueryException; end
  class SearchException < HlqueryException; end
end
