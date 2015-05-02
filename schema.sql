DROP DATABASE IF EXISTS `artist_mapper`;
CREATE DATABASE `artist_mapper`;
USE `artist_mapper`;

DROP TABLE IF EXISTS `artists`;
CREATE TABLE `artists` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `tracks`;
CREATE TABLE `tracks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dataset_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `artist` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `artist` (`artist`),
  CONSTRAINT `tracks_ibfk_2` FOREIGN KEY (`artist`) REFERENCES `artists` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `similars`;
CREATE TABLE `similars` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `track_1` int(10) unsigned NOT NULL,
  `track_2` int(10) unsigned NOT NULL,
  `tracks_processed` tinyint(1) unsigned DEFAULT 0,
  `artists_processed` tinyint(1) unsigned DEFAULT 0,
  `track_one_tweets` int(10) unsigned DEFAULT 0,
  `track_two_tweets_by_same_users` int(10) unsigned DEFAULT 0,
  `track_two_not_tweeted_by_same_users` int(10) unsigned DEFAULT 0,
  `track_one_artist_tweets` int(10) unsigned DEFAULT 0,
  `track_two_artist_tweets_by_same_users` int(10) unsigned DEFAULT 0,
  `track_two_artist_not_tweeted_by_same_users` int(10) unsigned DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `track_1` (`track_1`),
  KEY `track_2` (`track_2`),
  CONSTRAINT `similars_ibfk_1` FOREIGN KEY (`track_1`) REFERENCES `tracks` (`id`),
  CONSTRAINT `similars_ibfk_2` FOREIGN KEY (`track_2`) REFERENCES `tracks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `tweets`;
CREATE TABLE `tweets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `similar` int(10) unsigned NOT NULL,
  `user` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `tweet` varchar(160) COLLATE utf8_unicode_ci NOT NULL,
  `track` tinyint(1) unsigned DEFAULT 0, # 0 = artist, 1 = track 1, 2 = track 2
  `artist` tinyint(1) unsigned DEFAULT 0, # 0 = track, 1 = artist
  PRIMARY KEY (`id`),
  KEY `similar` (`similar`),
  CONSTRAINT `tweets_ibfk_1` FOREIGN KEY (`similar`) REFERENCES `similars` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;