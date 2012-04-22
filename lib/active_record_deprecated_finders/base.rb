module ActiveRecord
  module DeprecatedDefaultScope
    class FinderHashScope
      def initialize(klass, hash)
        @klass = klass
        @hash  = hash
      end

      def call
        @klass.unscoped.apply_finder_options(@hash)
      end
    end

    def default_scope(scope = {})
      scope = FinderHashScope.new(self, scope) if scope.is_a?(Hash)
      super(scope)
    end
  end

  class Base
    extend DeprecatedDefaultScope
  end
end
