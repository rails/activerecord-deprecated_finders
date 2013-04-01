module ActiveRecord
  module Associations
    class CollectionProxy
      module InterceptDynamicInstantiators
        def method_missing(method, *args, &block)
          match = DynamicMatchers::Method.match(klass, method)
          sanitized_method = match.class.prefix + match.class.suffix if match

          if match && self.respond_to?(sanitized_method)
            self.send(sanitized_method, Hash[match.attribute_names.zip(args)])

          elsif match && match.is_a?(DynamicMatchers::Instantiator)
            scoping do
              klass.send(method, *args) do |record|
                proxy_association.add_to_target(record)
                yield record if block_given?
              end
            end
          else
            super
          end
        end
      end

      def self.inherited(subclass)
        subclass.class_eval do
          # Ensure this get included first
          include ActiveRecord::Delegation::ClassSpecificRelation

          # Now override the method_missing definition
          include InterceptDynamicInstantiators
        end
      end
    end
  end
end
