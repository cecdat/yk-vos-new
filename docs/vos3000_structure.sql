-- MySQL dump 10.13  Distrib 8.0.20, for Linux (x86_64)
--
-- Host: localhost    Database: vos3000
-- ------------------------------------------------------
-- Server version	8.0.20

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `e_aas_alarm_word`
--

DROP TABLE IF EXISTS `e_aas_alarm_word`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_aas_alarm_word` (
  `id` int NOT NULL,
  `flowno` bigint DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `callere164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `gatewaymapping` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `gatewayrouting` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `alarmwordcategory` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `alarmword` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleraudiotext` text COLLATE utf8_bin,
  `calleeaudiotext` text COLLATE utf8_bin,
  `recordstarttime` bigint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_aas_cdr`
--

DROP TABLE IF EXISTS `e_aas_cdr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_aas_cdr` (
  `id` int NOT NULL,
  `flowno` bigint NOT NULL,
  `starttime` bigint DEFAULT NULL,
  `callere164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `gatewaymapping` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `gatewayrouting` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `alarmwordcategory` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `alarmword` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleraudiotext` text COLLATE utf8_bin,
  `calleeaudiotext` text COLLATE utf8_bin,
  `recordstarttime` bigint DEFAULT NULL,
  PRIMARY KEY (`flowno`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_activephonecard`
--

DROP TABLE IF EXISTS `e_activephonecard`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_activephonecard` (
  `id` int NOT NULL,
  `pin` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `displaye164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `activetime` bigint DEFAULT NULL,
  `bindlimit` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customer_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_alarm_current`
--

DROP TABLE IF EXISTS `e_alarm_current`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_alarm_current` (
  `id` int NOT NULL,
  `moid` int DEFAULT NULL,
  `motype` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `type` int DEFAULT NULL,
  `level` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `value` double DEFAULT NULL,
  `upper` double DEFAULT NULL,
  `lower` double DEFAULT NULL,
  `alarminfo` text COLLATE utf8_bin,
  `confirmuser` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `confirmusername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `confirmtime` bigint DEFAULT NULL,
  `confirmmemo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `emailtime` bigint DEFAULT NULL,
  `alarm_setting_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_alarm_history`
--

DROP TABLE IF EXISTS `e_alarm_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_alarm_history` (
  `id` int NOT NULL,
  `moid` int DEFAULT NULL,
  `motype` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `type` int DEFAULT NULL,
  `level` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `value` double DEFAULT NULL,
  `upper` double DEFAULT NULL,
  `lower` double DEFAULT NULL,
  `confirmuser` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `confirmusername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `confirmtime` bigint DEFAULT NULL,
  `confirmmemo` text COLLATE utf8_bin,
  `clearuser` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `clearusername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `cleartime` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`),
  KEY `type` (`type`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_alarm_setting`
--

DROP TABLE IF EXISTS `e_alarm_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_alarm_setting` (
  `id` int NOT NULL,
  `moid` int DEFAULT NULL,
  `motype` int DEFAULT NULL,
  `starttime` int DEFAULT NULL,
  `stoptime` int DEFAULT NULL,
  `type` int DEFAULT NULL,
  `level` int DEFAULT NULL,
  `upper` double DEFAULT NULL,
  `lower` double DEFAULT NULL,
  `period` int DEFAULT NULL,
  `enablevoice` int DEFAULT NULL,
  `e164s` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `enableemail` int DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_areacode`
--

DROP TABLE IF EXISTS `e_areacode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_areacode` (
  `id` int NOT NULL,
  `areacode` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `location` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `areacode` (`areacode`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_autoclean`
--

DROP TABLE IF EXISTS `e_autoclean`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_autoclean` (
  `id` int NOT NULL,
  `type` int DEFAULT NULL,
  `enabled` int DEFAULT NULL,
  `content` int DEFAULT NULL,
  `expiredays` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_axb_cdr`
--

DROP TABLE IF EXISTS `e_axb_cdr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_axb_cdr` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `anumber` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `xnumber` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `bnumber` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `xfee` double DEFAULT NULL,
  `xfeetime` int DEFAULT NULL,
  `xsuitefee` double DEFAULT NULL,
  `xsuitefeetime` int DEFAULT NULL,
  `xaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `xaccountname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `xinterface` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  PRIMARY KEY (`flowno`),
  KEY `calleegatewayid` (`calleegatewayid`),
  KEY `xnumber` (`xnumber`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `xaccount` (`xaccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_bindede164`
--

DROP TABLE IF EXISTS `e_bindede164`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_bindede164` (
  `id` int NOT NULL,
  `e164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `displaye164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rewriterulesoutcallee` text COLLATE utf8_bin,
  `bindtime` bigint DEFAULT NULL,
  `language` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `activephonecard_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `activephonecard_id` (`activephonecard_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_calendar`
--

DROP TABLE IF EXISTS `e_calendar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_calendar` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_calendar_day`
--

DROP TABLE IF EXISTS `e_calendar_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_calendar_day` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `utctime` bigint DEFAULT NULL,
  `type` int DEFAULT NULL,
  `calendar_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `calendar_id` (`calendar_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cc_seat`
--

DROP TABLE IF EXISTS `e_cc_seat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cc_seat` (
  `id` int NOT NULL,
  `e164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `level` int DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `jobid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `locktype` int DEFAULT NULL,
  `status` int DEFAULT NULL,
  `arealimit` text COLLATE utf8_bin,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `record` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ivr_id` int NOT NULL,
  `cc_seat_privilege_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ivr_id` (`ivr_id`),
  KEY `cc_seat_privilege_id` (`cc_seat_privilege_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cc_seat_group`
--

DROP TABLE IF EXISTS `e_cc_seat_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cc_seat_group` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `seatuplimit` int DEFAULT NULL,
  `record` int DEFAULT NULL,
  `schedulingtype` int DEFAULT NULL,
  `accesse164s` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `blackwhitelist` text COLLATE utf8_bin,
  `welcome` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `schedulingdelay` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ivr_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ivr_id` (`ivr_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cc_seat_privilege`
--

DROP TABLE IF EXISTS `e_cc_seat_privilege`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cc_seat_privilege` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `privilege` text COLLATE utf8_bin,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cc_seat_reserved_e164`
--

DROP TABLE IF EXISTS `e_cc_seat_reserved_e164`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cc_seat_reserved_e164` (
  `id` int NOT NULL,
  `e164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `allowother` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `cc_seat_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `e164_cc_seat_id` (`e164`,`cc_seat_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr`
--

DROP TABLE IF EXISTS `e_cdr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_citycode`
--

DROP TABLE IF EXISTS `e_citycode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_citycode` (
  `id` int NOT NULL,
  `citycode` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `province` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callere164length` int DEFAULT NULL,
  `calleee164length` int DEFAULT NULL,
  `location` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_conference_record`
--

DROP TABLE IF EXISTS `e_conference_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_conference_record` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `accesse164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `membere164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `membertype` int DEFAULT NULL,
  `jointype` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `holdtime` bigint DEFAULT NULL,
  `codec` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callid` int DEFAULT NULL,
  `ivrname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `sub_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_conferencemember`
--

DROP TABLE IF EXISTS `e_conferencemember`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_conferencemember` (
  `id` int NOT NULL,
  `e164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `type` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `conferenceroom_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `conferenceroom_id` (`conferenceroom_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_conferenceroom`
--

DROP TABLE IF EXISTS `e_conferenceroom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_conferenceroom` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customerpassword` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `record` int DEFAULT NULL,
  `blackwhitelist` text COLLATE utf8_bin,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customer_id` int NOT NULL,
  `ivrservice_id` int NOT NULL,
  `ivr_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `ivrservice_id` (`ivrservice_id`),
  KEY `ivr_id` (`ivr_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_consumption`
--

DROP TABLE IF EXISTS `e_consumption`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_consumption` (
  `id` int NOT NULL,
  `account` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `accountname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `money` double DEFAULT NULL,
  `remainmoney` double DEFAULT NULL,
  `time` bigint DEFAULT NULL,
  `type` int DEFAULT NULL,
  `comsumptionname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `account` (`account`),
  KEY `time` (`time`),
  KEY `agentaccount` (`agentaccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_currentgifttime`
--

DROP TABLE IF EXISTS `e_currentgifttime`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_currentgifttime` (
  `id` int NOT NULL,
  `prefix` text COLLATE utf8_bin,
  `starttime` int DEFAULT NULL,
  `endtime` int DEFAULT NULL,
  `gifttime` int DEFAULT NULL,
  `billingtime` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `currentsuite_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `currentsuite_id` (`currentsuite_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_currentsuite`
--

DROP TABLE IF EXISTS `e_currentsuite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_currentsuite` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rentperiod` int DEFAULT NULL,
  `renttype` int DEFAULT NULL,
  `availabletime` bigint DEFAULT NULL,
  `currentconsumption` double DEFAULT NULL,
  `minconsumption` double DEFAULT NULL,
  `lowerconsumption` double DEFAULT NULL,
  `expiretime` bigint DEFAULT NULL,
  `giftmoney` double DEFAULT NULL,
  `suiteoderid` int DEFAULT NULL,
  `suiteid` int DEFAULT NULL,
  `customer_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_customer`
--

DROP TABLE IF EXISTS `e_customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_customer` (
  `id` int NOT NULL,
  `account` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `type` int DEFAULT NULL,
  `bitsofconfig` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `lastupdatetime` bigint DEFAULT NULL,
  `money` double DEFAULT NULL,
  `validtime` bigint DEFAULT NULL,
  `locktype` int DEFAULT NULL,
  `status` int DEFAULT NULL,
  `limitmoney` double DEFAULT NULL,
  `todayconsumption` double DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `phonebookserialid` int DEFAULT NULL,
  `phonebooklimit` int DEFAULT NULL,
  `ctdbillingtype` int DEFAULT NULL,
  `timezoneid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `alarmemail` text COLLATE utf8_bin,
  `workday` tinyint(1) DEFAULT NULL,
  `feetimeaverage` bigint DEFAULT NULL,
  `feetimeaveragenonwork` bigint DEFAULT NULL,
  `feetimedays` int DEFAULT NULL,
  `feetimedaysnonwork` int DEFAULT NULL,
  `feetimetoday` bigint DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `feerategroup_id` int NOT NULL,
  `feerategroupprivate_id` int NOT NULL,
  `calendar_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `feerategroup_id` (`feerategroup_id`),
  KEY `feerategroupprivate_id` (`feerategroupprivate_id`),
  KEY `calendar_id` (`calendar_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_customerdetail`
--

DROP TABLE IF EXISTS `e_customerdetail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_customerdetail` (
  `address` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `linkman` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `emailcc` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `emailbcc` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `reporttype` int DEFAULT NULL,
  `nextreporttime` bigint DEFAULT NULL,
  `postcode` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `fax` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `idtype` int DEFAULT NULL,
  `idnumber` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `bankaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `companyname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customer_id` int NOT NULL,
  PRIMARY KEY (`customer_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_dns`
--

DROP TABLE IF EXISTS `e_dns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_dns` (
  `id` int NOT NULL,
  `domain` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `type` int DEFAULT NULL,
  `updatetime` bigint DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_equipment`
--

DROP TABLE IF EXISTS `e_equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_equipment` (
  `id` int NOT NULL,
  `catagory` int DEFAULT NULL,
  `type` int DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `vosname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `configserialid` int DEFAULT NULL,
  `createtime` bigint DEFAULT NULL,
  `accesstime` bigint DEFAULT NULL,
  `accessip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `localconfig` mediumtext COLLATE utf8_bin,
  `socketid` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_feerate`
--

DROP TABLE IF EXISTS `e_feerate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_feerate` (
  `id` int NOT NULL,
  `feeprefix` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `areacode` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `locktype` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `period` int DEFAULT NULL,
  `ivrfee` double DEFAULT NULL,
  `ivrperiod` int DEFAULT NULL,
  `type` int DEFAULT NULL,
  `feerategroup_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `feerategroup_id` (`feerategroup_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_feerate_update`
--

DROP TABLE IF EXISTS `e_feerate_update`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_feerate_update` (
  `id` int NOT NULL,
  `feeprefix` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `areacode` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `locktype` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `period` int DEFAULT NULL,
  `ivrfee` double DEFAULT NULL,
  `ivrperiod` int DEFAULT NULL,
  `type` int DEFAULT NULL,
  `udpatetime` bigint DEFAULT NULL,
  `updatetype` int DEFAULT NULL,
  `feerategroup_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `feerategroup_id` (`feerategroup_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_feeratebytime`
--

DROP TABLE IF EXISTS `e_feeratebytime`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_feeratebytime` (
  `id` int NOT NULL,
  `type` int DEFAULT NULL,
  `startday` bigint DEFAULT NULL,
  `endday` bigint DEFAULT NULL,
  `starttime` int DEFAULT NULL,
  `endtime` int DEFAULT NULL,
  `suite_id` int NOT NULL,
  `feerategroup_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `suite_id` (`suite_id`),
  KEY `feerategroup_id` (`feerategroup_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_feerategroup`
--

DROP TABLE IF EXISTS `e_feerategroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_feerategroup` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `privilege` int DEFAULT NULL,
  `fakeminute` int DEFAULT NULL,
  `isprivate` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_feeratesection`
--

DROP TABLE IF EXISTS `e_feeratesection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_feeratesection` (
  `fee` double DEFAULT NULL,
  `time` int DEFAULT NULL,
  `position` int DEFAULT NULL,
  `feerate_id` int DEFAULT NULL,
  KEY `feerate_id` (`feerate_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_feeratesection_update`
--

DROP TABLE IF EXISTS `e_feeratesection_update`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_feeratesection_update` (
  `fee` double DEFAULT NULL,
  `time` int DEFAULT NULL,
  `position` int DEFAULT NULL,
  `feerate_update_id` int DEFAULT NULL,
  KEY `feerate_update_id` (`feerate_update_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_gatewaygroup`
--

DROP TABLE IF EXISTS `e_gatewaygroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_gatewaygroup` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_gatewaymapping`
--

DROP TABLE IF EXISTS `e_gatewaymapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_gatewaymapping` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customerpassword` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `locktype` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `registertype` int DEFAULT NULL,
  `remoteips` text COLLATE utf8_bin,
  `rtpforwardtype` int DEFAULT NULL,
  `gatewaygroups` text COLLATE utf8_bin,
  `routinggatewaygroups` text COLLATE utf8_bin,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customer_id` int NOT NULL,
  `mbx_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `mbx_id` (`mbx_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_gatewaymappingsetting`
--

DROP TABLE IF EXISTS `e_gatewaymappingsetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_gatewaymappingsetting` (
  `callercitye164check` int DEFAULT NULL,
  `calleecitye164check` int DEFAULT NULL,
  `calloutcallerprefixesallow` tinyint(1) DEFAULT NULL,
  `calloutcallerprefixes` text COLLATE utf8_bin,
  `calloutcalleeprefixesallow` tinyint(1) DEFAULT NULL,
  `calloutcalleeprefixes` text COLLATE utf8_bin,
  `rewriterulesoutcallee` text COLLATE utf8_bin,
  `rewriterulesoutcaller` text COLLATE utf8_bin,
  `rewriterulesinmobilearea` text COLLATE utf8_bin,
  `scheduledcalloutprefixes` text COLLATE utf8_bin,
  `scheduledrewriterulesout` text COLLATE utf8_bin,
  `scheduledcapacity` text COLLATE utf8_bin,
  `timeoutcallproceeding` int DEFAULT NULL,
  `dtmfreceivemethod` int DEFAULT NULL,
  `dtmfsendmethodh323` int DEFAULT NULL,
  `dtmfsendmethodsip` int DEFAULT NULL,
  `dtmfreceivepayloadtype` int DEFAULT NULL,
  `dtmfsendpayloadtypeh323` int DEFAULT NULL,
  `dtmfsendpayloadtypesip` int DEFAULT NULL,
  `q931progressindicator` int DEFAULT NULL,
  `callfailedsipcode` text COLLATE utf8_bin,
  `callfailedq931causevalue` text COLLATE utf8_bin,
  `sipresponseaddressmethod` int DEFAULT NULL,
  `siprequestaddressmethod` int DEFAULT NULL,
  `sipremoteringsignal` int DEFAULT NULL,
  `sipcalleee164domain` int DEFAULT NULL,
  `sipcallere164domain` int DEFAULT NULL,
  `h323calleee164domain` int DEFAULT NULL,
  `h323callere164domain` int DEFAULT NULL,
  `allowphonebilling` int DEFAULT NULL,
  `allowbindede164billing` int DEFAULT NULL,
  `enablephonesetting` int DEFAULT NULL,
  `sipauthenticationmethod` int DEFAULT NULL,
  `sipauthenticationuser` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calltransferbillingmode` int DEFAULT NULL,
  `bitsofh323config` int DEFAULT NULL,
  `bitsofsipconfig` int DEFAULT NULL,
  `bitsofconfig` bigint DEFAULT NULL,
  `callerallowlength` int DEFAULT NULL,
  `calleeallowlength` int DEFAULT NULL,
  `callerlimite164groups` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleelimite164groups` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `minprofitpercent` int DEFAULT NULL,
  `firstroutepolicy` int DEFAULT NULL,
  `secondroutepolicy` int DEFAULT NULL,
  `h323g729sendmode` int DEFAULT NULL,
  `sipg729sendmode` int DEFAULT NULL,
  `sipg729annexb` int DEFAULT NULL,
  `sipg723annexa` int DEFAULT NULL,
  `mediacheckdirection` int DEFAULT NULL,
  `calleee164restrict` int DEFAULT NULL,
  `maxcalldurationlower` int DEFAULT NULL,
  `maxcalldurationupper` int DEFAULT NULL,
  `timeoutcallredirect` int DEFAULT NULL,
  `maxcallrate` int DEFAULT NULL,
  `maxcallrateunit` int DEFAULT NULL,
  `timeoutredirecte164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `h323codecs` text COLLATE utf8_bin,
  `sipcodecs` text COLLATE utf8_bin,
  `calculatequality` int DEFAULT NULL,
  `denysamecitycodes` text COLLATE utf8_bin,
  `checkmobilearea` text COLLATE utf8_bin,
  `externalrewritetype` int DEFAULT NULL,
  `externalrewritetrigger` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `sipremotepartyidscreen` int DEFAULT NULL,
  `sipe164displayfrom` int DEFAULT NULL,
  `sipextraheader` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `tryprotectroutedelay` int DEFAULT NULL,
  `forwardsignalrewritee164group` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `maxsecondrates` double DEFAULT NULL,
  `lrneatprefixlength` int DEFAULT NULL,
  `lrnfailureaction` int DEFAULT NULL,
  `lrninterstatebillingprefix` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `lrnundeterminedbillingprefix` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calloutroutinggateways` text COLLATE utf8_bin,
  `traceendtime` bigint DEFAULT NULL,
  `aassampling` double DEFAULT NULL,
  `aaswordcategory` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `language` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rewriteprefixaddoutcallee` text COLLATE utf8_bin,
  `callerblacklistpolicy` int DEFAULT NULL,
  `calleeblacklistpolicy` int DEFAULT NULL,
  `externalNumberVerifyBits` bigint DEFAULT NULL,
  `externalNumberVerfiyRewriteCaller` text COLLATE utf8_bin,
  `externalNumberVerfiyRewriteCallee` text COLLATE utf8_bin,
  `gatewaymapping_id` int NOT NULL,
  PRIMARY KEY (`gatewaymapping_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_gatewayrouting`
--

DROP TABLE IF EXISTS `e_gatewayrouting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_gatewayrouting` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `prefix` text COLLATE utf8_bin,
  `prefixstyle` int DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customerpassword` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `locktype` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `iptype` int DEFAULT NULL,
  `encrypt` int DEFAULT NULL,
  `protocol` int DEFAULT NULL,
  `remoteips` text COLLATE utf8_bin,
  `rtpforwardtype` int DEFAULT NULL,
  `signalport` int DEFAULT NULL,
  `signalportlocal` int DEFAULT NULL,
  `gatewaygroups` text COLLATE utf8_bin,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `mbx_id` int NOT NULL,
  `clearingcustomer_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `mbx_id` (`mbx_id`),
  KEY `clearingcustomer_id` (`clearingcustomer_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_gatewayroutingsetting`
--

DROP TABLE IF EXISTS `e_gatewayroutingsetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_gatewayroutingsetting` (
  `callercitye164check` int DEFAULT NULL,
  `calleecitye164check` int DEFAULT NULL,
  `denycallercallee` text COLLATE utf8_bin,
  `denysamecitycodes` text COLLATE utf8_bin,
  `checkmobilearea` text COLLATE utf8_bin,
  `callincallerprefixesallow` tinyint(1) DEFAULT NULL,
  `callincallerprefixes` text COLLATE utf8_bin,
  `callincalleeprefixesallow` tinyint(1) DEFAULT NULL,
  `callincalleeprefixes` text COLLATE utf8_bin,
  `callinforwardprefixes` text COLLATE utf8_bin,
  `rewriterulesincallee` text COLLATE utf8_bin,
  `rewriterulesinmobilearea` text COLLATE utf8_bin,
  `rewriterulesincaller` text COLLATE utf8_bin,
  `rewriterulesincallerusee164group` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rewriterulesincallerusee164line` int DEFAULT NULL,
  `rewriterulespidentity` text COLLATE utf8_bin,
  `scheduledcallinprefixes` text COLLATE utf8_bin,
  `scheduledrewriterulesin` text COLLATE utf8_bin,
  `scheduledcapacity` text COLLATE utf8_bin,
  `scheduledpriority` text COLLATE utf8_bin,
  `timeoutsetup` int DEFAULT NULL,
  `timeoutcallproceeding` int DEFAULT NULL,
  `timeoutcallproceedingolc` int DEFAULT NULL,
  `timeoutalerting` int DEFAULT NULL,
  `timeoutinvite` int DEFAULT NULL,
  `timeouttrying` int DEFAULT NULL,
  `timeoutsessionprogresssdp` int DEFAULT NULL,
  `timeoutsessionprogress` int DEFAULT NULL,
  `timeoutringing` int DEFAULT NULL,
  `stopswitchafterolc` int DEFAULT NULL,
  `stopswitchaftersdp` int DEFAULT NULL,
  `clearingaccountusecalloute164` int DEFAULT NULL,
  `q931presentationindicator` int DEFAULT NULL,
  `q931screeningindicator` int DEFAULT NULL,
  `dtmfreceivemethod` int DEFAULT NULL,
  `dtmfsendmethodh323` int DEFAULT NULL,
  `dtmfsendmethodsip` int DEFAULT NULL,
  `dtmfreceivepayloadtype` int DEFAULT NULL,
  `dtmfsendpayloadtypeh323` int DEFAULT NULL,
  `dtmfsendpayloadtypesip` int DEFAULT NULL,
  `q931numberingplan` int DEFAULT NULL,
  `q931numbertype` int DEFAULT NULL,
  `sipresponseaddressmethod` int DEFAULT NULL,
  `siprequestaddressmethod` int DEFAULT NULL,
  `stopswitchafterrtpstart` int DEFAULT NULL,
  `stopswitchafteruserbusy` int DEFAULT NULL,
  `bitsofh323config` int DEFAULT NULL,
  `bitsofsipconfig` int DEFAULT NULL,
  `bitsofconfig` bigint DEFAULT NULL,
  `callerallowlength` int DEFAULT NULL,
  `calleeallowlength` int DEFAULT NULL,
  `callerlimite164groups` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleelimite164groups` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `localip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `h323codecs` text COLLATE utf8_bin,
  `sipcodecs` text COLLATE utf8_bin,
  `calculatequality` int DEFAULT NULL,
  `minprofitpercent` int DEFAULT NULL,
  `maxsecondrates` double DEFAULT NULL,
  `feeraterestrict` int DEFAULT NULL,
  `leastcostrouting` int DEFAULT NULL,
  `h323g729sendmode` int DEFAULT NULL,
  `sipg729sendmode` int DEFAULT NULL,
  `sipg729annexb` int DEFAULT NULL,
  `sipg723annexa` int DEFAULT NULL,
  `mediacheckdirection` int DEFAULT NULL,
  `enablecalltransfer` int DEFAULT NULL,
  `maxcalldurationlower` int DEFAULT NULL,
  `maxcalldurationupper` int DEFAULT NULL,
  `calleee164restrict` int DEFAULT NULL,
  `enablephonedisplay` int DEFAULT NULL,
  `switchuntilconnect` int DEFAULT NULL,
  `maxcallrate` int DEFAULT NULL,
  `maxcallrateunit` int DEFAULT NULL,
  `sipremotepartyidscreen` int DEFAULT NULL,
  `sipe164displaytype` int DEFAULT NULL,
  `sipprivacytype` int DEFAULT NULL,
  `sipppreferredidentitytype` int DEFAULT NULL,
  `sippassertedidentitytype` int DEFAULT NULL,
  `sipinvitecode` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `sipauthenticationuser` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `sipextraheader` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `forwardsignalrewritee164group` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callinmappinggateways` text COLLATE utf8_bin,
  `traceendtime` bigint DEFAULT NULL,
  `aassampling` double DEFAULT NULL,
  `aaswordcategory` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `stopswitchsipcodes` text COLLATE utf8_bin,
  `callerblacklistpolicy` int DEFAULT NULL,
  `calleeblacklistpolicy` int DEFAULT NULL,
  `axbagroup` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `axbinterface` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `axbbrewriterules` text COLLATE utf8_bin,
  `axbaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `externalNumberVerifyBits` bigint DEFAULT NULL,
  `externalNumberVerfiyRewriteCaller` text COLLATE utf8_bin,
  `externalNumberVerfiyRewriteCallee` text COLLATE utf8_bin,
  `gatewayrouting_id` int NOT NULL,
  PRIMARY KEY (`gatewayrouting_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_gifttime`
--

DROP TABLE IF EXISTS `e_gifttime`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_gifttime` (
  `id` int NOT NULL,
  `prefix` text COLLATE utf8_bin,
  `starttime` int DEFAULT NULL,
  `endtime` int DEFAULT NULL,
  `gifttime` int DEFAULT NULL,
  `billingtime` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `suite_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `suite_id` (`suite_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_groupe164`
--

DROP TABLE IF EXISTS `e_groupe164`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_groupe164` (
  `id` int NOT NULL,
  `routinggatewaycalleee164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `phonee164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `mappinggatewaycallere164` text COLLATE utf8_bin,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_ims_edge_account`
--

DROP TABLE IF EXISTS `e_ims_edge_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_ims_edge_account` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `authenticationName` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `rewriteRulesOutCallee` text COLLATE utf8_bin,
  `rewriteRulesOutCaller` text COLLATE utf8_bin,
  `rewriteRulesInCallee` text COLLATE utf8_bin,
  `rewriteRulesInCaller` text COLLATE utf8_bin,
  `lockType` int DEFAULT NULL,
  `bitsOfConfig` int DEFAULT NULL,
  `durationDailyLimit` int DEFAULT NULL,
  `durationMonthlyLimit` int DEFAULT NULL,
  `durationBillingUnit` int DEFAULT NULL,
  `maxCallRate` int DEFAULT NULL,
  `maxCallRateUnit` int DEFAULT NULL,
  `durationDailyUsed` int DEFAULT NULL,
  `durationMonthlyUsed` int DEFAULT NULL,
  `lastCallTime` bigint DEFAULT NULL,
  `callTodaySeconds` int DEFAULT NULL,
  `callTodayAttempt` int DEFAULT NULL,
  `callTodaySuccess` int DEFAULT NULL,
  `callTodayLastError` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ims_edge_server_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ims_edge_server_id` (`ims_edge_server_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_ims_edge_server`
--

DROP TABLE IF EXISTS `e_ims_edge_server`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_ims_edge_server` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `serverIp` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `serverPort` int DEFAULT NULL,
  `expire` int DEFAULT NULL,
  `localIp` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `hostName` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `sipProxy` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `sipUserAgent` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `localPort` int DEFAULT NULL,
  `rtpForwardType` int DEFAULT NULL,
  `gatewayMapping` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `gatewayRouting` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `locktype` int DEFAULT NULL,
  `bitsOfConfig` int DEFAULT NULL,
  `stopSwitchSipCodes` text COLLATE utf8_bin,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `equipment_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `equipment_id` (`equipment_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_interfaceagent`
--

DROP TABLE IF EXISTS `e_interfaceagent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_interfaceagent` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `vosname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `type` int DEFAULT NULL,
  `configserialid` int DEFAULT NULL,
  `createtime` bigint DEFAULT NULL,
  `accesstime` bigint DEFAULT NULL,
  `accessip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `socketid` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_ip_limit`
--

DROP TABLE IF EXISTS `e_ip_limit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_ip_limit` (
  `id` int NOT NULL,
  `area` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ip` varchar(255) COLLATE utf8_bin NOT NULL,
  `count` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`ip`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_ivr`
--

DROP TABLE IF EXISTS `e_ivr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_ivr` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `vosname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `type` int DEFAULT NULL,
  `configserialid` int DEFAULT NULL,
  `createtime` bigint DEFAULT NULL,
  `accesstime` bigint DEFAULT NULL,
  `accessip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `localconfig` mediumtext COLLATE utf8_bin,
  `socketid` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_ivr_cdr`
--

DROP TABLE IF EXISTS `e_ivr_cdr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_ivr_cdr` (
  `id` int NOT NULL,
  `caller` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callee` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `service` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `dtmf` text COLLATE utf8_bin,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `sipcallid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `equipment` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  PRIMARY KEY (`flowno`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_ivraudio`
--

DROP TABLE IF EXISTS `e_ivraudio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_ivraudio` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `language` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `size` int DEFAULT NULL,
  `type` int DEFAULT NULL,
  `dataserialid` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ivrservice_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ivrservice_id` (`ivrservice_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_ivraudiodata`
--

DROP TABLE IF EXISTS `e_ivraudiodata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_ivraudiodata` (
  `id` int NOT NULL,
  `data` longblob,
  `ivraudio_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ivraudio_id` (`ivraudio_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_ivrservice`
--

DROP TABLE IF EXISTS `e_ivrservice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_ivrservice` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `type` int DEFAULT NULL,
  `calloutdisplaye164` int DEFAULT NULL,
  `callquickdisplaye164` int DEFAULT NULL,
  `calloutcalleerewriterules` text COLLATE utf8_bin,
  `firstaudiodelay` int DEFAULT NULL,
  `alertingtime` int DEFAULT NULL,
  `afteralertingaction` int DEFAULT NULL,
  `callbackdelay` int DEFAULT NULL,
  `callbackretry` int DEFAULT NULL,
  `callbackretryinterval` int DEFAULT NULL,
  `callbackreplace` int DEFAULT NULL,
  `callbacksametime` int DEFAULT NULL,
  `callbackendreason` int DEFAULT NULL,
  `callbackcalleerewriterules` text COLLATE utf8_bin,
  `bitsofconfig` int DEFAULT NULL,
  `recordcallergroups` text COLLATE utf8_bin,
  `recordcalleegroups` text COLLATE utf8_bin,
  `language` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ivr_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ivr_id` (`ivr_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_ivrservicemenu`
--

DROP TABLE IF EXISTS `e_ivrservicemenu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_ivrservicemenu` (
  `id` int NOT NULL,
  `flowindex` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `identification` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `audioes` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `acceptkeyes` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `acceptkeylength` int DEFAULT NULL,
  `interruptkeyes` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ani` int DEFAULT NULL,
  `acceptkeytimeout` int DEFAULT NULL,
  `recordkey` int DEFAULT NULL,
  `recordkeyname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `recordrtptime` int DEFAULT NULL,
  `precleandtmf` int DEFAULT NULL,
  `postcleandtmf` int DEFAULT NULL,
  `action` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `actionparameter` text COLLATE utf8_bin,
  `timeout` int DEFAULT NULL,
  `timeoutaction` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `timeoutactionparameter` text COLLATE utf8_bin,
  `timeoutlimit` int DEFAULT NULL,
  `timeoutlimitaction` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `timeoutlimitactionparameter` text COLLATE utf8_bin,
  `ivrservice_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ivrservice_id` (`ivrservice_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_language`
--

DROP TABLE IF EXISTS `e_language`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_language` (
  `id` int NOT NULL,
  `directory` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_lerg`
--

DROP TABLE IF EXISTS `e_lerg`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_lerg` (
  `id` int NOT NULL,
  `state` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `npanxx` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ocn` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `company` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ratecenter` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `effectivedate` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `used` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `assigndate` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `initialorgrowth` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `pooledcodefileudpated` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `npanxx` (`npanxx`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_limit_e164`
--

DROP TABLE IF EXISTS `e_limit_e164`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_limit_e164` (
  `id` int NOT NULL,
  `e164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `limit_e164_group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `e164` (`e164`,`limit_e164_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_limit_e164_group`
--

DROP TABLE IF EXISTS `e_limit_e164_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_limit_e164_group` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_mbx`
--

DROP TABLE IF EXISTS `e_mbx`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_mbx` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `vosname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `configserialid` int DEFAULT NULL,
  `createtime` bigint DEFAULT NULL,
  `accesstime` bigint DEFAULT NULL,
  `accessip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `localconfig` mediumtext COLLATE utf8_bin,
  `socketid` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_mobilearea`
--

DROP TABLE IF EXISTS `e_mobilearea`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_mobilearea` (
  `id` int NOT NULL,
  `mobileprefix` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `areacode` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mobileprefix` (`mobileprefix`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_moconfig`
--

DROP TABLE IF EXISTS `e_moconfig`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_moconfig` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `value` text COLLATE utf8_bin,
  `editable` int DEFAULT NULL,
  `moid` int DEFAULT NULL,
  `motype` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_moexternal`
--

DROP TABLE IF EXISTS `e_moexternal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_moexternal` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `type` int DEFAULT NULL,
  `equipmentid` int DEFAULT NULL,
  `equipmentcategory` int DEFAULT NULL,
  `openbits` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_motimer`
--

DROP TABLE IF EXISTS `e_motimer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_motimer` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `nexttime` bigint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_othermaxid`
--

DROP TABLE IF EXISTS `e_othermaxid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_othermaxid` (
  `id` int NOT NULL,
  `type` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `maxid` bigint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_payhistory`
--

DROP TABLE IF EXISTS `e_payhistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_payhistory` (
  `id` int NOT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `paymoney` double DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `time` bigint DEFAULT NULL,
  `customermoney` double DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `paytype` int DEFAULT NULL,
  `type` int DEFAULT NULL,
  `loginname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customeraccount` (`customeraccount`),
  KEY `time` (`time`),
  KEY `agentaccount` (`agentaccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_phone`
--

DROP TABLE IF EXISTS `e_phone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_phone` (
  `id` int NOT NULL,
  `e164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customerpassword` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `displaynum` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `locktype` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `calleebilling` int DEFAULT NULL,
  `routinggatewaygroups` text COLLATE utf8_bin,
  `monthlymoneymax` double DEFAULT NULL,
  `monthconsumption` double DEFAULT NULL,
  `monthlymoneymin` double DEFAULT NULL,
  `monthlyrentfee` double DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `phonebookserialid` int DEFAULT NULL,
  `phonebooklimit` int DEFAULT NULL,
  `linecallin` int DEFAULT NULL,
  `linecallout` int DEFAULT NULL,
  `customer_id` int NOT NULL,
  `ivrservice_id` int NOT NULL,
  `feerategroup_id` int NOT NULL,
  `mbx_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `ivrservice_id` (`ivrservice_id`),
  KEY `feerategroup_id` (`feerategroup_id`),
  KEY `mbx_id` (`mbx_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_phonecard`
--

DROP TABLE IF EXISTS `e_phonecard`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_phonecard` (
  `id` int NOT NULL,
  `serialno` bigint DEFAULT NULL,
  `pin` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `displaye164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `maintainno` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `bitsofconfig` int DEFAULT NULL,
  `money` double DEFAULT NULL,
  `limitmoney` double DEFAULT NULL,
  `bindlimit` int DEFAULT NULL,
  `locktype` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `expiretime` bigint DEFAULT NULL,
  `activeday` int DEFAULT NULL,
  `sold` int DEFAULT NULL,
  `usedtime` bigint DEFAULT NULL,
  `usedaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `usedaccountname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `producetime` bigint DEFAULT NULL,
  `feerategroup_id` int DEFAULT NULL,
  `suitename` text COLLATE utf8_bin,
  PRIMARY KEY (`id`),
  UNIQUE KEY `serialno` (`serialno`),
  UNIQUE KEY `pin` (`pin`),
  KEY `usedaccount` (`usedaccount`),
  KEY `agentaccount` (`agentaccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_phoneservice`
--

DROP TABLE IF EXISTS `e_phoneservice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_phoneservice` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `vosname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `configserialid` int DEFAULT NULL,
  `createtime` bigint DEFAULT NULL,
  `accesstime` bigint DEFAULT NULL,
  `accessip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `socketid` int DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_phonesetting`
--

DROP TABLE IF EXISTS `e_phonesetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_phonesetting` (
  `registertype` int DEFAULT NULL,
  `encrypt` int DEFAULT NULL,
  `protocol` int DEFAULT NULL,
  `ipaddress` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `localip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `signalport` int DEFAULT NULL,
  `signalportlocal` int DEFAULT NULL,
  `rtpforwardtype` int DEFAULT NULL,
  `bitsofopen` int DEFAULT NULL,
  `usecallerphonedisplay` int DEFAULT NULL,
  `callforwardalwaysnum` text COLLATE utf8_bin,
  `callforwardbusynum` text COLLATE utf8_bin,
  `callforwardnoanswernum` text COLLATE utf8_bin,
  `callforwardtimebasedalwaysnum` text COLLATE utf8_bin,
  `callforwardofflinenum` text COLLATE utf8_bin,
  `sipresponseaddressmethod` int DEFAULT NULL,
  `siprequestaddressmethod` int DEFAULT NULL,
  `sipremoteringsignal` int DEFAULT NULL,
  `dtmfreceivemethod` int DEFAULT NULL,
  `dtmfsendmethodh323` int DEFAULT NULL,
  `dtmfsendmethodsip` int DEFAULT NULL,
  `dtmfreceivepayloadtype` int DEFAULT NULL,
  `dtmfsendpayloadtypeh323` int DEFAULT NULL,
  `dtmfsendpayloadtypesip` int DEFAULT NULL,
  `enableivre164setting` int DEFAULT NULL,
  `localalertingsound` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `remotealertingpassthrough` int DEFAULT NULL,
  `sipauthenticationmethod` int DEFAULT NULL,
  `calltransferbillingmode` int DEFAULT NULL,
  `bitsofh323config` int DEFAULT NULL,
  `bitsofsipconfig` int DEFAULT NULL,
  `bitsofconfig` bigint DEFAULT NULL,
  `redirecttogatewayoffline` int DEFAULT NULL,
  `groupe164change` int DEFAULT NULL,
  `h323codecs` text COLLATE utf8_bin,
  `sipcodecs` text COLLATE utf8_bin,
  `minprofitpercent` int DEFAULT NULL,
  `firstroutepolicy` int DEFAULT NULL,
  `secondroutepolicy` int DEFAULT NULL,
  `h323g729sendmode` int DEFAULT NULL,
  `sipg729sendmode` int DEFAULT NULL,
  `sipg729annexb` int DEFAULT NULL,
  `sipg723annexa` int DEFAULT NULL,
  `mediacheckdirection` int DEFAULT NULL,
  `indicationcallfailed` int DEFAULT NULL,
  `indicationcallremaintime` int DEFAULT NULL,
  `callforwardcaller` int DEFAULT NULL,
  `accountindicationmethod` int DEFAULT NULL,
  `calleee164restrict` int DEFAULT NULL,
  `maxcalldurationlower` int DEFAULT NULL,
  `maxcalldurationupper` int DEFAULT NULL,
  `displaycallinshorte164` int DEFAULT NULL,
  `scheduledcalloutprefixes` text COLLATE utf8_bin,
  `scheduledrewriterulesout` text COLLATE utf8_bin,
  `scheduledcapacity` text COLLATE utf8_bin,
  `voicemailcheckpassword` int DEFAULT NULL,
  `voicemailmaxnumber` int DEFAULT NULL,
  `voicemailexpireday` int DEFAULT NULL,
  `voicemailaudiotype` int DEFAULT NULL,
  `ivraccessverifymode` int DEFAULT NULL,
  `ivrcallbackbillingmode` int DEFAULT NULL,
  `ivrcallbackbillingchangemode` int DEFAULT NULL,
  `ivrcallbackmergebillingmode` int DEFAULT NULL,
  `ivrdirectmergebillingmode` int DEFAULT NULL,
  `ivrsecondbillingmode` int DEFAULT NULL,
  `callerlimite164groups` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleelimite164groups` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callercitye164check` int DEFAULT NULL,
  `calleecitye164check` int DEFAULT NULL,
  `rewriterulesinmobilearea` text COLLATE utf8_bin,
  `checkmobilearea` text COLLATE utf8_bin,
  `callincallerprefixes` text COLLATE utf8_bin,
  `calloutcalleeprefixes` text COLLATE utf8_bin,
  `externalrewritetype` int DEFAULT NULL,
  `externalrewritetrigger` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `sipremotepartyidscreen` int DEFAULT NULL,
  `sipe164displayfrom` int DEFAULT NULL,
  `sipe164displaytype` int DEFAULT NULL,
  `sipprivacytype` int DEFAULT NULL,
  `sipppreferredidentitytype` int DEFAULT NULL,
  `sippassertedidentitytype` int DEFAULT NULL,
  `sipextraheader` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `nobillingtophone` int DEFAULT NULL,
  `rewriterulesoutcallee` text COLLATE utf8_bin,
  `rewriterulesincallee` text COLLATE utf8_bin,
  `rewriterulesincaller` text COLLATE utf8_bin,
  `dids` text COLLATE utf8_bin,
  `maxsecondrates` double DEFAULT NULL,
  `lrneatprefixlength` int DEFAULT NULL,
  `lrnfailureaction` int DEFAULT NULL,
  `lrninterstatebillingprefix` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `lrnundeterminedbillingprefix` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calltransfernormaldisplay` int DEFAULT NULL,
  `calltransferaskdisplay` int DEFAULT NULL,
  `traceendtime` bigint DEFAULT NULL,
  `aassampling` double DEFAULT NULL,
  `aaswordcategory` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `language` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callerblacklistpolicy` int DEFAULT NULL,
  `calleeblacklistpolicy` int DEFAULT NULL,
  `phone_id` int NOT NULL,
  PRIMARY KEY (`phone_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_privatephonebook`
--

DROP TABLE IF EXISTS `e_privatephonebook`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_privatephonebook` (
  `id` int NOT NULL,
  `shorte164s` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `e164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `department` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `devicetype` int DEFAULT NULL,
  `addresstype` int DEFAULT NULL,
  `type` int DEFAULT NULL,
  `lastupdatetime` bigint DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `phone_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `phone_id` (`phone_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_publicphonebook`
--

DROP TABLE IF EXISTS `e_publicphonebook`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_publicphonebook` (
  `id` int NOT NULL,
  `shorte164s` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `e164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `department` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `devicetype` int DEFAULT NULL,
  `addresstype` int DEFAULT NULL,
  `type` int DEFAULT NULL,
  `lastupdatetime` bigint DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customer_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportagentincome`
--

DROP TABLE IF EXISTS `e_reportagentincome`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportagentincome` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `count` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customertimezoneid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `customeraccount` (`customeraccount`),
  KEY `agentaccount` (`agentaccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportaxbaccountfee`
--

DROP TABLE IF EXISTS `e_reportaxbaccountfee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportaxbaccountfee` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `count` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `account` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `accountname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customertimezoneid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `account` (`account`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportcustomerclearingfee`
--

DROP TABLE IF EXISTS `e_reportcustomerclearingfee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportcustomerclearingfee` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `count` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customertimezoneid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportcustomerclearingio`
--

DROP TABLE IF EXISTS `e_reportcustomerclearingio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportcustomerclearingio` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `count` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `feeaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `feeaccountname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customertimezoneid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `feeaccount` (`feeaccount`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportcustomerclearinglocationfee`
--

DROP TABLE IF EXISTS `e_reportcustomerclearinglocationfee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportcustomerclearinglocationfee` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `count` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `areacode` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customertimezoneid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportcustomerfee`
--

DROP TABLE IF EXISTS `e_reportcustomerfee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportcustomerfee` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `count` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customertimezoneid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `customeraccount` (`customeraccount`),
  KEY `agentaccount` (`agentaccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportcustomerio`
--

DROP TABLE IF EXISTS `e_reportcustomerio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportcustomerio` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customertimezoneid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `customeraccount` (`customeraccount`),
  KEY `agentaccount` (`agentaccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportcustomerlocationfee`
--

DROP TABLE IF EXISTS `e_reportcustomerlocationfee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportcustomerlocationfee` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `count` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `areacode` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customertimezoneid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `customeraccount` (`customeraccount`),
  KEY `agentaccount` (`agentaccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportgatewaycrosslocationasracd`
--

DROP TABLE IF EXISTS `e_reportgatewaycrosslocationasracd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportgatewaycrosslocationasracd` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `callergatewayid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `areacode` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callcount` int DEFAULT NULL,
  `callreply` int DEFAULT NULL,
  `callestablished` int DEFAULT NULL,
  `callduration` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `calleegatewayid` (`calleegatewayid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportgatewaymappingasracd`
--

DROP TABLE IF EXISTS `e_reportgatewaymappingasracd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportgatewaymappingasracd` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `hour` int DEFAULT NULL,
  `gatewayid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callcount` int DEFAULT NULL,
  `callreply` int DEFAULT NULL,
  `callestablished` int DEFAULT NULL,
  `callduration` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `gatewayid` (`gatewayid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportgatewaymappingfee`
--

DROP TABLE IF EXISTS `e_reportgatewaymappingfee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportgatewaymappingfee` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `count` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `gatewayid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customertimezoneid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `gatewayid` (`gatewayid`),
  KEY `customeraccount` (`customeraccount`),
  KEY `agentaccount` (`agentaccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportgatewaymappinglocationasracd`
--

DROP TABLE IF EXISTS `e_reportgatewaymappinglocationasracd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportgatewaymappinglocationasracd` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `gatewayid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `type` int DEFAULT NULL,
  `ip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `areacode` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callcount` int DEFAULT NULL,
  `callreply` int DEFAULT NULL,
  `callestablished` int DEFAULT NULL,
  `callduration` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `gatewayid` (`gatewayid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportgatewayroutingasracd`
--

DROP TABLE IF EXISTS `e_reportgatewayroutingasracd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportgatewayroutingasracd` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `hour` int DEFAULT NULL,
  `gatewayid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callcount` int DEFAULT NULL,
  `callreply` int DEFAULT NULL,
  `callestablished` int DEFAULT NULL,
  `callduration` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `gatewayid` (`gatewayid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportgatewayroutingfee`
--

DROP TABLE IF EXISTS `e_reportgatewayroutingfee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportgatewayroutingfee` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `count` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `gatewayid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `ip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customertimezoneid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `gatewayid` (`gatewayid`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportgatewayroutinglocationasracd`
--

DROP TABLE IF EXISTS `e_reportgatewayroutinglocationasracd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportgatewayroutinglocationasracd` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `gatewayid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `type` int DEFAULT NULL,
  `ip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `areacode` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `callcount` int DEFAULT NULL,
  `callreply` int DEFAULT NULL,
  `callestablished` int DEFAULT NULL,
  `callduration` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `gatewayid` (`gatewayid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportmanagement`
--

DROP TABLE IF EXISTS `e_reportmanagement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportmanagement` (
  `id` int NOT NULL,
  `date` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `createtime` bigint DEFAULT NULL,
  `loginname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `types` bigint DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportphonecarde164fee`
--

DROP TABLE IF EXISTS `e_reportphonecarde164fee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportphonecarde164fee` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `count` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `calleraccesse164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `pin` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customertimezoneid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `calleraccesse164` (`calleraccesse164`),
  KEY `customeraccount` (`customeraccount`),
  KEY `agentaccount` (`agentaccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportphonecardfee`
--

DROP TABLE IF EXISTS `e_reportphonecardfee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportphonecardfee` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `count` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `pin` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customertimezoneid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `pin` (`pin`),
  KEY `customeraccount` (`customeraccount`),
  KEY `agentaccount` (`agentaccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_reportphonefee`
--

DROP TABLE IF EXISTS `e_reportphonefee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_reportphonefee` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` bigint DEFAULT NULL,
  `count` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `calleebilling` int DEFAULT NULL,
  `e164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customertimezoneid` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `e164` (`e164`),
  KEY `customeraccount` (`customeraccount`),
  KEY `agentaccount` (`agentaccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_suite`
--

DROP TABLE IF EXISTS `e_suite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_suite` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rentperiod` int DEFAULT NULL,
  `renttype` int DEFAULT NULL,
  `nonholonomicorder` int DEFAULT NULL,
  `rentfee` double DEFAULT NULL,
  `minconsumption` double DEFAULT NULL,
  `lowerconsumption` double DEFAULT NULL,
  `giftmoney` double DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_suiteorder`
--

DROP TABLE IF EXISTS `e_suiteorder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_suiteorder` (
  `id` int NOT NULL,
  `availabletime` bigint DEFAULT NULL,
  `expiretime` bigint DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `failedprocessmode` int DEFAULT NULL,
  `rentpercent` double DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `suite_id` int NOT NULL,
  `customer_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `suite_id` (`suite_id`),
  KEY `customer_id` (`customer_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_syslog`
--

DROP TABLE IF EXISTS `e_syslog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_syslog` (
  `id` int NOT NULL,
  `type` int DEFAULT NULL,
  `time` bigint DEFAULT NULL,
  `source` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `event` int DEFAULT NULL,
  `format` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `memo` text COLLATE utf8_bin,
  `infoold` text COLLATE utf8_bin,
  `infonew` text COLLATE utf8_bin,
  PRIMARY KEY (`id`),
  KEY `time` (`time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_system_limit_e164`
--

DROP TABLE IF EXISTS `e_system_limit_e164`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_system_limit_e164` (
  `id` int NOT NULL,
  `e164` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `e164` (`e164`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_terminal_black_list_policy`
--

DROP TABLE IF EXISTS `e_terminal_black_list_policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_terminal_black_list_policy` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `blacklistgroup` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `conditions` text COLLATE utf8_bin,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_user`
--

DROP TABLE IF EXISTS `e_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_user` (
  `id` int NOT NULL,
  `loginname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `username` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `level` int DEFAULT NULL,
  `locktype` int DEFAULT NULL,
  `expiretime` bigint DEFAULT NULL,
  `createduser_id` int DEFAULT NULL,
  `lastlogin` bigint DEFAULT NULL,
  `lastmodifypassword` bigint DEFAULT NULL,
  `limitmacs` int DEFAULT NULL,
  `macs` text COLLATE utf8_bin,
  `onetimepassword` text COLLATE utf8_bin,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `user_privilege_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_privilege_id` (`user_privilege_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_user_privilege`
--

DROP TABLE IF EXISTS `e_user_privilege`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_user_privilege` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `privilege` text COLLATE utf8_bin,
  `classprivilege` text COLLATE utf8_bin,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `create_user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_useragent`
--

DROP TABLE IF EXISTS `e_useragent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_useragent` (
  `id` int NOT NULL,
  `groupname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `username` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `serverip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `serverport` int DEFAULT NULL,
  `encrypt` int DEFAULT NULL,
  `expire` int DEFAULT NULL,
  `localip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `authenticationname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `hostname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `sipoutboundproxy` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `sipuseragent` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `randomlocalport` int DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `rewriterulesoutcaller` text COLLATE utf8_bin,
  `rewriterulesoutcallee` text COLLATE utf8_bin,
  `mbx_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `mbx_id` (`mbx_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_userlogin`
--

DROP TABLE IF EXISTS `e_userlogin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_userlogin` (
  `socketid` int DEFAULT NULL,
  `loginip` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `logintime` bigint DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_web_access_control`
--

DROP TABLE IF EXISTS `e_web_access_control`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_web_access_control` (
  `id` int NOT NULL,
  `path` text COLLATE utf8_bin,
  `allowip` text COLLATE utf8_bin,
  `memo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `equipment_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `r_cc_seat_group_seat`
--

DROP TABLE IF EXISTS `r_cc_seat_group_seat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `r_cc_seat_group_seat` (
  `cc_seat_id` int DEFAULT NULL,
  `cc_seat_group_id` int NOT NULL,
  KEY `cc_seat_group_id` (`cc_seat_group_id`),
  KEY `cc_seat_id` (`cc_seat_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `r_customer_e164ranges`
--

DROP TABLE IF EXISTS `r_customer_e164ranges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `r_customer_e164ranges` (
  `begine164` bigint DEFAULT NULL,
  `ende164` bigint DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  KEY `customer_id` (`customer_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `r_customer_privileges`
--

DROP TABLE IF EXISTS `r_customer_privileges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `r_customer_privileges` (
  `privileges` int DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  KEY `user_id` (`user_id`),
  KEY `customer_id` (`customer_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `r_feerategroup_privileges`
--

DROP TABLE IF EXISTS `r_feerategroup_privileges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `r_feerategroup_privileges` (
  `privileges` int DEFAULT NULL,
  `feerategroup_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  KEY `user_id` (`user_id`),
  KEY `feerategroup_id` (`feerategroup_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `r_suite_privileges`
--

DROP TABLE IF EXISTS `r_suite_privileges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `r_suite_privileges` (
  `privileges` int DEFAULT NULL,
  `suite_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  KEY `user_id` (`user_id`),
  KEY `suite_id` (`suite_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-16 10:24:14
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260118`
--

DROP TABLE IF EXISTS `e_cdr_20260118`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260118` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260119`
--

DROP TABLE IF EXISTS `e_cdr_20260119`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260119` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260120`
--

DROP TABLE IF EXISTS `e_cdr_20260120`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260120` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260121`
--

DROP TABLE IF EXISTS `e_cdr_20260121`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260121` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260122`
--

DROP TABLE IF EXISTS `e_cdr_20260122`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260122` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260123`
--

DROP TABLE IF EXISTS `e_cdr_20260123`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260123` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260124`
--

DROP TABLE IF EXISTS `e_cdr_20260124`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260124` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260125`
--

DROP TABLE IF EXISTS `e_cdr_20260125`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260125` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260126`
--

DROP TABLE IF EXISTS `e_cdr_20260126`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260126` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260127`
--

DROP TABLE IF EXISTS `e_cdr_20260127`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260127` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260128`
--

DROP TABLE IF EXISTS `e_cdr_20260128`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260128` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260129`
--

DROP TABLE IF EXISTS `e_cdr_20260129`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260129` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260130`
--

DROP TABLE IF EXISTS `e_cdr_20260130`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260130` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260131`
--

DROP TABLE IF EXISTS `e_cdr_20260131`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260131` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260201`
--

DROP TABLE IF EXISTS `e_cdr_20260201`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260201` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260202`
--

DROP TABLE IF EXISTS `e_cdr_20260202`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260202` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260203`
--

DROP TABLE IF EXISTS `e_cdr_20260203`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260203` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260204`
--

DROP TABLE IF EXISTS `e_cdr_20260204`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260204` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260205`
--

DROP TABLE IF EXISTS `e_cdr_20260205`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260205` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260206`
--

DROP TABLE IF EXISTS `e_cdr_20260206`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260206` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260207`
--

DROP TABLE IF EXISTS `e_cdr_20260207`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260207` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260208`
--

DROP TABLE IF EXISTS `e_cdr_20260208`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260208` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260209`
--

DROP TABLE IF EXISTS `e_cdr_20260209`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260209` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260210`
--

DROP TABLE IF EXISTS `e_cdr_20260210`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260210` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260211`
--

DROP TABLE IF EXISTS `e_cdr_20260211`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260211` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260212`
--

DROP TABLE IF EXISTS `e_cdr_20260212`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260212` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260213`
--

DROP TABLE IF EXISTS `e_cdr_20260213`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260213` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260214`
--

DROP TABLE IF EXISTS `e_cdr_20260214`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260214` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260215`
--

DROP TABLE IF EXISTS `e_cdr_20260215`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260215` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260216`
--

DROP TABLE IF EXISTS `e_cdr_20260216`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260216` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260217`
--

DROP TABLE IF EXISTS `e_cdr_20260217`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260217` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260218`
--

DROP TABLE IF EXISTS `e_cdr_20260218`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260218` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260219`
--

DROP TABLE IF EXISTS `e_cdr_20260219`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260219` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260220`
--

DROP TABLE IF EXISTS `e_cdr_20260220`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260220` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260221`
--

DROP TABLE IF EXISTS `e_cdr_20260221`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260221` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260222`
--

DROP TABLE IF EXISTS `e_cdr_20260222`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260222` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260223`
--

DROP TABLE IF EXISTS `e_cdr_20260223`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260223` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260224`
--

DROP TABLE IF EXISTS `e_cdr_20260224`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260224` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260225`
--

DROP TABLE IF EXISTS `e_cdr_20260225`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260225` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260226`
--

DROP TABLE IF EXISTS `e_cdr_20260226`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260226` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260227`
--

DROP TABLE IF EXISTS `e_cdr_20260227`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260227` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260228`
--

DROP TABLE IF EXISTS `e_cdr_20260228`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260228` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260301`
--

DROP TABLE IF EXISTS `e_cdr_20260301`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260301` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260302`
--

DROP TABLE IF EXISTS `e_cdr_20260302`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260302` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260303`
--

DROP TABLE IF EXISTS `e_cdr_20260303`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260303` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260304`
--

DROP TABLE IF EXISTS `e_cdr_20260304`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260304` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260305`
--

DROP TABLE IF EXISTS `e_cdr_20260305`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260305` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260306`
--

DROP TABLE IF EXISTS `e_cdr_20260306`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260306` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260307`
--

DROP TABLE IF EXISTS `e_cdr_20260307`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260307` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260308`
--

DROP TABLE IF EXISTS `e_cdr_20260308`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260308` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleetype` int DEFAULT NULL,
  `billingmode` int DEFAULT NULL,
  `calllevel` int DEFAULT NULL,
  `agentfeetime` int DEFAULT NULL,
  `starttime` bigint DEFAULT NULL,
  `stoptime` bigint DEFAULT NULL,
  `callerpdd` int DEFAULT NULL,
  `calleepdd` int DEFAULT NULL,
  `holdtime` int DEFAULT NULL,
  `callerareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `feetime` int DEFAULT NULL,
  `fee` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `suitefee` double DEFAULT NULL,
  `suitefeetime` int DEFAULT NULL,
  `incomefee` double DEFAULT NULL,
  `incometax` double DEFAULT NULL,
  `customeraccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customername` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `calleeareacode` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `agentfee` double DEFAULT NULL,
  `agenttax` double DEFAULT NULL,
  `agentsuitefee` double DEFAULT NULL,
  `agentsuitefeetime` int DEFAULT NULL,
  `agentaccount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `agentname` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `flowno` bigint NOT NULL,
  `softswitchname` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `softswitchcallid` bigint DEFAULT NULL,
  `callercallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalcallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecallid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleroriginalinfo` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rtpforward` int DEFAULT NULL,
  `enddirection` int DEFAULT NULL,
  `endreason` int DEFAULT NULL,
  `billingtype` int DEFAULT NULL,
  `cdrlevel` int DEFAULT NULL,
  `agentcdr_id` int DEFAULT NULL,
  `sipreasonheader` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `recordstarttime` bigint DEFAULT NULL,
  `transactionid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `flownofirst` bigint DEFAULT NULL,
  `additional` blob,
  `dynamicValue` json DEFAULT NULL,
  PRIMARY KEY (`flowno`),
  KEY `callere164` (`callere164`),
  KEY `callergatewayid` (`callergatewayid`),
  KEY `starttime` (`starttime`),
  KEY `stoptime` (`stoptime`),
  KEY `customeraccount` (`customeraccount`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `e_cdr_20260309`
--

DROP TABLE IF EXISTS `e_cdr_20260309`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `e_cdr_20260309` (
  `id` int NOT NULL,
  `callere164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleraccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleee164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleeaccesse164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerrtpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callercodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callergatewayid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callerproductid` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertogatewaye164` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `callertype` int DEFAULT NULL,
  `calleeip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleertpip` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleecodec` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `calleegatewayid` varchar(64) COLLATE u