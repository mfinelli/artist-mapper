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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `matches`;
CREATE TABLE `matches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `similar` int(10) unsigned NOT NULL,
  `user` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `tweet_1` varchar(160) COLLATE utf8_unicode_ci NOT NULL,
  `tweet_2` varchar(160) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `similar` (`similar`),
  CONSTRAINT `tweets_ibfk_3` FOREIGN KEY (`similar`) REFERENCES `similars` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;