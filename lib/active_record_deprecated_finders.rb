require 'active_support/lazy_load_hooks'
require 'active_record_deprecated_finders/version'

ActiveSupport.on_load(:active_record) do
  require 'active_record_deprecated_finders/relation'
end
