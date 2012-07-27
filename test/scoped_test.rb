require 'helper'

describe 'scoped' do
  it 'accepts a deprecated conditions option' do
    assert_deprecated { Post.scoped(conditions: :foo) }.where_values.must_equal [:foo]
  end

  it 'accepts a deprecated include option' do
    assert_deprecated { Post.scoped(include: :foo) }.includes_values.must_equal [:foo]
  end

  it 'accepts a deprecated extend option' do
    mod = Module.new
    assert_deprecated { Post.scoped(extend: mod) }.extensions.must_equal [mod]
  end

  it 'is deprecated' do
    assert_deprecated { Post.scoped }
  end
end
