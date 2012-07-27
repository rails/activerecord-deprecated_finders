require 'active_record/relation'
require 'active_support/core_ext/module/aliasing'

module ActiveRecord
  class Relation
    module DeprecatedMethods
      VALID_FIND_OPTIONS = [ :conditions, :include, :joins, :limit, :offset, :extend,
                             :order, :select, :readonly, :group, :having, :from, :lock ]

      # The silence_deprecation arg is for internal use, where we have already output a
      # deprecation further up the call stack.
      def apply_finder_options(options, silence_deprecation = false)
        ActiveSupport::Deprecation.warn("#apply_finder_options is deprecated") unless silence_deprecation

        relation = clone
        return relation unless options

        options.assert_valid_keys(VALID_FIND_OPTIONS)
        finders = options.dup
        finders.delete_if { |key, value| value.nil? && key != :limit }

        ((VALID_FIND_OPTIONS - [:conditions, :include, :extend]) & finders.keys).each do |finder|
          relation = relation.send(finder, finders[finder])
        end

        relation = relation.where(finders[:conditions]) if options.has_key?(:conditions)
        relation = relation.includes(finders[:include]) if options.has_key?(:include)
        relation = relation.extending(finders[:extend]) if options.has_key?(:extend)

        relation
      end

      def update_all_with_deprecated_options(updates, conditions = nil, options = {})
        scope = self

        if conditions
          scope = where(conditions)

          ActiveSupport::Deprecation.warn(
            "Relation#update_all with conditions is deprecated. Please use " \
            "Item.where(color: 'red').update_all(...) rather than " \
            "Item.update_all(..., color: 'red')."
          )
        end

        if options.present?
          scope = scope.apply_finder_options(options.slice(:limit, :order), true)

          ActiveSupport::Deprecation.warn(
            "Relation#update_all with :limit / :order options is deprecated. " \
            "Please use e.g. Post.limit(1).order(:foo).update_all instead."
          )
        end

        scope.update_all_without_deprecated_options(updates)
      end

      def find_in_batches(options = {}, &block)
        if (finder_options = options.except(:start, :batch_size)).present?
          ActiveSupport::Deprecation.warn(
            "Relation#find_in_batches with finder options is deprecated. Please build " \
            "a scope and then call find_in_batches on it instead."
          )

          raise "You can't specify an order, it's forced to be #{batch_order}" if options[:order].present?
          raise "You can't specify a limit, it's forced to be the batch_size"  if options[:limit].present?

          apply_finder_options(finder_options, true).
            find_in_batches(options.slice(:start, :batch_size), &block)
        else
          super
        end
      end

      def calculate(operation, column_name, options = {})
        if options.except(:distinct).present?
          ActiveSupport::Deprecation.warn(
            "Relation#calculate with finder options is deprecated. Please build " \
            "a scope and then call find_in_batches on it instead."
          )

          apply_finder_options(options.except(:distinct), true)
            .calculate(operation, column_name, :distinct => options[:distinct])
        else
          super
        end
      end

      def find(*args)
        options = args.extract_options!

        if options.present?
          scope = apply_finder_options(options, true)

          case finder = args.first
          when :first, :last, :all
            ActiveSupport::Deprecation.warn(
              "Calling #find(#{finder.inspect}) is deprecated. Please call " \
              "##{finder} directly instead. You have also used finder options. " \
              "These are also deprecated. Please build a scope instead of using " \
              "finder options."
            )

            scope.send(finder)
          else
            ActiveSupport::Deprecation.warn(
              "Passing options to #find is deprecated. Please build a scope " \
              "and then call #find on it."
            )

            scope.find(*args)
          end
        else
          case finder = args.first
          when :first, :last, :all
            ActiveSupport::Deprecation.warn(
              "Calling #find(#{finder.inspect}) is deprecated. Please call " \
              "##{finder} directly instead."
            )

            send(finder)
          else
            super
          end
        end
      end

      def first(*args)
        if args.empty?
          super
        else
          if args.first.kind_of?(Integer) || (loaded? && !args.first.kind_of?(Hash))
            super
          else
            ActiveSupport::Deprecation.warn(
              "Relation#first with finder options is deprecated. Please build " \
              "a scope and then call #first on it instead."
            )

            apply_finder_options(args.first, true).first
          end
        end
      end

      def last(*args)
        if args.empty?
          super
        else
          if args.first.kind_of?(Integer) || (loaded? && !args.first.kind_of?(Hash))
            super
          else
            ActiveSupport::Deprecation.warn(
              "Relation#last with finder options is deprecated. Please build " \
              "a scope and then call #last on it instead."
            )

            apply_finder_options(args.first, true).last
          end
        end
      end

      def all(*args)
        ActiveSupport::Deprecation.warn("Relation#all is deprecated. Please use #to_a instead.")
        apply_finder_options(args.first, true).to_a
      end

      # ActiveRecord::Relation usually compiled delegator methods at runtime as an optimisation.
      # However, we want to hook into method_missing in CollectionProxy in order to do extra
      # stuff around find_or_{create|initialize}_by methods. If a compiled method for the delegation
      # is defined, then we have no way to hook in because method_missing is never invoked.
      # Therefore, the purpose of this is simply to prevent the super implementation of
      # method_missing being called in this case, which prevent the compiled delegation from
      # being created.
      def method_missing(method, *args, &block)
        match = DynamicMatchers::Method.match(klass, method)

        if match && match.is_a?(DynamicMatchers::Instantiator)
          scoping { klass.send(method, *args, &block) }
        else
          super
        end
      end
    end

    include DeprecatedMethods
    alias_method_chain :update_all, :deprecated_options
  end
end
