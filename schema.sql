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
  `track_1` int(10) unsigned NOT NULL,
  `track_2` int(10) unsigned NOT NULL,
  KEY `track_1` (`track_1`),
  KEY `track_2` (`track_2`),
  CONSTRAINT `similars_ibfk_1` FOREIGN KEY (`track_1`) REFERENCES `tracks` (`id`),
  CONSTRAINT `similars_ibfk_2` FOREIGN KEY (`track_2`) REFERENCES `tracks` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;