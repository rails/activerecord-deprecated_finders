require 'helper'

describe 'scope' do
  before do
    @klass = Class.new(ActiveRecord::Base)
  end

  it 'supports a finder hash' do
    assert_deprecated { @klass.scope :foo, conditions: :foo }
    @klass.foo.where_values.must_equal [:foo]
  end

  it 'supports a finder hash inside a callable' do
    @klass.scope :foo, ->(v) { { conditions: v } }
    assert_deprecated { @klass.foo(:bar) }.where_values.must_equal [:bar]
  end

  it 'supports chaining' do
    @klass.scope :foo, -> { @klass.where(:foo) }
    assert_deprecated { @klass.scope :bar, conditions: :bar }
    @klass.foo.bar.where_values.must_equal [:foo, :bar]
  end
end
