CREATE TABLE IF NOT EXISTS `keep_containers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `random_id` varchar(50) NOT NULL,
  `owner_citizenid` varchar(50) DEFAULT NULL,
  `password` CHAR(60) DEFAULT NULL,
  `access_list` LONGTEXT DEFAULT NULL,
  `deleted` BOOLEAN NOT NULL DEFAULT TRUE,
  `deleted_by` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `random_id` (`random_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `keep_containers_access_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `random_id` varchar(50) NOT NULL,
  `citizenid` varchar(50) DEFAULT NULL,
  `action` varchar(50) DEFAULT NULL,
  `metadata` TEXT DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `random_id` (`random_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;