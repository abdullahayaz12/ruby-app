require 'test_helper'

class WidgetTest < ActiveSupport::TestCase
  setup do
    @widget = widgets(:one)
  end

  # Model validations
  test "should create widget with valid attributes" do
    widget = Widget.new(name: 'Test Widget', description: 'A test widget', stock: 10)
    assert widget.valid?
  end

  test "should not be valid without name" do
    widget = Widget.new(description: 'No name', stock: 5)
    assert_not widget.valid?
    assert widget.errors[:name].any?
  end

  test "should not be valid without description" do
    widget = Widget.new(name: 'Widget', stock: 5)
    assert_not widget.valid?
    assert widget.errors[:description].any?
  end

  test "should not be valid without stock" do
    widget = Widget.new(name: 'Widget', description: 'Test')
    assert_not widget.valid?
    assert widget.errors[:stock].any?
  end

  test "stock must be an integer" do
    widget = Widget.new(name: 'Widget', description: 'Test', stock: 'invalid')
    assert_not widget.valid?
    assert widget.errors[:stock].any?
  end

  test "stock should not be negative" do
    widget = Widget.new(name: 'Widget', description: 'Test', stock: -5)
    assert_not widget.valid?
    assert widget.errors[:stock].any?
  end

  test "stock can be zero" do
    widget = Widget.new(name: 'Widget', description: 'Test', stock: 0)
    assert widget.valid?
  end

  # Model associations and methods
  test "should have timestamps" do
    assert @widget.respond_to?(:created_at)
    assert @widget.respond_to?(:updated_at)
  end

  test "should update widget attributes" do
    @widget.update(name: 'Updated Widget', stock: 20)
    assert_equal 'Updated Widget', @widget.name
    assert_equal 20, @widget.stock
  end

  test "should destroy widget" do
    widget = widgets(:two)
    assert_difference('Widget.count', -1) do
      widget.destroy
    end
  end

  # Performance and query tests
  test "should fetch widget by id efficiently" do
    widget = Widget.find(@widget.id)
    assert_equal @widget.id, widget.id
  end

  test "should order widgets by created_at descending" do
    widgets = Widget.order(created_at: :desc)
    assert widgets.first.created_at >= widgets.last.created_at
  end

  test "should limit widget query results" do
    widgets = Widget.limit(1)
    assert_equal 1, widgets.count
  end

  test "should count total widgets" do
    count = Widget.count
    assert count > 0
  end

  test "should sum stock quantity" do
    total_stock = Widget.sum(:stock)
    assert total_stock >= 0
  end
end
