module ActiveRecord
  module Associations
    class CollectionProxy
      def method_missing(method, *args, &block)
        match = DynamicMatchers::Method.match(klass, method)

        if match && match.is_a?(DynamicMatchers::Instantiator)
          super do |record|
            proxy_association.add_to_target(record)
            yield record if block_given?
          end
        else
          super
        end
      end
    end
  end
end
