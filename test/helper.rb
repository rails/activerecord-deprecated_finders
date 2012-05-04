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
    t.string :category
  end
end

class Post < ActiveRecord::Base
  attr_accessible :id, :title, :category
end

require 'active_support/testing/deprecation'
ActiveSupport::Deprecation.debug = true

class MiniTest::Spec
  include ActiveSupport::Testing::Deprecation
end
