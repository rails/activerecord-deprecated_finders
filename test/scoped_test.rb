require 'helper'

describe 'scoped' do
  it 'accepts a deprecated conditions option' do
    Post.scoped(conditions: :foo).where_values.must_equal [:foo]
  end

  it 'accepts a deprecated include option' do
    Post.scoped(include: :foo).includes_values.must_equal [:foo]
  end

  it 'accepts a deprecated extend option' do
    mod = Module.new
    Post.scoped(extend: mod).extensions.must_equal [mod]
  end
end
