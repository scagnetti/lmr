require 'test_helper'

class DepositEntriesControllerTest < ActionController::TestCase
  setup do
    @deposit_entry = deposit_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:deposit_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create deposit_entry" do
    assert_difference('DepositEntry.count') do
      post :create, deposit_entry: { balance: @deposit_entry.balance }
    end

    assert_redirected_to deposit_entry_path(assigns(:deposit_entry))
  end

  test "should show deposit_entry" do
    get :show, id: @deposit_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @deposit_entry
    assert_response :success
  end

  test "should update deposit_entry" do
    patch :update, id: @deposit_entry, deposit_entry: { balance: @deposit_entry.balance }
    assert_redirected_to deposit_entry_path(assigns(:deposit_entry))
  end

  test "should destroy deposit_entry" do
    assert_difference('DepositEntry.count', -1) do
      delete :destroy, id: @deposit_entry
    end

    assert_redirected_to deposit_entries_path
  end
end
