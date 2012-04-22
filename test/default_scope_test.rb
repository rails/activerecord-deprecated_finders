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
    klass = Class.new(Post) do
      self.table_name = 'posts'
      default_scope conditions: { id: 1 }
    end
    assert_equal [1], klass.all.map(&:id)
  end

  it 'works with a finder hash and a scope' do
    klass = Class.new(Post) do
      self.table_name = 'posts'
      default_scope { where("title like '%foo%'") }
      default_scope conditions: "title like '%omg%'"
    end
    assert_equal [2], klass.all.map(&:id)
  end
end
