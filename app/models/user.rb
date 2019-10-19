class User < ApplicationRecord
    attr_accessor :remember_token
    # 仮想の属性remember_token作成
    
    before_save{ email.downcase! }
    
    validates :name, presence:true,length:{ maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence:true,length:{ maximum: 225 }, 
                      format:{with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
    has_secure_password
    validates :password, presence: true, length: {minimum: 6}
    
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
    
    def authenticated?(remember_token)
        return false if remember_digest.nil?
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end
    
    def forget
        update_attribute(:remember_digest, nil)
    end
end
