module ActiveRecord
  module DynamicMatchers
    class FindAllBy < Method
      Method.matchers << self
      include Finder

      def self.prefix
        "find_all_by"
      end

      def finder
        "where"
      end

      def result
        "#{super}.to_a"
      end
    end

    class FindLastBy < Method
      Method.matchers << self
      include Finder

      def self.prefix
        "find_last_by"
      end

      def finder
        "where"
      end

      def result
        "#{super}.last"
      end
    end

    class ScopedBy < Method
      Method.matchers << self
      include Finder

      def self.prefix
        "scoped_by"
      end

      def body
        "where(#{attributes_hash})"
      end
    end

    class Instantiator < Method
      # This is nasty, but it doesn't matter because it will be deprecated.
      def self.dispatch(klass, attribute_names, instantiator, args, block)
        if args.length == 1 && args.first.is_a?(Hash)
          attributes = args.first.stringify_keys
          conditions = attributes.slice(*attribute_names)
          rest       = [attributes.except(*attribute_names)]
        else
          raise ArgumentError, "too few arguments" unless args.length >= attribute_names.length

          conditions = Hash[attribute_names.map.with_index { |n, i| [n, args[i]] }]
          rest       = args.drop(attribute_names.length)
        end

        klass.where(conditions).first ||
          klass.create_with(conditions).send(instantiator, *rest, &block)
      end

      def signature
        "*args, &block"
      end

      def body
        "#{self.class}.dispatch(self, #{attribute_names.inspect}, #{instantiator.inspect}, args, block)"
      end

      def instantiator
        raise NotImplementedError
      end
    end

    class FindOrInitializeBy < Instantiator
      Method.matchers << self

      def self.prefix
        "find_or_initialize_by"
      end

      def instantiator
        "new"
      end
    end

    class FindOrCreateBy < Instantiator
      Method.matchers << self

      def self.prefix
        "find_or_create_by"
      end

      def instantiator
        "create"
      end
    end

    class FindOrCreateByBang < Instantiator
      Method.matchers << self

      def self.prefix
        "find_or_create_by"
      end

      def self.suffix
        "!"
      end

      def instantiator
        "create!"
      end
    end

    module DeprecatedFinder
      def body
        <<-CODE
          result = #{super}
          result && block_given? ? yield(result) : result
        CODE
      end

      def result
        "scoped.apply_finder_options(options).#{super}"
      end

      def signature
        "#{super}, options = {}"
      end
    end

    [FindBy, FindByBang, FindAllBy, FindLastBy].each do |klass|
      klass.send(:include, DeprecatedFinder)
    end
  end
end
