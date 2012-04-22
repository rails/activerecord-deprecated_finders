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

    def with_scope(scope = {}, action = :merge)
      # If another Active Record class has been passed in, get its current scope
      scope = scope.current_scope if !scope.is_a?(Relation) && scope.respond_to?(:current_scope)

      previous_scope = self.current_scope

      if scope.is_a?(Hash)
        # Dup first and second level of hash (method and params).
        scope = scope.dup
        scope.each do |method, params|
          scope[method] = params.dup unless params == true
        end

        scope.assert_valid_keys([ :find, :create ])
        relation = construct_finder_arel(scope[:find] || {})
        relation.default_scoped = true unless action == :overwrite

        if previous_scope && previous_scope.create_with_value && scope[:create]
          scope_for_create = if action == :merge
            previous_scope.create_with_value.merge(scope[:create])
          else
            scope[:create]
          end

          relation = relation.create_with(scope_for_create)
        else
          scope_for_create = scope[:create]
          scope_for_create ||= previous_scope.create_with_value if previous_scope
          relation = relation.create_with(scope_for_create) if scope_for_create
        end

        scope = relation
      end

      scope = previous_scope.merge(scope) if previous_scope && action == :merge
      scope.scoping { yield }
    end

    protected

    # Works like with_scope, but discards any nested properties.
    def with_exclusive_scope(method_scoping = {}, &block)
      if method_scoping.values.any? { |e| e.is_a?(ActiveRecord::Relation) }
        raise ArgumentError, <<-MSG
New finder API can not be used with_exclusive_scope. You can either call unscoped to get an anonymous scope not bound to the default_scope:

User.unscoped.where(:active => true)

Or call unscoped with a block:

User.unscoped do
User.where(:active => true).all
end

MSG
      end
      with_scope(method_scoping, :overwrite, &block)
    end

    private

    def construct_finder_arel(options = {}, scope = nil)
      relation = options.is_a?(Hash) ? unscoped.apply_finder_options(options) : options
      relation = scope.merge(relation) if scope
      relation
    end
  end

  class Base
    extend DeprecatedFinders
  end
end
