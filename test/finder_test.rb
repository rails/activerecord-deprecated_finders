require 'helper'

describe 'finders' do
  before do
    @posts = 3.times.map { |i| Post.create id: i + 1 }
  end

  after do
    Post.delete_all
  end

  it 'supports find(:all) with no options' do
    Post.find(:all).must_equal @posts
  end

  it 'supports find(:all) with options' do
    Post.find(:all, conditions: 'id >= 2').must_equal [@posts[1], @posts[2]]
  end

  it 'supports all with options' do
    Post.all(conditions: 'id >= 2').must_equal [@posts[1], @posts[2]]
  end

  it 'supports find(:first) with no options' do
    Post.order(:id).find(:first).must_equal @posts.first
  end

  it 'supports find(:first) with options' do
    Post.order(:id).find(:first, conditions: 'id >= 2').must_equal @posts[1]
  end

  it 'supports first with options' do
    assert_deprecated { Post.order(:id).first(conditions: 'id >= 2') }.must_equal @posts[1]
  end

  it 'supports find(:last) with no options' do
    Post.order(:id).find(:last).must_equal @posts.last
  end

  it 'supports find(:last) with options' do
    Post.order(:id).find(:last, conditions: 'id <= 2').must_equal @posts[1]
  end

  it 'supports last with options' do
    assert_deprecated { Post.order(:id).last(conditions: 'id <= 2') }.must_equal @posts[1]
  end
end
