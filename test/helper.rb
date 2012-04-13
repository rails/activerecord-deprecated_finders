require 'bundler/setup'
require 'active_record_deprecated_finders'
require 'minitest/spec'
require 'minitest/autorun'
require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :posts do |t|
    t.string :title
  end
end

class Post < ActiveRecord::Base
end
