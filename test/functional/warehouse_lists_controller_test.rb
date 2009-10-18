require 'test_helper'

class WarehouseListsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:warehouse_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create warehouse_list" do
    assert_difference('WarehouseList.count') do
      post :create, :warehouse_list => { }
    end

    assert_redirected_to warehouse_list_path(assigns(:warehouse_list))
  end

  test "should show warehouse_list" do
    get :show, :id => warehouse_lists(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => warehouse_lists(:one).to_param
    assert_response :success
  end

  test "should update warehouse_list" do
    put :update, :id => warehouse_lists(:one).to_param, :warehouse_list => { }
    assert_redirected_to warehouse_list_path(assigns(:warehouse_list))
  end

  test "should destroy warehouse_list" do
    assert_difference('WarehouseList.count', -1) do
      delete :destroy, :id => warehouse_lists(:one).to_param
    end

    assert_redirected_to warehouse_lists_path
  end
end
