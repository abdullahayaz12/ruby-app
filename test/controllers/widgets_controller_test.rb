require 'test_helper'

class WidgetsControllerTest < ActionController::TestCase
  setup do
    @widget = widgets(:one)
  end

  # Index action tests
  test "should get index" do
    get :index
    assert_response :success
  end

  test "index should load widgets" do
    get :index
    assert_response :success
  end

  # New action tests
  test "should get new" do
    get :new
    assert_response :success
  end

  # Create action tests
  test "should create widget with valid params" do
    assert_difference('Widget.count') do
      post :create,
        params: {
          widget: {
            description: 'Valid Description',
            name: 'Valid Widget',
            stock: 5
          }
        }
    end

    assert_redirected_to widget_path(Widget.last)
  end

  test "should not create widget with missing name" do
    assert_no_difference('Widget.count') do
      post :create,
        params: {
          widget: {
            description: 'Test',
            stock: 5
          }
        }
    end

    assert_response :success
  end

  test "should not create widget with negative stock" do
    assert_no_difference('Widget.count') do
      post :create,
        params: {
          widget: {
            name: 'Widget',
            description: 'Test',
            stock: -5
          }
        }
    end
  end

  # Show action tests
  test "should show widget" do
    get :show, params: { id: @widget }
    assert_response :success
  end

  test "show should return 404 for non-existent widget" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, params: { id: 99999 }
    end
  end

  # Edit action tests
  test "should get edit" do
    get :edit, params: { id: @widget }
    assert_response :success
  end

  test "edit should return 404 for non-existent widget" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, params: { id: 99999 }
    end
  end

  # Update action tests
  test "should update widget with valid params" do
    new_name = 'Updated Widget Name'
    patch :update,
      params: {
        id: @widget,
        widget: {
          description: @widget.description,
          name: new_name,
          stock: @widget.stock
        }
      }

    @widget.reload
    assert_equal new_name, @widget.name
    assert_redirected_to widget_path(@widget)
  end

  test "should not update widget with invalid params" do
    original_name = @widget.name
    patch :update,
      params: {
        id: @widget,
        widget: {
          name: '',
          description: @widget.description,
          stock: @widget.stock
        }
      }

    @widget.reload
    assert_equal original_name, @widget.name
  end

  test "should update only stock quantity" do
    new_stock = @widget.stock + 10
    patch :update,
      params: {
        id: @widget,
        widget: {
          stock: new_stock,
          name: @widget.name,
          description: @widget.description
        }
      }

    @widget.reload
    assert_equal new_stock, @widget.stock
  end

  # Destroy action tests
  test "should destroy widget" do
    widget = widgets(:two)
    assert_difference('Widget.count', -1) do
      delete :destroy, params: { id: widget }
    end

    assert_redirected_to widgets_path
  end

  test "should not destroy non-existent widget" do
    assert_raises(ActiveRecord::RecordNotFound) do
      delete :destroy, params: { id: 99999 }
    end
  end

  # Performance tests
  test "index should respond successfully" do
    get :index
    assert_response :success
  end

  test "show should fetch widget" do
    get :show, params: { id: @widget }
    assert_response :success
  end
end
