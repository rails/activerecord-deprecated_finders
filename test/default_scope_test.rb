require 'helper'

describe 'default scope' do
  before do
    Post.create(id: 1, title: 'foo lol')
    Post.create(id: 2, title: 'foo omg')
    Post.create(id: 3)
  end

  after do
    Post.delete_all
  end

  it 'works with a finder hash' do
    klass = Class.new(Post)
    klass.table_name = 'posts'
    assert_deprecated { klass.default_scope conditions: { id: 1 } }

    klass.all.map(&:id).must_equal [1]
  end

  it 'works with a finder hash and a scope' do
    klass = Class.new(Post)
    klass.table_name = 'posts'
    klass.default_scope { klass.where("title like '%foo%'") }
    ActiveSupport::Deprecation.silence do
      klass.default_scope conditions: "title like '%omg%'"
    end

    klass.all.map(&:id).must_equal [2]
  end
end
