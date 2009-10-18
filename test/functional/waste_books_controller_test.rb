require 'test_helper'

class WasteBooksControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:waste_books)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create waste_book" do
    assert_difference('WasteBook.count') do
      post :create, :waste_book => { }
    end

    assert_redirected_to waste_book_path(assigns(:waste_book))
  end

  test "should show waste_book" do
    get :show, :id => waste_books(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => waste_books(:one).to_param
    assert_response :success
  end

  test "should update waste_book" do
    put :update, :id => waste_books(:one).to_param, :waste_book => { }
    assert_redirected_to waste_book_path(assigns(:waste_book))
  end

  test "should destroy waste_book" do
    assert_difference('WasteBook.count', -1) do
      delete :destroy, :id => waste_books(:one).to_param
    end

    assert_redirected_to waste_books_path
  end
end
