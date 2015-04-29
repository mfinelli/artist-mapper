require 'mysql2'
require 'json'
require 'colorize'

class ArtistMapper

  def mysql
    @mysql ||= Mysql2::Client.new(:host => 'localhost', :username => 'root', :database => 'artist_mapper')
  end

  def create_schema!
    File.read('schema.sql').split(';').each do |command|
      mysql.query(command.strip)
    end
  end

  def recurse!
    file_count = 0
    similar_queue = Array.new
    status = {
        ten: false,
        twenty: false,
        thirty: false,
        fourty: false,
        fifty: false,
        sixty: false,
        seventy: false,
        eighty: false,
        ninty: false
    }

    Dir.glob('lastfm_subset/**/**/**/*.json') do |filename|
      json = JSON.parse(File.read(filename))

      # add the artist to the db if it isn't already there
      artist = mysql.escape(json['artist'])
      artist_exists = mysql.query("select `id` from `artists` where `name` = '#{artist}' limit 1")
      unless artist_exists.count == 1
        mysql.query("insert into `artists` (`name`) values ('#{artist}')")

        # query again so that we can get the id later
        artist_exists = mysql.query("select `id` from `artists` where `name` = '#{artist}' limit 1")
      end

      # add the track to the db
      song = mysql.escape(json['title'])
      dataset_id = mysql.escape(json['track_id'])
      artist_id = artist_exists.first['id']
      query = 'insert into `tracks` (`dataset_id`, `name`, `artist`) ' +
          "values ('#{dataset_id}', '#{song}', '#{artist_id}')"
      mysql.query(query)

      # get the similar tracks
      json['similars'].each do |similar|
        similar_queue.push [json['track_id'], similar[0]]
      end

      file_count += 1
    end

    puts 'Files: '.red + file_count.to_s.red
    puts 'Similars count: '.yellow + similar_queue.count.to_s.yellow

    similar_count = 0
    # loop through the similar tracks and make sure the match doesn't already exist (it's unidirectional) and add it
    # to the similar table
    similar_queue.each do |similar_relationship|
      # check to make sure the first track is in our database
      track_one_dsid = mysql.escape(similar_relationship[0])
      track_two_dsid = mysql.escape(similar_relationship[1])
      track_one_result = mysql.query("select `id` from `tracks` where `dataset_id` = '#{track_one_dsid}' limit 1")
      track_two_result = mysql.query("select `id` from `tracks` where `dataset_id` = '#{track_two_dsid}' limit 1")

      unless track_one_result != 1 or track_two_result != 1
        track_one = track_one_result.first['id']
        track_two = track_two_result.first['id']
        # both tracks exist in our database, now make sure the relationship doesn't already exist
        exist_result = mysql.query('select * from `similars` where ' +
                                       "(`track_1` = #{track_one} and `track_2` = #{track_two}) or " +
                                       "(`track_1` = #{track_two} and `track_2` = #{track_one}) limit 1")

        # only insert if the relationship doesn't exist
        unless exist_result.count == 1
          mysql.query("insert into `similars` (`track_1`, `track_2`) values (#{track_one}, #{track_two})")
        end
      end

      similar_count += 1

      # uncomment to see a more fine grained status
      # if similar_count % 1000 == 0
      #   puts similar_count.to_s.yellow + ' similars completed'.yellow
      # end

      percent = (similar_count.to_f / similar_queue.count) * 100

      if percent > 10 and status[:ten] == false
        puts '10% done...'.green
        status[:ten] = true
      elsif percent > 20 and status[:twenty] == false
        puts '20% done...'.green
        status[:twenty] = true
      elsif percent > 30 and status[:thirty] == false
        puts '30% done...'.green
        status[:thirty] = true
      elsif percent > 40 and status[:forty] == false
        puts '40% done...'.green
        status[:forty] = true
      elsif percent > 50 and status[:fifty] == false
        puts '50% done...'.green
        status[:fifty] = true
      elsif percent > 60 and status[:sixty] == false
        puts '60% done...'.green
        status[:sixty] = true
      elsif percent > 70 and status[:seventy] == false
        puts '70% done...'.green
        status[:seventy] = true
      elsif percent > 80 and status[:eighty] == false
        puts '80% done...'.green
        status[:eighty] = true
      elsif percent > 90 and status[:ninty] == false
        puts '90% done...'.green
        status[:ninty] = true
      end
    end

    puts '100% done.'.green
  end

end