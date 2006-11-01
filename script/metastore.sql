-- MySQL dump 10.9
--
-- Host: 127.0.0.1    Database: metastore2
-- ------------------------------------------------------
-- Server version	4.1.18-log
-- $Id: metastore.sql,v 1.2 2006/04/17 16:15:46 zag Exp $
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES latin1 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `metadata`
--

DROP TABLE IF EXISTS `metadata`;
CREATE TABLE `metadata` (
  `mid` int(10) unsigned NOT NULL auto_increment,
  `mtype` varchar(255) NOT NULL default '',
  `mdata` text,
  PRIMARY KEY  (`mid`),
  UNIQUE KEY `mid_2` (`mid`),
  KEY `mid` (`mid`),
  KEY `mtype` (`mtype`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `metadata`
--


/*!40000 ALTER TABLE `metadata` DISABLE KEYS */;
LOCK TABLES `metadata` WRITE;
INSERT INTO `metadata` VALUES (388,'','TEST');
UNLOCK TABLES;
/*!40000 ALTER TABLE `metadata` ENABLE KEYS */;

--
-- Table structure for table `metatags`
--

DROP TABLE IF EXISTS `metatags`;
CREATE TABLE `metatags` (
  `mid` int(11) NOT NULL default '0',
  `tname` varchar(255) NOT NULL default '',
  `tval` text NOT NULL default '',
  KEY `mid` (`mid`),
  KEY `mid_2` (`mid`),
  KEY `tname` (`tname`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
CREATE INDEX tval ON metatags (tval(256));
--  KEY `tval` (`tval`)

--
-- Dumping data for table `metatags`
--


/*!40000 ALTER TABLE `metatags` DISABLE KEYS */;
LOCK TABLES `metatags` WRITE;
INSERT INTO `metatags` VALUES (388,'sess_id','2531493'),(388,'_pass','test'),(388,'_login','test'),(388,'__class','_metastore_user'),(388,'guid','52C118D2-B9E3-11DA-9AB2-AA82F23BA24A');
UNLOCK TABLES;
/*!40000 ALTER TABLE `metatags` ENABLE KEYS */;

--
-- Table structure for table `metalinks`
--

DROP TABLE IF EXISTS `metalinks`;
CREATE TABLE `metalinks` (
  `lsrc` int(11) NOT NULL default '0',
  `ldst` int(11) NOT NULL default '0',
  `lid` int(11) NOT NULL default '0',
  `lex` int(11) NOT NULL default '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

