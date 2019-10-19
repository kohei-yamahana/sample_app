module SessionsHelper
    
    def log_in(user)
        session[:user_id] = user.id
    end
    
    def remember(user)
        user.remember
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    def current_user
        if (user_id = session[:user_id])
            @current_user||= User.find_by(id: user_id)
            # 上記のものは、@current_user = @current_user || User.find_by(id: session[:user_id])
            # の短縮形。rubyの左から処理していきtrueになると止まる特性を生かしたもの。
        elsif (user_id = cookies.signed[:user_id])
            user = User.find_by(id: user_id)
            if user&&user.authenticated?(cookies[:remembar_token])
                log_in user
                @current_user = user
            end
        end
    end
    
    def logged_in?
        !current_user.nil?
    end
    
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end
    
    def log_out
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end
    
end
