require 'mysql2'
require 'colorize'
require 'twitter'

class TweetFinder

  def mysql
    @mysql ||= Mysql2::Client.new(:host => 'localhost', :username => 'root', :database => 'artist_mapper')
  end

  def setup_twitter
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = Credentials::TWITTER_CONSUMER_KEY
      config.consumer_secret = Credentials::TWITTER_CONSUMER_SECRET
      config.access_token = Credentials::TWITTER_ACCESS_TOKEN
      config.access_token_secret = Credentials::TWITTER_ACCESS_SECRET
    end

    client
  end

  def twitter
    @twitter ||= setup_twitter
  end

  def get_track_name_from_id(id)
    result = mysql.query("select `name` from `tracks` where `id` = #{id} limit 1")
    result.first['name']
  end

  def get_artist_name_from_track_id(id)
    track = mysql.query("select `artist` from `tracks` where `id` = #{id} limit 1")
    artist = mysql.query("select `name` from `artists` where `id` = #{track.first['artist']} limit 1")
    artist.first['name']
  end

  def find_tweets!
    main_query = 'select `id`, `track_1`, `track_2` from `similars` where `tracks_processed` = 0 limit 5'
    similars = mysql.query(main_query)

    while similars.count != 0
      similars.each do |similar|
        track_one = get_track_name_from_id(similar['track_1'])
        track_one_artist = get_artist_name_from_track_id(similar['track_1'])
        track_two = get_track_name_from_id(similar['track_2'])
        track_two_artist = get_artist_name_from_track_id(similar['track_2'])
        puts "Asking twitter for tweets about #{track_one} by #{track_one_artist}"

        retries = 0
        begin
          twitter.search("#{track_one} by #{track_one_artist}").each do |tweet|
            puts tweet.text
            puts tweet.user.screen_name
            puts "Asking twitter for tweets about #{track_two} by #{track_two_artist}"

            twitter.search("#{track_two} by #{track_two_artist}").each do |other_tweet|
              puts other_tweet.text
              puts other_tweet.user.screen_name

              if other_tweet.user.screen_name == tweet.user.screen_name
                puts 'MATCH FOUND!'.red
                sql = 'insert into `matches` (`similar`, `user`, `tweet_1`, `tweet_2`) values (' +
                    "#{similar['id']}, '#{mysql.escape(tweet.user.screen_name)}', '#{mysql.escape(tweet.text)}', " +
                    "'#{mysql.escape(other_tweet.text)}')"
                mysql.query(sql)
              end
            end

            puts ''
          end
        rescue Twitter::Error::TooManyRequests
          puts 'Rate limit exceeded. Waiting 15 minutes...'

          (1..15).each do |minute|
            sleep 60
            unless minute == 15
              puts "#{15-minute} minutes(s) left..."
            end
          end

          retries += 1
          unless retries > 3
            retry
          end
        end

        retries = 0
        mysql.query("update `similars` set `tracks_processed` = 1 where `id` = #{similar['id']} limit 1")
      end

      # run the query again to get an updated set of results
      similars = mysql.query(main_query)
    end
  end

  def purge_duplicate_matches!
    similars = mysql.query('select `similar`, count(*) from `matches` group by `similar`')

    similars.each do |similar|
      matches = mysql.query("select * from `matches` where `similar` = #{similar['similar']}")
      matches.each do |match|
        # first we need to query to make sure this match hasn't already been deleted
        exists = mysql.query("select `id` from `matches` where `id` = #{match['id']} limit 1")

        unless exists.count != 1
          query = "select `id` from `matches` where `id` != #{match['id']} and `user` = " +
              "'#{mysql.escape(match['user'])}' and `tweet_1` = " +
              "'#{mysql.escape(match['tweet_1'])}' and `tweet_2` = '#{mysql.escape(match['tweet_2'])}'"
          duplicates = mysql.query(query)

          duplicates.each do |duplicate|
            puts "DUPLICATES FOUND: ids #{match['id']} and #{duplicate['id']}"
            mysql.query("delete from `matches` where `id` = #{duplicate['id']} limit 1")
          end
        end
      end
    end
  end

end