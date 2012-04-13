require 'active_support/core_ext/module/aliasing'

module ActiveRecord
  class Relation
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
    alias_method_chain :update_all, :deprecated_options
  end
end
