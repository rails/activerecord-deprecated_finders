require 'helper'

describe 'calculate' do
  after do
    Post.destroy_all
  end

  it 'supports finder options' do
    Post.create id: 1
    Post.create id: 2, title: 'foo'
    Post.create id: 3, title: 'foo'

    assert_deprecated { Post.calculate(:sum, :id, conditions: { title: 'foo' }) }.must_equal 5
  end

  if active_record_4_0?
    it 'should pass :distinct option along' do
      Post.create id: 1, title: "foo"
      Post.create id: 2, title: "bar"
      Post.create id: 3, title: "bar"
      Post.create id: 4, title: "baz"

      _result, deprecations = collect_deprecations do
        Post.count(:title, conditions: { title: ["bar", "baz"] }, distinct: true).must_equal 2
      end
      assert_equal 2, deprecations.size, deprecations
    end
  end

  it 'should not issue :distinct deprecation warning when :distinct was not passed' do
    Post.create id: 1
    Post.create id: 2, title: "bar"

    _result, deprecations = collect_deprecations do
      Post.count(conditions: { title: "bar" }).must_equal 1
    end
    assert_equal 1, deprecations.size, deprecations
  end
end
