class SessionsController < ApplicationController
  def new
  end
  
  def create
    @user = User.find_by(email:params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
    # 「ユーザーがデータベースにあり、かつ、認証に成功した場合にのみ」
      log_in @user
      params[:session][:remember_me] == '1' ? remember(@user): forget(@user)
      redirect_to @user
    else
      flash.now[:danger] = 'invalid email/password combination'
      # flash.nowは次にリクエストが発生した時に消滅する。rails
      render 'new'
    end
  end
  
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
