require 'test_helper'

class InsiderDealsControllerTest < ActionController::TestCase
  setup do
    @insider_deal = insider_deals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:insider_deals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create insider_deal" do
    assert_difference('InsiderDeal.count') do
      post :create, insider_deal: { link: @insider_deal.link, occurred: @insider_deal.occurred, person: @insider_deal.person, price: @insider_deal.price, quanity: @insider_deal.quanity, type: @insider_deal.type }
    end

    assert_redirected_to insider_deal_path(assigns(:insider_deal))
  end

  test "should show insider_deal" do
    get :show, id: @insider_deal
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @insider_deal
    assert_response :success
  end

  test "should update insider_deal" do
    put :update, id: @insider_deal, insider_deal: { link: @insider_deal.link, occurred: @insider_deal.occurred, person: @insider_deal.person, price: @insider_deal.price, quanity: @insider_deal.quanity, type: @insider_deal.type }
    assert_redirected_to insider_deal_path(assigns(:insider_deal))
  end

  test "should destroy insider_deal" do
    assert_difference('InsiderDeal.count', -1) do
      delete :destroy, id: @insider_deal
    end

    assert_redirected_to insider_deals_path
  end
end
