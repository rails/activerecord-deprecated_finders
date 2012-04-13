require 'active_record/relation'
require 'active_support/core_ext/module/aliasing'

module ActiveRecord
  class Relation
    module DeprecatedMethods
      VALID_FIND_OPTIONS = [ :conditions, :include, :joins, :limit, :offset, :extend,
                             :order, :select, :readonly, :group, :having, :from, :lock ]

      def apply_finder_options(options)
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
        if conditions || options.present?
          where(conditions)
            .apply_finder_options(options.slice(:limit, :order))
            .update_all_without_deprecated_options(updates)
        else
          update_all_without_deprecated_options(updates)
        end
      end

      def find_in_batches(options = {}, &block)
        if (finder_options = options.except(:start, :batch_size)).present?
          raise "You can't specify an order, it's forced to be #{batch_order}" if options[:order].present?
          raise "You can't specify a limit, it's forced to be the batch_size"  if options[:limit].present?

          apply_finder_options(finder_options).
            find_in_batches(options.slice(:start, :batch_size), &block)
        else
          super
        end
      end

      def calculate(operation, column_name, options = {})
        if options.except(:distinct).present?
          apply_finder_options(options.except(:distinct))
            .calculate(operation, column_name, :distinct => options[:distinct])
        else
          super
        end
      end

      def find(*args)
        options = args.extract_options!

        if options.present?
          apply_finder_options(options).find(*args)
        else
          case args.first
          when :first, :last, :all
            send(args.first)
          else
            super
          end
        end
      end

      def first(*args)
        if args.any?
          if args.first.kind_of?(Integer) || (loaded? && !args.first.kind_of?(Hash))
            super
          else
            apply_finder_options(args.first).first
          end
        else
          super
        end
      end

      def last(*args)
        if args.any?
          if args.first.kind_of?(Integer) || (loaded? && !args.first.kind_of?(Hash))
            super
          else
            apply_finder_options(args.first).last
          end
        else
          super
        end
      end

      def all(*args)
        args.any? ? apply_finder_options(args.first).all : super
      end
    end

    include DeprecatedMethods
    alias_method_chain :update_all, :deprecated_options
  end
end
