require 'helper'

describe 'associations' do
  before do
    @klass = Class.new(ActiveRecord::Base)
    def @klass.name; 'Post'; end
    @klass.table_name = 'posts'
  end

  it 'translates hash scope options into scopes' do
    extension = Module.new

    @klass.has_many :comments, readonly: 'a', order: 'b', limit: 'c', group: 'd', having: 'e',
                               offset: 'f', select: 'g', uniq: 'h', include: 'i', conditions: 'j',
                               extend: extension

    scope = @klass.new.comments

    scope.readonly_value.must_equal 'a'
    scope.order_values.must_equal ['b']
    scope.limit_value.must_equal 'c'
    scope.group_values.must_equal ['d']
    scope.having_values.must_equal ['e']
    scope.offset_value.must_equal 'f'
    scope.select_values.must_equal ['g']
    scope.uniq_value.must_equal 'h'
    scope.includes_values.must_equal ['i']
    scope.where_values.must_include 'j'
    scope.extensions.must_equal [extension]
  end

  it 'supports proc where values' do
    @klass.has_many :comments, conditions: proc { 'omg' }
    @klass.new.comments.where_values.must_include 'omg'
    @klass.joins(:comments).to_sql.must_include 'omg'
  end

  it 'supports proc where values which access the owner' do
    @klass.has_many :comments, conditions: proc { title }
    @klass.new(title: 'omg').comments.where_values.must_include 'omg'
  end

  it 'allows an extend option plus a block extension' do
    mod = Module.new { def foo; 'foo'; end }
    @klass.has_many(:comments, extend: mod) { def bar; 'bar'; end }

    obj = @klass.new
    obj.comments.foo.must_equal 'foo'
    obj.comments.bar.must_equal 'bar'
  end

  it "allows a declaration with a scope with no options" do
    @klass.has_many :comments, -> { limit 5 }
    scope = @klass.new.comments
    scope.limit_value.must_equal 5
  end
end
