class User < ApplicationRecord
    has_many :microposts, dependent: :destroy
    # dependent(依存)で、userの削除はmicropostと連動する
    has_many :active_relationships, class_name: "Relationship",#外部キーが<class>_idによって推測されるため。
                                    foreign_key: "follower_id",#foreign_keyは外部キーの意。
                                    dependent: :destroy
    has_many :passive_relationships, class_name: "Relationship",
                                     foreign_key: "followed_id",
                                     dependent: :destroy
    has_many :following, through: :active_relationships, source: :followed
    #フォロー
    # source: :followedはhas_many :followedsという表記がおかしいので、
    # followingへと明示的に変更するために行っている。
    has_many :followers, through: :passive_relationships, source: :follower
    #フォロアー
    # 今回source: :followerはいらなかったが、上記との類似性を強調するために書いた。
    attr_accessor :remember_token, :activation_token, :reset_token
    before_save   :downcase_email
    before_create :create_activation_digest
    # 仮想の属性remember_token作成

    validates :name, presence:true,length:{ maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence:true,length:{ maximum: 225 }, 
                      format:{with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
    has_secure_password
    validates :password, presence: true, length: {minimum: 6}, allow_nil: true
    
    def self.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST:
                                                  BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end
    
    def self.new_token
        SecureRandom.urlsafe_base64
    end
    
    def remember
        self.remember_token = User.new_token
        # selfキーワード、selfは自身の動いているオブジェクトをさす予約語。今回の場合User。
        # つまり、ここではUserに属性"remember_token"を定義し、User.new_tokenを代入している。
        update_attribute(:remember_digest, User.digest(remember_token))
        # 第一引数に更新対象、第二引数に更新内容を指定。
    end
    
    def authenticated?(attribute,token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end
    
    def forget
        update_attribute(:remember_digest, nil)
    end
    
    # アカウントを有効にする
    def activate
        update_columns(activated: true, activated_at: Time.zone.now)
    end
    
    # 有効化用のメールを送信する
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end
    
    # パスワード再設定の属性を設定する
    def create_reset_digest
        self.reset_token = User.new_token
        update_attribute(:reset_digest, User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
    end
    
    #パスワード再設定のメールを送信
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end
    
    def feed
        following_ids = "SELECT followed_id FROM relationships 
                         WHERE follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids}) 
                         OR user_id = :user_id", user_id: id)
        # user_id IN (?)でユーザーをフォローしている人を検索、
        # user_id = ? で ユーザー自身を取得。
    end
    
    def follow(other_user)
        following << other_user
    end
    
    def unfollow(other_user)
        active_relationships.find_by(followed_id: other_user.id).destroy
    end
    
    def following?(other_user)
        following.include?(other_user)
    end
    
    private
    
        # メールアドレスを全て小文字化する
        def downcase_email
            self.email.downcase!
        end
        
        # 有効化トークンとダイジェストを作成および代入する
        def create_activation_digest
            self.activation_token = User.new_token
            self.activation_digest = User.digest(activation_token)
        end
    
    
end
