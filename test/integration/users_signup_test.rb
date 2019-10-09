require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  test "invaid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
     post signup_path, params: { user: {name: "Example User",
                                email: "user@invalid",
                                password:   "foo",
                                password_confirmation: "bar"}}
                                  # テストの意義：ユーザー登録が失敗した時に、間違えて登録されていないか
  #               assert_no_differenceで実行前後のユーザー数をカウントし同数か
  #               確かめている。
    end
    
  assert_template 'users/new'
  assert_select 'div#error_explanation'
  assert_select 'div.alert'
  # assert_select 'form[action ="/signup"]'
  #意義："invaid signup information" をテストした結果、それに付随して動作して
  # ほしい機能が実際動いているか確かめる。
  end
  
  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: {name: "Example User",
                                email: "user@example.com",
                                password:   "password",
                                password_confirmation: "password"} }
      end
      follow_redirect!
      assert_template 'users/show'
      assert_not flash.empty?
      assert is_logged_in?
    end
  # test "the truth" do
  #   assert true
  # end
end
