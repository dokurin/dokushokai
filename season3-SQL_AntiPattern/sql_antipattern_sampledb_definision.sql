-- MySQL dump 10.13  Distrib 8.0.16, for osx10.14 (x86_64)
--
-- Host: 127.0.0.1    Database: sql_anti_pattern
-- ------------------------------------------------------
-- Server version	8.0.16

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8mb4 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Accounts`
--

DROP TABLE IF EXISTS `Accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `Accounts` (
  `account_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `account_name` varchar(20) DEFAULT NULL,
  `first_name` varchar(20) DEFAULT NULL,
  `last_name` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password_hash` char(64) DEFAULT NULL,
  `portrait_image` blob,
  `hourly_rate` decimal(9,2) DEFAULT NULL,
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `account_id` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `BugStatus`
--

DROP TABLE IF EXISTS `BugStatus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `BugStatus` (
  `status` varchar(20) NOT NULL,
  PRIMARY KEY (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Bugs`
--

DROP TABLE IF EXISTS `Bugs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `Bugs` (
  `bug_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `date_reported` date NOT NULL,
  `summary` varchar(80) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `resolution` varchar(1000) DEFAULT NULL,
  `reported_by` bigint(20) unsigned NOT NULL,
  `assigned_to` bigint(20) unsigned DEFAULT NULL,
  `verified_by` bigint(20) unsigned DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'NEW',
  `priority` varchar(20) DEFAULT NULL,
  `hours` decimal(9,2) DEFAULT NULL,
  PRIMARY KEY (`bug_id`),
  UNIQUE KEY `bug_id` (`bug_id`),
  KEY `reported_by` (`reported_by`),
  KEY `assigned_to` (`assigned_to`),
  KEY `verified_by` (`verified_by`),
  KEY `status` (`status`),
  CONSTRAINT `Bugs_ibfk_1` FOREIGN KEY (`reported_by`) REFERENCES `Accounts` (`account_id`),
  CONSTRAINT `Bugs_ibfk_2` FOREIGN KEY (`assigned_to`) REFERENCES `Accounts` (`account_id`),
  CONSTRAINT `Bugs_ibfk_3` FOREIGN KEY (`verified_by`) REFERENCES `Accounts` (`account_id`),
  CONSTRAINT `Bugs_ibfk_4` FOREIGN KEY (`status`) REFERENCES `BugStatus` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `BugsProducts`
--

DROP TABLE IF EXISTS `BugsProducts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `BugsProducts` (
  `bug_id` bigint(20) unsigned NOT NULL,
  `product_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`bug_id`,`product_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `BugsProducts_ibfk_1` FOREIGN KEY (`bug_id`) REFERENCES `Bugs` (`bug_id`),
  CONSTRAINT `BugsProducts_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `Products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Comments`
--

DROP TABLE IF EXISTS `Comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `Comments` (
  `comment_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `bug_id` bigint(20) unsigned NOT NULL,
  `author` bigint(20) unsigned NOT NULL,
  `comment_date` datetime NOT NULL,
  `comment` text NOT NULL,
  PRIMARY KEY (`comment_id`),
  UNIQUE KEY `comment_id` (`comment_id`),
  KEY `bug_id` (`bug_id`),
  KEY `author` (`author`),
  CONSTRAINT `Comments_ibfk_1` FOREIGN KEY (`bug_id`) REFERENCES `Bugs` (`bug_id`),
  CONSTRAINT `Comments_ibfk_2` FOREIGN KEY (`author`) REFERENCES `Accounts` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Products`
--

DROP TABLE IF EXISTS `Products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `Products` (
  `product_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `product_name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Screenshots`
--

DROP TABLE IF EXISTS `Screenshots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `Screenshots` (
  `bug_id` bigint(20) unsigned NOT NULL,
  `image_id` bigint(20) unsigned NOT NULL,
  `screenshot_image` blob,
  `caption` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`bug_id`,`image_id`),
  CONSTRAINT `Screenshots_ibfk_1` FOREIGN KEY (`bug_id`) REFERENCES `Bugs` (`bug_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Tags`
--

DROP TABLE IF EXISTS `Tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `Tags` (
  `bug_id` bigint(20) unsigned NOT NULL,
  `tag` varchar(20) NOT NULL,
  PRIMARY KEY (`bug_id`,`tag`),
  CONSTRAINT `Tags_ibfk_1` FOREIGN KEY (`bug_id`) REFERENCES `Bugs` (`bug_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-06-08 13:21:21
