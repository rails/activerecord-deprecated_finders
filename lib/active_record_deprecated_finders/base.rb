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

    class CallableScope
      def initialize(klass, callable)
        @klass    = klass
        @callable = callable
      end

      def call(*args)
        result = @callable.call(*args)

        if result.is_a?(Hash)
          @klass.unscoped.apply_finder_options(result)
        else
          result
        end
      end
    end

    def default_scope(scope = {})
      scope = FinderHashScope.new(self, scope) if scope.is_a?(Hash)
      super
    end

    def scoped(options = nil)
      if options && (options.keys & [:conditions, :include, :extend]).any?
        super().apply_finder_options(options)
      else
        super
      end
    end

    def scope(name, body = {}, &block)
      if body.is_a?(Hash)
        body = FinderHashScope.new(self, body)
      elsif !body.is_a?(Relation) && body.respond_to?(:call)
        body = CallableScope.new(self, body)
      end

      super
    end
  end

  class Base
    extend DeprecatedFinders
  end
end
