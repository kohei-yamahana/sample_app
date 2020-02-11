require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
  end
  
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
  
  
   
  test "valid signup indormation with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: {name: "Example User",
                                email: "user@example.com",
                                password:   "password",
                                password_confirmation: "password"} }
      end
      assert_equal 1, ActionMailer::Base.deliveries.size
      #配信されたメッセージがきっかり1つであるかどうか確認する
      user = assigns(:user)
      assert_not user.activated?
      #有効化していない状態でログインしてみる
      log_in_as(user)
      assert_not is_logged_in?
      #有効化トークンが不正な場合
      get edit_account_activation_path("invalid token", email: user.email)
      assert_not is_logged_in?
      #トークンは正しいがメールアドレスが無効な場合
      get edit_account_activation_path(user.activation_token, email:'wrong')
      assert_not is_logged_in?
      #有効化トークンが正しい場合
      get edit_account_activation_path(user.activation_token, email: user.email)
      assert user.reload.activated?
      follow_redirect!
      assert_template 'users/show'
      assert is_logged_in?
    end

end
