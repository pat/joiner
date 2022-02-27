class User < ActiveRecord::Base
  has_many :articles
  has_many :comments
  has_many :article_comments, through: :articles, source: :comments
end
