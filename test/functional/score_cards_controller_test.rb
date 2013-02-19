require 'test_helper'

class ScoreCardsControllerTest < ActionController::TestCase
  setup do
    @score_card = score_cards(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:score_cards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create score_card" do
    assert_difference('ScoreCard.count') do
      post :create, score_card: { financial: @score_card.financial, isin: @score_card.isin, name: @score_card.name, price: @score_card.price }
    end

    assert_redirected_to score_card_path(assigns(:score_card))
  end

  test "should show score_card" do
    get :show, id: @score_card
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @score_card
    assert_response :success
  end

  test "should update score_card" do
    put :update, id: @score_card, score_card: { financial: @score_card.financial, isin: @score_card.isin, name: @score_card.name, price: @score_card.price }
    assert_redirected_to score_card_path(assigns(:score_card))
  end

  test "should destroy score_card" do
    assert_difference('ScoreCard.count', -1) do
      delete :destroy, id: @score_card
    end

    assert_redirected_to score_cards_path
  end
end
