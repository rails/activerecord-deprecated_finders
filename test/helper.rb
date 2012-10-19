require 'bundler/setup'
require 'minitest/spec'
require 'minitest/autorun'
require 'active_record'
require 'active_record/deprecated_finders'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :posts do |t|
    t.string :title
    t.string :category
  end

  create_table :comments do |t|
    t.string :title
    t.references :post
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  def self.lol
    "lol"
  end
end

require 'active_support/testing/deprecation'
ActiveSupport::Deprecation.debug = true

class MiniTest::Spec
  include ActiveSupport::Testing::Deprecation
end
