require 'active_record/associations/builder/association'
require 'active_support/core_ext/module/aliasing'

module ActiveRecord::Associations::Builder
  class DeprecatedOptionsProc
    attr_reader :options

    def initialize(options)
      options[:includes]  = options.delete(:include)    if options[:include]
      options[:where]     = options.delete(:conditions) if options[:conditions]
      options[:extending] = options.delete(:extend)     if options[:extend]

      @options = options
    end

    def to_proc
      options = self.options
      proc do |owner|
        if options[:where].respond_to?(:to_proc)
          context = owner || self
          where(context.instance_eval(&options[:where]))
            .merge!(options.except(:where))
        else
          scoped(options)
        end
      end
    end

    def arity
      1
    end
  end

  class Association
    # FIXME: references should not be in this list
    DEPRECATED_OPTIONS = [:readonly, :references, :order, :limit, :group, :having,
                          :offset, :select, :uniq, :include, :conditions, :extend]

    # FIXME: or this list...
    self.valid_options += [:select, :conditions, :include, :extend, :readonly, :references]

    def initialize_with_deprecated_options(*args)
      initialize_without_deprecated_options(*args)

      unless scope
        deprecated_options = options.slice(*DEPRECATED_OPTIONS)

        unless deprecated_options.empty?
          @scope   = DeprecatedOptionsProc.new(deprecated_options)
          @options = options.except(*DEPRECATED_OPTIONS)
        end
      end
    end

    alias_method_chain :initialize, :deprecated_options
  end

  class CollectionAssociation
    include Module.new {
      def valid_options
        super + [:order, :group, :having, :limit, :offset, :uniq]
      end
    }
  end
end
