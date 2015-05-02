# Artist Mapper for Last.FM dataset

This library takes the flat json files of the [Last.FM dataset](http://labrosa.ee.columbia.edu/millionsong/lastfm) and
makes them more usable by adding the information into a relational database (MySQL or MariaDB).

After compiling the files it is then possible to search Twitter for tweets about the songs that are supposed to be
related and see if we find that people are actually tweeting about the same songs or artists.

## Download

You can get the latest version of this source code from [GitHub](https://github.com/mfinelli/artist-mapper). Check out
a local copy of the files using git:

```shell
$ git clone https://github.com/mfinelli/artist-mapper.git
```

## Dependencies

The dataset can be downloaded from 
[http://labrosa.ee.columbia.edu/millionsong/lastfm#getting](http://labrosa.ee.columbia.edu/millionsong/lastfm#getting)

Project dependencies are handled with [bundler](http://bundler.io).

```shell
$ bundle install
```

Data is stored using MariaDB (or Mysql):

### Linux (e.g., Debian)

Use your package manager (e.g., apt).

```shell
$ sudo apt-get install mariadb-server mariadb-client
```

### OSX

Use e.g., [homebrew](http://brew.sh/).

```shell
$ brew install mariadb
```

## Usage

First make sure that the mysql server is running. Then start the console:

```shell
$ bundle exec ./console
```

Initialize the `ArtistMapper` class

```ruby
am = ArtistMapper.new
```

Create (or refresh) the database schema:

```ruby
am.create_schema!
```

Process the data:

```ruby
am.recurse!
```

## License

This project licensed under the [GNU Public License v3](https://www.gnu.org/licenses/gpl.html), see LICENSE for more
information.