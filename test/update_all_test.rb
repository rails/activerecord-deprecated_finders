require 'helper'

describe 'update_all' do
  it 'supports conditions' do
    foo = Post.create title: 'foo'
    bar = Post.create title: 'bar'

    Post.where(id: [foo, bar]).update_all({ title: 'omg' }, title: 'foo')

    foo.reload.title.must_equal 'omg'
    bar.reload.title.must_equal 'bar'
  end

  it 'supports limit and order' do
    posts = 3.times.map { Post.create }
    Post.where(id: posts).update_all({ title: 'omg' }, {}, limit: 2, order: :id)

    posts.each(&:reload).map(&:title).must_equal ['omg', 'omg', nil]
  end
end
