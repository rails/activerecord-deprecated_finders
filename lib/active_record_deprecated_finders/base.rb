module ActiveRecord
  module DeprecatedFinders
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

    def scoped(options = nil)
      if options && (options.keys & [:conditions, :include, :extend]).any?
        super().apply_finder_options(options)
      else
        super
      end
    end
  end

  class Base
    extend DeprecatedFinders
  end
end
