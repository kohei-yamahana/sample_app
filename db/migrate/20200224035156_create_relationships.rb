class CreateRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    add_index :relationships, [:follower_id, :followed_id], unique: true
    # 複合キーインデックスのための行。これはfollower_idとfollowed_idが
    # 必ずユニークである事を保証する仕組み。
    # これにより同じユーザーを２回以上ファローできなくする。
  end
end
