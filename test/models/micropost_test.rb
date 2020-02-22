require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  
  def setup
    @user = users(:michael)
    #このコードは慣習的に正しくない。なぜならリレーションを活用せず、user_idに＠user.idを格納してるから
    # 旧 @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
    # buildとcreateの違い
    # DBにアクセスするかしないか。
    # build：DBにアクセスせずインスタンスを確保する。→比較的処理が軽くなる
    # create：DBにアクセスし、インスタンスを永続化する。DBにデータを作成。
  end
  
  test "should be valid" do
    assert @micropost.valid?
  end
  
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end
  
  test "content should be present" do
    @micropost.content = ""
    assert_not @micropost.valid?
  end
  
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end
  
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
  
  
end
