require 'test_helper'

class RisingScoresControllerTest < ActionController::TestCase
  setup do
    @rising_score = rising_scores(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rising_scores)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rising_score" do
    assert_difference('RisingScore.count') do
      post :create, rising_score: { days: @rising_score.days, isin: @rising_score.isin }
    end

    assert_redirected_to rising_score_path(assigns(:rising_score))
  end

  test "should show rising_score" do
    get :show, id: @rising_score
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @rising_score
    assert_response :success
  end

  test "should update rising_score" do
    put :update, id: @rising_score, rising_score: { days: @rising_score.days, isin: @rising_score.isin }
    assert_redirected_to rising_score_path(assigns(:rising_score))
  end

  test "should destroy rising_score" do
    assert_difference('RisingScore.count', -1) do
      delete :destroy, id: @rising_score
    end

    assert_redirected_to rising_scores_path
  end
end
