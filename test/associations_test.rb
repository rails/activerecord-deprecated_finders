require 'helper'

describe 'associations' do
  before do
    @klass = Class.new(ActiveRecord::Base)
    def @klass.name; 'Post'; end
    @klass.table_name = 'posts'
  end

  it 'find_or_create_by on has_many through should work' do
    physician = Physician.create!
    ActiveSupport::Deprecation.silence do
      physician.patients.find_or_create_by_name('Tim')
    end
    assert_equal 1, Appointment.count
  end

  it 'translates hash scope options into scopes' do
    assert_deprecated do
      @klass.has_many :comments, readonly: 'a', order: 'b', limit: 'c', group: 'd', having: 'e',
                                 offset: 'f', select: 'g', uniq: 'h', include: 'i', conditions: 'j'
    end

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
  end

  it 'supports proc where values' do
    ActiveSupport::Deprecation.silence do
      @klass.has_many :comments, conditions: proc { 'omg' }
    end
    @klass.new.comments.where_values.must_include 'omg'
    @klass.joins(:comments).to_sql.must_include 'omg'
  end

  it 'supports proc where values which access the owner' do
    ActiveSupport::Deprecation.silence do
      @klass.has_many :comments, conditions: proc { title }
    end
    @klass.new(title: 'omg').comments.where_values.must_include 'omg'
  end

  it "allows a declaration with a scope with no options" do
    ActiveSupport::Deprecation.silence do
      @klass.has_many :comments, -> { limit 5 }
    end
    scope = @klass.new.comments
    scope.limit_value.must_equal 5
  end

  it "raises an ArgumentError when declaration uses both scope and deprecated options" do
    assert_raises(ArgumentError) do
      @klass.has_many :comments, -> { limit 5 }, :order=>'b'
    end
  end
end
