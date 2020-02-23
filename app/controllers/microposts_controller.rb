class MicropostsController < ApplicationController
    before_action :logged_in_user, only: [:create, :destroy]
    before_action :corrent_user,   only: :destroy
    
    def create
        @micropost = current_user.microposts.build(micropost_params)
        if @micropost.save
            flash[:success] = "Micropost craetd!"
            redirect_to root_url
        else
            @feed_items = []
            render 'static_pages/home'
        end
    end
    
    def destroy
        @micropost.destroy
        flash[:success] = "Micropost deleted"
        redirect_to request.referrer || root_url
        # redirect_back(fallback_location: root_url) => Rail５から導入された。同じ機能。
        # request.referrerは一つ前のurlを返す。そして、nilが帰ってきたらroot_urlに飛ぶ
    end
    
    private
    
        def micropost_params
            params.require(:micropost).permit(:content, :picture)
        end
        
        def corrent_user
            @micropost = current_user.microposts.find_by(id: params[:id])
            redirect_to root_url if @micropost.nil?
        end
    
end
