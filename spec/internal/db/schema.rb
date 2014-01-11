ActiveRecord::Schema.define do
  create_table :articles, :force => true do |t|
    t.integer :user_id
    t.timestamps
  end

  create_table :comments, :force => true do |t|
    t.integer :article_id
    t.integer :user_id
    t.timestamps
  end

  create_table :users, :force => true do |t|
    t.timestamps
  end
end
