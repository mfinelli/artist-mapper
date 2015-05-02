require 'mysql2'
require 'colorize'

class TweetFinder

  def mysql
    @mysql ||= Mysql2::Client.new(:host => 'localhost', :username => 'root', :database => 'artist_mapper')
  end

  def find_tweets!

  end

end