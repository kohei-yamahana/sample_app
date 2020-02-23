class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> {order(created_at: :desc)}
  mount_uploader :picture, PictureUploader
  # mount_uploaderメソッドはCarrierWaveに画像と関連付けたモデルを伝える。
  # 引数に属性名のシンボルと生成したアップローダーのクラス名をとる。
  validates :user_id, presence:true
  validates :content, presence:true, length: { maximum: 140}
  validate  :picture_size
  
  private
  
  # アップロードされた画像のサイズをバリデーション
  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, "should be less than 5MB")
    end
  end
  
end
