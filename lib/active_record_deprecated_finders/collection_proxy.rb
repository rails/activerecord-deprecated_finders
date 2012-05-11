module ActiveRecord
  module Associations
    class CollectionProxy
      alias method_missing_without_dynamic_instantiator method_missing
      remove_method :method_missing

      def method_missing(method, *args, &block)
        match = DynamicMatchers::Method.match(klass, method)

        if match && match.is_a?(DynamicMatchers::Instantiator)
          super do |record|
            proxy_association.add_to_target(record)
            yield record if block_given?
          end
        else
          method_missing_without_dynamic_instantiator(method, *args, &block)
        end
      end
    end
  end
end
