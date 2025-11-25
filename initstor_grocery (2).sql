-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Sep 01, 2025 at 08:48 AM
-- Server version: 8.0.41-cll-lve
-- PHP Version: 8.3.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `initstor_grocery`
--

-- --------------------------------------------------------

--
-- Table structure for table `chat_rooms`
--

CREATE TABLE `chat_rooms` (
  `id` int NOT NULL,
  `room_id` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `user_id_1` int NOT NULL,
  `user_id_2` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_message` text COLLATE utf8mb3_unicode_ci,
  `unread_count` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `chat_rooms`
--

INSERT INTO `chat_rooms` (`id`, `room_id`, `user_id_1`, `user_id_2`, `created_at`, `updated_at`, `last_message`, `unread_count`) VALUES
(1, 'room_68a2134d70c5b1.37727261', 2, 1, '2025-08-17 17:37:17', '2025-08-19 06:20:15', 'hello', 0),
(2, 'room_68a2d56d128f29.10904899', 3, 2, '2025-08-18 07:25:33', '2025-08-19 08:32:54', 'Hii', 0),
(3, 'room_68a31348d7a573.71596269', 8, 3, '2025-08-18 11:49:28', '2025-08-18 11:49:32', 'hello sir', 0),
(4, 'room_68a31c1af2cbf7.12248207', 4, 6, '2025-08-18 12:27:06', '2025-08-18 12:27:11', 'hi', 0),
(5, 'room_68a31c49ca1ec6.52250960', 4, 5, '2025-08-18 12:27:53', '2025-08-21 03:39:40', 'Hii', 0),
(6, 'room_68a31ecdeef803.12595036', 5, 9, '2025-08-18 12:38:37', '2025-08-18 12:38:37', NULL, 0),
(7, 'room_68a338fc23ed56.29703379', 3, 4, '2025-08-18 14:30:20', '2025-08-18 14:30:43', 'sir proper aahe ka', 0),
(8, 'room_68a3f52d13de37.19915805', 8, 4, '2025-08-19 03:53:17', '2025-08-19 08:19:33', 'Hi', 0),
(9, 'room_68a3fc9c8e6ca6.29380118', 2, 4, '2025-08-19 04:25:00', '2025-08-19 07:44:07', 'Hello', 0),
(10, 'room_68a41dca429c33.53690225', 2, 9, '2025-08-19 06:46:34', '2025-08-19 07:47:21', 'Hii', 0),
(14, 'room_68a436c24fe786.93392169', 8, 2, '2025-08-19 08:33:06', '2025-08-19 08:33:10', 'Hello', 0),
(19, 'room_68a527e5efd557.72638932', 2, 6, '2025-08-20 01:41:57', '2025-08-20 01:42:02', 'Hii', 0),
(20, 'room_68a6950f0b4d59.63558531', 5, 8, '2025-08-21 03:39:59', '2025-08-21 03:40:07', 'Hii', 0),
(21, 'room_68a9cfab7632e0.84764537', 10, 8, '2025-08-23 14:26:51', '2025-08-23 14:27:30', '', 0);

-- --------------------------------------------------------

--
-- Table structure for table `comments`
--

CREATE TABLE `comments` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `parent_id` int DEFAULT NULL,
  `post_id` int NOT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `comments`
--

INSERT INTO `comments` (`id`, `user_id`, `parent_id`, `post_id`, `comment`, `created_at`, `updated_at`) VALUES
(1, 1, NULL, 4, 'hii', '2025-08-03 05:51:08', '2025-08-03 05:51:08'),
(2, 1, NULL, 4, 'hii', '2025-08-03 06:22:35', '2025-08-03 06:22:35'),
(3, 1, NULL, 4, 'hii', '2025-08-03 06:22:35', '2025-08-03 06:22:35'),
(4, 1, NULL, 4, 'hii', '2025-08-03 06:22:38', '2025-08-03 06:22:38'),
(5, 1, NULL, 4, 'hii', '2025-08-03 06:22:38', '2025-08-03 06:22:38'),
(6, 1, NULL, 4, 'hii', '2025-08-03 06:22:39', '2025-08-03 06:22:39'),
(7, 1, NULL, 4, 'hii', '2025-08-03 06:22:39', '2025-08-03 06:22:39'),
(8, 1, NULL, 1, 'fhhduu', '2025-08-03 06:26:06', '2025-08-03 06:26:06'),
(9, 1, NULL, 1, 'fhhduu', '2025-08-03 06:26:07', '2025-08-03 06:26:07'),
(10, 1, NULL, 1, 'chff', '2025-08-03 06:26:30', '2025-08-03 06:26:30'),
(11, 1, NULL, 1, 'chff', '2025-08-03 06:26:33', '2025-08-03 06:26:33'),
(12, 4, NULL, 8, 'hi', '2025-08-05 17:09:45', '2025-08-05 17:09:45'),
(13, 5, NULL, 10, '????', '2025-08-21 03:40:39', '2025-08-21 03:40:39'),
(14, 5, NULL, 10, '????', '2025-08-21 03:40:45', '2025-08-21 03:40:45'),
(15, 5, NULL, 10, '????????', '2025-08-21 03:41:01', '2025-08-21 03:41:01'),
(16, 5, NULL, 10, '????????', '2025-08-21 03:41:04', '2025-08-21 03:41:04'),
(17, 4, NULL, 11, 'nice', '2025-08-21 05:08:25', '2025-08-21 05:08:25'),
(18, 2, NULL, 11, 'hi', '2025-08-23 13:54:01', '2025-08-23 13:54:01'),
(19, 2, NULL, 11, 'hi', '2025-08-23 13:54:03', '2025-08-23 13:54:03'),
(20, 2, NULL, 11, 'hi', '2025-08-23 13:54:04', '2025-08-23 13:54:04'),
(21, 2, NULL, 11, 'hi', '2025-08-23 13:54:04', '2025-08-23 13:54:04'),
(22, 2, NULL, 11, 'hi', '2025-08-23 13:54:04', '2025-08-23 13:54:04'),
(23, 2, NULL, 11, 'hi', '2025-08-23 13:54:04', '2025-08-23 13:54:04'),
(24, 10, NULL, 11, 'hello', '2025-08-23 14:24:14', '2025-08-23 14:24:14');

-- --------------------------------------------------------

--
-- Table structure for table `follows`
--

CREATE TABLE `follows` (
  `id` int NOT NULL,
  `follower_id` int NOT NULL,
  `following_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `follows`
--

INSERT INTO `follows` (`id`, `follower_id`, `following_id`, `created_at`) VALUES
(3, 1, 2, '2025-08-03 11:46:45'),
(5, 2, 3, '2025-08-05 15:38:34'),
(6, 2, 1, '2025-08-05 15:47:19'),
(8, 2, 5, '2025-08-17 16:34:06'),
(11, 9, 6, '2025-08-18 09:02:13'),
(12, 9, 2, '2025-08-18 09:02:19'),
(13, 9, 1, '2025-08-18 09:06:41'),
(14, 9, 5, '2025-08-18 09:07:11'),
(15, 8, 3, '2025-08-18 10:43:37'),
(17, 2, 6, '2025-08-18 12:02:52'),
(19, 4, 5, '2025-08-18 12:27:49'),
(20, 3, 4, '2025-08-18 14:30:01'),
(21, 4, 3, '2025-08-18 14:33:44'),
(22, 4, 8, '2025-08-18 14:33:46'),
(24, 8, 2, '2025-08-19 08:32:56'),
(25, 2, 4, '2025-08-19 08:34:09'),
(26, 8, 10, '2025-08-23 14:25:15');

-- --------------------------------------------------------

--
-- Table structure for table `gift_categories`
--

CREATE TABLE `gift_categories` (
  `id` int NOT NULL,
  `name` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `icon` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `gift_categories`
--

INSERT INTO `gift_categories` (`id`, `name`, `icon`, `created_at`) VALUES
(1, 'Love & Hearts', '❤️', '2025-08-17 16:03:03'),
(2, 'Celebration', '?', '2025-08-17 16:03:03'),
(3, 'Nature', '?', '2025-08-17 16:03:03'),
(4, 'Animals', '?', '2025-08-17 16:03:03'),
(5, 'Premium', '?', '2025-08-17 16:03:03'),
(6, 'Love & Hearts', '❤️', '2025-08-17 16:03:18'),
(7, 'Celebration', '?', '2025-08-17 16:03:18'),
(8, 'Nature', '?', '2025-08-17 16:03:18'),
(9, 'Animals', '?', '2025-08-17 16:03:18'),
(10, 'Premium', '?', '2025-08-17 16:03:18'),
(11, 'Love & Hearts', '❤️', '2025-08-17 16:03:27'),
(12, 'Celebration', '?', '2025-08-17 16:03:27'),
(13, 'Nature', '?', '2025-08-17 16:03:27'),
(14, 'Animals', '?', '2025-08-17 16:03:27'),
(15, 'Premium', '?', '2025-08-17 16:03:27'),
(16, 'Love & Hearts', '❤️', '2025-08-17 16:16:07'),
(17, 'Celebration', '', '2025-08-17 16:16:07'),
(18, 'Nature', '', '2025-08-17 16:16:07'),
(19, 'Animals', '', '2025-08-17 16:16:07'),
(20, 'Premium', '', '2025-08-17 16:16:07'),
(21, 'Love & Hearts', '❤️', '2025-08-19 06:09:55'),
(22, 'Celebration', '', '2025-08-19 06:09:55'),
(23, 'Nature', '', '2025-08-19 06:09:55'),
(24, 'Animals', '', '2025-08-19 06:09:55'),
(25, 'Premium', '', '2025-08-19 06:09:55');

-- --------------------------------------------------------

--
-- Table structure for table `gift_items`
--

CREATE TABLE `gift_items` (
  `id` int NOT NULL,
  `category_id` int NOT NULL,
  `name` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `icon` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `coins` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `gift_items`
--

INSERT INTO `gift_items` (`id`, `category_id`, `name`, `icon`, `price`, `coins`, `created_at`) VALUES
(1, 1, 'Rose', '?', 0.99, 100, '2025-08-17 16:03:03'),
(2, 1, 'Heart', '?', 1.99, 200, '2025-08-17 16:03:03'),
(3, 1, 'Kiss', '?', 2.99, 300, '2025-08-17 16:03:03'),
(4, 2, 'Cake', '?', 4.99, 500, '2025-08-17 16:03:03'),
(5, 2, 'Balloon', '?', 2.49, 250, '2025-08-17 16:03:03'),
(6, 2, 'Party', '?', 9.99, 1000, '2025-08-17 16:03:03'),
(7, 3, 'Flower', '?', 1.49, 150, '2025-08-17 16:03:03'),
(8, 3, 'Tree', '?', 3.99, 400, '2025-08-17 16:03:03'),
(9, 3, 'Sun', '☀️', 3.49, 350, '2025-08-17 16:03:03'),
(10, 4, 'Cat', '?', 4.49, 450, '2025-08-17 16:03:03'),
(11, 4, 'Dog', '?', 5.49, 550, '2025-08-17 16:03:03'),
(12, 4, 'Butterfly', '?', 2.99, 300, '2025-08-17 16:03:03'),
(13, 5, 'Diamond', '?', 19.99, 2000, '2025-08-17 16:03:03'),
(14, 5, 'Crown', '?', 49.99, 5000, '2025-08-17 16:03:03'),
(15, 5, 'Star', '⭐', 14.99, 1500, '2025-08-17 16:03:03'),
(16, 1, 'Rose', '?', 0.99, 100, '2025-08-17 16:03:18'),
(17, 1, 'Heart', '?', 1.99, 200, '2025-08-17 16:03:18'),
(18, 1, 'Kiss', '?', 2.99, 300, '2025-08-17 16:03:18'),
(19, 2, 'Cake', '?', 4.99, 500, '2025-08-17 16:03:18'),
(20, 2, 'Balloon', '?', 2.49, 250, '2025-08-17 16:03:18'),
(21, 2, 'Party', '?', 9.99, 1000, '2025-08-17 16:03:18'),
(22, 3, 'Flower', '?', 1.49, 150, '2025-08-17 16:03:18'),
(23, 3, 'Tree', '?', 3.99, 400, '2025-08-17 16:03:18'),
(24, 3, 'Sun', '☀️', 3.49, 350, '2025-08-17 16:03:18'),
(25, 4, 'Cat', '?', 4.49, 450, '2025-08-17 16:03:18'),
(26, 4, 'Dog', '?', 5.49, 550, '2025-08-17 16:03:18'),
(27, 4, 'Butterfly', '?', 2.99, 300, '2025-08-17 16:03:18'),
(28, 5, 'Diamond', '?', 19.99, 2000, '2025-08-17 16:03:18'),
(29, 5, 'Crown', '?', 49.99, 5000, '2025-08-17 16:03:18'),
(30, 5, 'Star', '⭐', 14.99, 1500, '2025-08-17 16:03:18'),
(31, 1, 'Rose', '?', 0.99, 100, '2025-08-17 16:03:27'),
(32, 1, 'Heart', '?', 1.99, 200, '2025-08-17 16:03:27'),
(33, 1, 'Kiss', '?', 2.99, 300, '2025-08-17 16:03:27'),
(34, 2, 'Cake', '?', 4.99, 500, '2025-08-17 16:03:27'),
(35, 2, 'Balloon', '?', 2.49, 250, '2025-08-17 16:03:27'),
(36, 2, 'Party', '?', 9.99, 1000, '2025-08-17 16:03:27'),
(37, 3, 'Flower', '?', 1.49, 150, '2025-08-17 16:03:27'),
(38, 3, 'Tree', '?', 3.99, 400, '2025-08-17 16:03:27'),
(39, 3, 'Sun', '☀️', 3.49, 350, '2025-08-17 16:03:27'),
(40, 4, 'Cat', '?', 4.49, 450, '2025-08-17 16:03:27'),
(41, 4, 'Dog', '?', 5.49, 550, '2025-08-17 16:03:27'),
(42, 4, 'Butterfly', '?', 2.99, 300, '2025-08-17 16:03:27'),
(43, 5, 'Diamond', '?', 19.99, 2000, '2025-08-17 16:03:27'),
(44, 5, 'Crown', '?', 49.99, 5000, '2025-08-17 16:03:27'),
(45, 5, 'Star', '⭐', 14.99, 1500, '2025-08-17 16:03:27'),
(46, 1, 'Rose', '', 0.99, 100, '2025-08-17 16:16:07'),
(47, 1, 'Heart', '', 1.99, 200, '2025-08-17 16:16:07'),
(48, 1, 'Kiss', '', 2.99, 300, '2025-08-17 16:16:07'),
(49, 2, 'Cake', '', 4.99, 500, '2025-08-17 16:16:07'),
(50, 2, 'Balloon', '', 2.49, 250, '2025-08-17 16:16:07'),
(51, 2, 'Party', '', 9.99, 1000, '2025-08-17 16:16:07'),
(52, 3, 'Flower', '', 1.49, 150, '2025-08-17 16:16:07'),
(53, 3, 'Tree', '', 3.99, 400, '2025-08-17 16:16:07'),
(54, 3, 'Sun', '☀️', 3.49, 350, '2025-08-17 16:16:07'),
(55, 4, 'Cat', '', 4.49, 450, '2025-08-17 16:16:07'),
(56, 4, 'Dog', '', 5.49, 550, '2025-08-17 16:16:07'),
(57, 4, 'Butterfly', '', 2.99, 300, '2025-08-17 16:16:07'),
(58, 5, 'Diamond', '', 19.99, 2000, '2025-08-17 16:16:07'),
(59, 5, 'Crown', '', 49.99, 5000, '2025-08-17 16:16:07'),
(60, 5, 'Star', '⭐', 14.99, 1500, '2025-08-17 16:16:07'),
(61, 1, 'Rose', '', 0.99, 100, '2025-08-19 06:09:55'),
(62, 1, 'Heart', '', 1.99, 200, '2025-08-19 06:09:55'),
(63, 1, 'Kiss', '', 2.99, 300, '2025-08-19 06:09:55'),
(64, 2, 'Cake', '', 4.99, 500, '2025-08-19 06:09:55'),
(65, 2, 'Balloon', '', 2.49, 250, '2025-08-19 06:09:55'),
(66, 2, 'Party', '', 9.99, 1000, '2025-08-19 06:09:55'),
(67, 3, 'Flower', '', 1.49, 150, '2025-08-19 06:09:55'),
(68, 3, 'Tree', '', 3.99, 400, '2025-08-19 06:09:55'),
(69, 3, 'Sun', '☀️', 3.49, 350, '2025-08-19 06:09:55'),
(70, 4, 'Cat', '', 4.49, 450, '2025-08-19 06:09:55'),
(71, 4, 'Dog', '', 5.49, 550, '2025-08-19 06:09:55'),
(72, 4, 'Butterfly', '', 2.99, 300, '2025-08-19 06:09:55'),
(73, 5, 'Diamond', '', 19.99, 2000, '2025-08-19 06:09:55'),
(74, 5, 'Crown', '', 49.99, 5000, '2025-08-19 06:09:55'),
(75, 5, 'Star', '⭐', 14.99, 1500, '2025-08-19 06:09:55');

-- --------------------------------------------------------

--
-- Table structure for table `gift_transactions`
--

CREATE TABLE `gift_transactions` (
  `id` int NOT NULL,
  `sender_id` int NOT NULL,
  `recipient_id` int NOT NULL,
  `gift_id` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `gift_name` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `gift_icon` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `quantity` int DEFAULT '1',
  `total_cost` int NOT NULL,
  `message` text COLLATE utf8mb3_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `gift_transactions`
--

INSERT INTO `gift_transactions` (`id`, `sender_id`, `recipient_id`, `gift_id`, `gift_name`, `gift_icon`, `quantity`, `total_cost`, `message`, `created_at`) VALUES
(1, 1, 2, '1', 'Rose', '?', 1, 100, 'Welcome to MySgram!', '2025-08-13 10:57:16'),
(2, 2, 1, '2', 'Heart', '?', 1, 200, 'Thanks for the follow!', '2025-08-13 10:57:16'),
(3, 1, 3, '4', 'Cake', '?', 1, 500, 'Happy Birthday!', '2025-08-13 10:57:16'),
(4, 1, 2, '1', 'Rose', '?', 1, 100, 'Welcome to MySgram!', '2025-08-13 10:59:25'),
(5, 2, 1, '2', 'Heart', '?', 1, 200, 'Thanks for the follow!', '2025-08-13 10:59:25'),
(6, 1, 3, '4', 'Cake', '?', 1, 500, 'Happy Birthday!', '2025-08-13 10:59:25'),
(7, 1, 2, '1', 'Rose', '?', 1, 100, 'Welcome to MySgram!', '2025-08-13 10:59:33'),
(8, 2, 1, '2', 'Heart', '?', 1, 200, 'Thanks for the follow!', '2025-08-13 10:59:33'),
(9, 1, 3, '4', 'Cake', '?', 1, 500, 'Happy Birthday!', '2025-08-13 10:59:33');

-- --------------------------------------------------------

--
-- Table structure for table `likes`
--

CREATE TABLE `likes` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `post_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `likes`
--

INSERT INTO `likes` (`id`, `user_id`, `post_id`, `created_at`) VALUES
(8, 1, 2, '2025-08-03 05:45:10'),
(13, 1, 1, '2025-08-03 06:12:20'),
(18, 1, 3, '2025-08-03 06:22:24'),
(20, 1, 4, '2025-08-03 06:25:56'),
(24, 1, 5, '2025-08-03 08:24:39'),
(25, 1, 6, '2025-08-03 08:35:21'),
(26, 2, 6, '2025-08-03 08:43:14'),
(27, 2, 5, '2025-08-03 08:43:17'),
(28, 2, 4, '2025-08-03 08:43:18'),
(29, 2, 3, '2025-08-03 08:43:20'),
(30, 2, 2, '2025-08-03 08:43:22'),
(31, 2, 1, '2025-08-03 08:43:24'),
(32, 2, 7, '2025-08-03 09:09:57'),
(35, 4, 8, '2025-08-05 17:09:33'),
(38, 2, 9, '2025-08-17 16:33:32'),
(39, 5, 9, '2025-08-18 12:37:12'),
(40, 3, 10, '2025-08-18 14:30:50'),
(41, 3, 9, '2025-08-18 14:30:53'),
(42, 5, 10, '2025-08-19 05:40:09'),
(43, 2, 10, '2025-08-19 06:19:16'),
(44, 5, 11, '2025-08-19 08:24:55'),
(45, 2, 11, '2025-08-19 08:33:38');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` int NOT NULL,
  `message_id` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `room_id` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `sender_id` int NOT NULL,
  `message` text COLLATE utf8mb3_unicode_ci NOT NULL,
  `reply_to` varchar(100) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `message_type` enum('text','image','video','audio','file','gift','location') COLLATE utf8mb3_unicode_ci DEFAULT 'text',
  `metadata` json DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_seen` tinyint(1) DEFAULT '0',
  `seen_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `message_id`, `room_id`, `sender_id`, `message`, `reply_to`, `message_type`, `metadata`, `timestamp`, `is_seen`, `seen_at`) VALUES
(1, 'msg_68a2138b26cea1.36101515', 'room_68a2134d70c5b1.37727261', 2, 'hi', NULL, 'text', NULL, '2025-08-17 17:38:19', 0, NULL),
(2, 'msg_68a214a4dc0657.39987028', 'room_68a2134d70c5b1.37727261', 2, 'Hello', NULL, 'text', NULL, '2025-08-17 17:43:00', 0, NULL),
(3, 'msg_68a226d7340881.49515638', 'room_68a2134d70c5b1.37727261', 2, 'hi', NULL, 'text', NULL, '2025-08-17 19:00:39', 0, NULL),
(4, 'msg_68a2d574194fc4.02347132', 'room_68a2d56d128f29.10904899', 3, 'hello', NULL, 'text', NULL, '2025-08-18 07:25:40', 1, '2025-08-19 07:17:28'),
(5, 'msg_68a3134c512021.30261251', 'room_68a31348d7a573.71596269', 8, 'hello sir', NULL, 'text', NULL, '2025-08-18 11:49:32', 0, NULL),
(6, 'msg_68a31c1f3f61f6.74192273', 'room_68a31c1af2cbf7.12248207', 4, 'hi', NULL, 'text', NULL, '2025-08-18 12:27:11', 0, NULL),
(7, 'msg_68a31c4d795d05.86229929', 'room_68a31c49ca1ec6.52250960', 4, 'hi', NULL, 'text', NULL, '2025-08-18 12:27:57', 1, '2025-08-20 17:36:08'),
(8, 'msg_68a31e9e8873e4.43825242', 'room_68a31c49ca1ec6.52250960', 5, 'hii', NULL, 'text', NULL, '2025-08-18 12:37:50', 1, '2025-08-21 05:07:23'),
(9, 'msg_68a33902ac6c48.37699122', 'room_68a338fc23ed56.29703379', 3, 'hii sir', NULL, 'text', NULL, '2025-08-18 14:30:26', 1, '2025-08-19 08:19:45'),
(10, 'msg_68a33913d7e5f3.74512238', 'room_68a338fc23ed56.29703379', 3, 'sir proper aahe ka', NULL, 'text', NULL, '2025-08-18 14:30:43', 1, '2025-08-19 08:19:45'),
(11, 'msg_68a340c60b87e0.14287757', 'room_68a31c49ca1ec6.52250960', 5, 'hello', NULL, 'text', NULL, '2025-08-18 15:03:34', 1, '2025-08-21 05:07:23'),
(12, 'msg_68a3fca30781a6.77889195', 'room_68a3fc9c8e6ca6.29380118', 2, 'hii', NULL, 'text', NULL, '2025-08-19 04:25:07', 0, NULL),
(13, 'msg_68a4178a91f667.85987863', 'room_68a2134d70c5b1.37727261', 2, 'hii', NULL, 'text', NULL, '2025-08-19 06:19:54', 0, NULL),
(14, 'msg_68a4179f07ac20.31399632', 'room_68a2134d70c5b1.37727261', 2, 'hello', NULL, 'text', NULL, '2025-08-19 06:20:15', 0, NULL),
(15, 'msg_68a420ca595eb0.18687164', 'room_68a2d56d128f29.10904899', 2, 'hii', NULL, 'text', NULL, '2025-08-19 06:59:22', 0, NULL),
(16, 'msg_68a42b473641f6.01975438', 'room_68a3fc9c8e6ca6.29380118', 2, 'Hello', NULL, 'text', NULL, '2025-08-19 07:44:07', 0, NULL),
(17, 'msg_68a42c093943c7.88524235', 'room_68a41dca429c33.53690225', 2, 'Hii', NULL, 'text', NULL, '2025-08-19 07:47:21', 0, NULL),
(18, 'msg_68a4322095eb16.00830104', 'room_68a3f52d13de37.19915805', 8, 'Hello', NULL, 'text', NULL, '2025-08-19 08:13:20', 1, '2025-08-19 08:19:20'),
(19, 'msg_68a4333c3a4b46.81092972', 'room_68a3f52d13de37.19915805', 8, 'Hello', NULL, 'text', NULL, '2025-08-19 08:18:04', 1, '2025-08-19 08:19:20'),
(20, 'msg_68a43395588c80.48764067', 'room_68a3f52d13de37.19915805', 4, 'Hi', NULL, 'text', NULL, '2025-08-19 08:19:33', 1, '2025-08-19 08:19:47'),
(21, 'msg_68a436b6c57b54.02046283', 'room_68a2d56d128f29.10904899', 2, 'Hii', NULL, 'text', NULL, '2025-08-19 08:32:54', 0, NULL),
(22, 'msg_68a436c6ecba36.10334005', 'room_68a436c24fe786.93392169', 8, 'Hello', NULL, 'text', NULL, '2025-08-19 08:33:10', 1, '2025-08-19 08:33:26'),
(23, 'msg_68a527ea63b7f2.02100144', 'room_68a527e5efd557.72638932', 2, 'Hii', NULL, 'text', NULL, '2025-08-20 01:42:02', 0, NULL),
(24, 'msg_68a694fc6ffa03.11730706', 'room_68a31c49ca1ec6.52250960', 5, 'Hii', NULL, 'text', NULL, '2025-08-21 03:39:40', 1, '2025-08-21 05:07:23'),
(25, 'msg_68a69517067121.63955564', 'room_68a6950f0b4d59.63558531', 5, 'Hii', NULL, 'text', NULL, '2025-08-21 03:40:07', 0, NULL),
(26, 'msg_68a9cfafb3e700.48761294', 'room_68a9cfab7632e0.84764537', 10, 'Hello', NULL, 'text', NULL, '2025-08-23 14:26:55', 1, '2025-08-23 14:27:22'),
(27, 'msg_68a9cfd2bed807.45329468', 'room_68a9cfab7632e0.84764537', 8, '', NULL, 'text', NULL, '2025-08-23 14:27:30', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int NOT NULL,
  `recipient_id` int NOT NULL,
  `sender_id` int NOT NULL,
  `type` enum('follow','like','comment','follow_request','mention') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `post_id` int DEFAULT NULL,
  `comment_id` int DEFAULT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `posts`
--

CREATE TABLE `posts` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `caption` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `media_type` enum('image','video','reel') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `media_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `thumbnail_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `duration` int DEFAULT NULL,
  `likes_count` int DEFAULT '0',
  `comments_count` int DEFAULT '0',
  `shares_count` int DEFAULT '0',
  `is_public` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `posts`
--

INSERT INTO `posts` (`id`, `user_id`, `caption`, `media_type`, `media_url`, `thumbnail_url`, `duration`, `likes_count`, `comments_count`, `shares_count`, `is_public`, `created_at`, `updated_at`) VALUES
(1, 1, 'Posted from MySgram! ????', 'image', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754193859_688edfc35959c.png', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754193859_688edfc35959c.png', NULL, 2, 4, 0, 1, '2025-08-03 04:04:23', '2025-08-03 08:43:24'),
(2, 1, 'nzngsmdkd', 'image', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754194460_688ee21cd0c94.jpg', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754194460_688ee21cd0c94.jpg', NULL, 2, 0, 0, 1, '2025-08-03 04:14:21', '2025-08-03 08:43:22'),
(3, 1, 'Posted from MySgram! ????', 'image', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754195106_688ee4a29c334.png', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754195106_688ee4a29c334.png', NULL, 2, 0, 0, 1, '2025-08-03 04:25:06', '2025-08-03 08:43:20'),
(4, 1, 'helloo', 'image', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754199228_688ef4bcd3e9d.jpg', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754199228_688ef4bcd3e9d.jpg', NULL, 2, 7, 0, 1, '2025-08-03 05:33:48', '2025-08-03 08:43:18'),
(5, 1, 'Posted from MySgram! ????', 'video', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754208611_688f1963888bd.mp4', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754208611_688f1963888bd.mp4', NULL, 2, 0, 0, 1, '2025-08-03 08:10:17', '2025-08-03 08:43:17'),
(6, 1, 'new one', 'video', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754210098_688f1f3229fa6.mp4', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754210098_688f1f3229fa6.mp4', NULL, 2, 0, 0, 1, '2025-08-03 08:35:08', '2025-08-30 15:51:12'),
(7, 2, 'Posted from MySgram! ????', '', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754212191_688f275faec73.png', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754212191_688f275faec73.png', NULL, 1, 0, 0, 1, '2025-08-03 09:09:51', '2025-08-05 17:01:13'),
(8, 4, 'Posted from MySgram! ????', '', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754413328_689239100e3ba.jpg', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754413328_689239100e3ba.jpg', NULL, 1, 1, 0, 1, '2025-08-05 17:02:08', '2025-08-05 17:09:45'),
(9, 5, 'Pattadakkal Tempel', '', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754482710_68934816b4e0a.jpg', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1754482710_68934816b4e0a.jpg', NULL, 3, 0, 0, 1, '2025-08-06 12:18:32', '2025-08-18 14:30:53'),
(10, 4, 'Posted from MySgram! ????', '', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1755520104_68a31c6880dd0.jpg', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1755520104_68a31c6880dd0.jpg', NULL, 3, 4, 0, 1, '2025-08-18 12:28:24', '2025-08-21 03:41:04'),
(11, 8, 'Posted from MySgram! ????', '', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1755591245_68a4324d68be1.jpg', 'https://devloperwala.in/MySgram/backend/uploads/posts/post_1755591245_68a4324d68be1.jpg', NULL, 2, 8, 0, 1, '2025-08-19 08:14:05', '2025-08-30 15:50:33');

-- --------------------------------------------------------

--
-- Table structure for table `stories`
--

CREATE TABLE `stories` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `media_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `media_type` enum('image','video') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `caption` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `duration` int DEFAULT '24',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `stories`
--

INSERT INTO `stories` (`id`, `user_id`, `media_url`, `media_type`, `caption`, `duration`, `created_at`) VALUES
(1, 1, 'https://devloperwala.in/MySgram/backend/uploads/stories/story_1754204106_1.png', 'image', '', NULL, '2025-08-03 06:55:06'),
(2, 1, 'https://devloperwala.in/MySgram/backend/uploads/stories/story_1754206392_1.png', 'image', '', NULL, '2025-08-03 07:33:12'),
(3, 5, 'https://devloperwala.in/MySgram/backend/uploads/stories/story_1755529379_5.jpg', 'image', '', NULL, '2025-08-18 15:02:59'),
(4, 2, 'https://devloperwala.in/MySgram/backend/uploads/stories/story_1755584369_2.png', 'image', '', NULL, '2025-08-19 06:19:29'),
(5, 2, 'https://devloperwala.in/MySgram/backend/uploads/stories/story_1755584376_2.png', 'image', '', NULL, '2025-08-19 06:19:36'),
(6, 8, 'https://devloperwala.in/MySgram/backend/uploads/stories/story_1755592525_8.jpg', 'image', '', NULL, '2025-08-19 08:35:27'),
(7, 8, 'https://devloperwala.in/MySgram/backend/uploads/stories/story_1755592537_8.jpg', 'image', '', NULL, '2025-08-19 08:35:37'),
(8, 4, 'https://devloperwala.in/MySgram/backend/uploads/stories/story_1755708239_4.jpg', 'image', '', NULL, '2025-08-20 16:43:59'),
(9, 2, 'https://devloperwala.in/MySgram/backend/uploads/stories/story_1755957019_2.jpg', 'image', '', NULL, '2025-08-23 13:50:20'),
(10, 2, 'https://devloperwala.in/MySgram/backend/uploads/stories/story_1755957435_2.jpg', 'image', '', NULL, '2025-08-23 13:57:17'),
(11, 10, 'https://devloperwala.in/MySgram/backend/uploads/stories/story_1755959068_10.jpg', 'image', '', NULL, '2025-08-23 14:24:28');

-- --------------------------------------------------------

--
-- Table structure for table `story_views`
--

CREATE TABLE `story_views` (
  `id` int NOT NULL,
  `story_id` int NOT NULL,
  `viewer_id` int NOT NULL,
  `viewed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `story_views`
--

INSERT INTO `story_views` (`id`, `story_id`, `viewer_id`, `viewed_at`) VALUES
(1, 3, 2, '2025-08-19 04:24:36'),
(2, 3, 4, '2025-08-19 05:39:41'),
(3, 5, 8, '2025-08-19 08:33:24'),
(4, 4, 8, '2025-08-19 08:33:28'),
(5, 11, 8, '2025-08-23 14:25:22');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `profile_picture` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `bio` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `website` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gender` enum('male','female','other','prefer_not_to_say') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `followers_count` int DEFAULT '0',
  `following_count` int DEFAULT '0',
  `posts_count` int DEFAULT '0',
  `is_private` tinyint(1) DEFAULT '0',
  `auth_provider` enum('email','google','facebook') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'email',
  `auth_provider_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `streak_count` int DEFAULT '0',
  `last_post_date` date DEFAULT NULL,
  `coins` int NOT NULL,
  `is_online` tinyint(1) DEFAULT '0',
  `last_seen` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `full_name`, `profile_picture`, `bio`, `website`, `location`, `phone`, `gender`, `date_of_birth`, `followers_count`, `following_count`, `posts_count`, `is_private`, `auth_provider`, `auth_provider_id`, `is_verified`, `created_at`, `updated_at`, `streak_count`, `last_post_date`, `coins`, `is_online`, `last_seen`) VALUES
(1, 'deepakmishra978', 'dm591959@gmail.com', '', 'Deepak Mishra', 'https://devloperwala.in/MySgram/backend/uploads/profile_photos/profile_1_1754193674.jpg', 'Add a bio to tell people more abut yourself', '', 'Add location', '', '', '0000-00-00', 2, 1, 6, 0, 'google', '113328066871707197885', 1, '2025-08-03 04:00:40', '2025-08-18 09:06:41', 1, '2025-08-03', 1000, 0, '2025-08-17 16:44:08'),
(2, 'deepakmishra744', '121deepak2104@sjcem.edu.in', '', 'Deepak Mishra', 'https://lh3.googleusercontent.com/a/ACg8ocLmG1AHYcuQm6dIzAIcpciwCZgfxvmdyz9UFCmGznq9SVQBmJM=s96-c', 'Add a bio to tell people more about yourself.', '', 'Add location', '', '', '0000-00-00', 3, 5, 1, 0, 'google', '111872514320088981183', 1, '2025-08-03 08:43:08', '2025-08-19 08:34:09', 1, '2025-08-03', 1000, 0, '2025-08-17 16:44:08'),
(3, 'kishorkatkhade272', 'codify2003@gmail.com', '', 'Kishor Katkhade', 'https://lh3.googleusercontent.com/a/ACg8ocLeQiK1ZIIso5s44apcJSxhnh0c2IukTd3BNGNeKgNR3o20eJY=s96-c', 'Add a bio to tell people more about yourself.', '', 'Add location', '', '', '0000-00-00', 3, 1, 0, 0, 'google', '115439120055661777152', 1, '2025-08-05 13:18:56', '2025-08-18 14:33:44', 0, NULL, 1000, 0, '2025-08-17 16:44:08'),
(4, 'yuvrajpatil888', 'patilyuvraj1989@gmail.com', '', 'Yuvraj Patil', 'https://lh3.googleusercontent.com/a/ACg8ocL2m3s3wyhYMaJsh1oYFp139TWo_mInOMBrP6SJtCbUlw8JUw=s96-c', 'Add a bio to tell people more about yourself.', '', 'Add location', '', '', '0000-00-00', 2, 3, 2, 0, 'google', '105716968119443062105', 1, '2025-08-05 17:00:54', '2025-08-19 08:34:09', 1, '2025-08-18', 0, 0, '2025-08-17 16:44:08'),
(5, 'aprantsavagave821', 'aprantsavagave07@gmail.com', '', 'Aprant Savagave', 'https://lh3.googleusercontent.com/a/ACg8ocIqHFc-pykZY_yRZPZwBkPv4KRbT1gzlCsO9UXOnKBvrsD_IA=s96-c', 'Add a bio to tell people more about yourself.', '', 'Add location', '', '', '0000-00-00', 3, 0, 1, 0, 'google', '114117639089945937898', 1, '2025-08-05 17:09:21', '2025-08-18 12:27:49', 1, '2025-08-06', 0, 0, '2025-08-17 16:44:08'),
(6, 'deepakmishra708', 'deepakm7778@gmail.com', '', 'Deepak Mishra', 'https://lh3.googleusercontent.com/a/ACg8ocJdhU7soNL-PDDroRizGHbG48bUxkgSg40px33odzWGrvO4VZItJQ=s96-c', 'Add a bio to tell people more about yourself.', '', 'Add location', '', '', '0000-00-00', 2, 0, 0, 0, 'google', '103874850416146048497', 1, '2025-08-17 16:23:25', '2025-08-18 12:27:41', 0, NULL, 0, 0, '2025-08-17 16:44:08'),
(7, 'sakshimishra309', 'hu12310031@sjchs.edu.in', '', 'Sakshi Mishra', 'https://lh3.googleusercontent.com/a/ACg8ocKItUtEOt5L9prnEm-clArbpwBE1z_wl12YwaMk0_giq9bIvRx2=s96-c', 'Add a bio to tell people more about yourself.', '', 'Add location', '', '', '0000-00-00', 0, 0, 0, 0, 'google', '112818878367948637544', 1, '2025-08-17 17:07:45', '2025-08-17 17:07:45', 0, NULL, 0, 0, '2025-08-17 17:07:45'),
(8, 'kishorkatkhade458', 'katkhadekishorpaypal@gmail.com', '', 'Kishor Katkhade', 'https://lh3.googleusercontent.com/a/ACg8ocJ6JvqQwI55hKz9DVsW1ICNpDwhLtBWVltZx3bsumDGdbWBKw=s96-c', 'Add a bio to tell people more about yourself.', '', 'Add location', '', '', '0000-00-00', 1, 3, 1, 0, 'google', '100621036170012411361', 1, '2025-08-18 07:23:46', '2025-08-23 14:25:15', 1, '2025-08-19', 0, 0, '2025-08-18 07:23:46'),
(9, 'sejalrai586', '123sejal2124@sjcem.edu.in', '', 'Sejal Rai', 'https://lh3.googleusercontent.com/a/ACg8ocIvCXGLtjQlqfUjnXseC4D3ZQVLR1H5yvgKorap-w_eU1KOQQ=s96-c', 'Add a bio to tell people more about yourself.', '', 'Add location', '', '', '0000-00-00', 0, 4, 0, 0, 'google', '103255116621761285021', 1, '2025-08-18 08:50:57', '2025-08-18 09:07:11', 0, NULL, 0, 0, '2025-08-18 08:50:57'),
(10, 'gamingstar811', 'gamingstarunity@gmail.com', '', 'Gaming Star', 'https://lh3.googleusercontent.com/a/ACg8ocI9xpq5IWT3l6aga1PmwvwK6Lg1-3yXN4CF4WFBPgO8mk7-hw=s96-c', 'Add a bio to tell people more about yourself.', '', 'Add location', '', '', '0000-00-00', 1, 0, 0, 0, 'google', '103159217434479245141', 1, '2025-08-23 14:24:05', '2025-08-23 14:25:15', 0, NULL, 0, 0, '2025-08-23 14:24:05'),
(11, 'bhartiyamahitiadhikarallindiartinewsnetwork(rtionl', 'rticheck@gmail.com', '', 'Bhartiya Mahiti Adhikar All India RTi News Network (RTi Online News Media)', 'https://lh3.googleusercontent.com/a/ACg8ocI9cyWTD0q1GSXjoQ9J9gvHhHr_URJ56jWm83EwQDgfsCiPsNZZ=s96-c', 'Add a bio to tell people more about yourself.', '', 'Add location', '', '', '0000-00-00', 0, 0, 0, 0, 'google', '117788208184459920431', 1, '2025-08-30 09:17:35', '2025-08-30 09:17:35', 0, NULL, 0, 0, '2025-08-30 09:17:35');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `chat_rooms`
--
ALTER TABLE `chat_rooms`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `room_id` (`room_id`),
  ADD UNIQUE KEY `room_id_2` (`room_id`),
  ADD UNIQUE KEY `room_id_3` (`room_id`),
  ADD KEY `user_id_2` (`user_id_2`),
  ADD KEY `idx_chat_rooms_users` (`user_id_1`,`user_id_2`);

--
-- Indexes for table `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_post_id` (`post_id`),
  ADD KEY `fk_parent_comment` (`parent_id`);

--
-- Indexes for table `follows`
--
ALTER TABLE `follows`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_follow` (`follower_id`,`following_id`),
  ADD KEY `idx_follower` (`follower_id`),
  ADD KEY `idx_following` (`following_id`);

--
-- Indexes for table `gift_categories`
--
ALTER TABLE `gift_categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `gift_items`
--
ALTER TABLE `gift_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `gift_transactions`
--
ALTER TABLE `gift_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sender_id` (`sender_id`),
  ADD KEY `idx_recipient_id` (`recipient_id`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_gift_transactions_users` (`sender_id`,`recipient_id`);

--
-- Indexes for table `likes`
--
ALTER TABLE `likes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_like` (`user_id`,`post_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_post_id` (`post_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `message_id` (`message_id`),
  ADD KEY `idx_messages_room` (`room_id`),
  ADD KEY `idx_messages_sender` (`sender_id`),
  ADD KEY `idx_is_seen` (`is_seen`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_id` (`post_id`),
  ADD KEY `comment_id` (`comment_id`),
  ADD KEY `idx_recipient_id` (`recipient_id`),
  ADD KEY `idx_sender_id` (`sender_id`),
  ADD KEY `idx_type` (`type`),
  ADD KEY `idx_is_read` (`is_read`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `stories`
--
ALTER TABLE `stories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `story_views`
--
ALTER TABLE `story_views`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_story_view` (`story_id`,`viewer_id`),
  ADD KEY `viewer_id` (`viewer_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_username` (`username`),
  ADD KEY `idx_auth_provider` (`auth_provider`,`auth_provider_id`),
  ADD KEY `idx_users_email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `chat_rooms`
--
ALTER TABLE `chat_rooms`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `comments`
--
ALTER TABLE `comments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `follows`
--
ALTER TABLE `follows`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `gift_categories`
--
ALTER TABLE `gift_categories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `gift_items`
--
ALTER TABLE `gift_items`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=76;

--
-- AUTO_INCREMENT for table `gift_transactions`
--
ALTER TABLE `gift_transactions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `likes`
--
ALTER TABLE `likes`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `posts`
--
ALTER TABLE `posts`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `stories`
--
ALTER TABLE `stories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `story_views`
--
ALTER TABLE `story_views`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `chat_rooms`
--
ALTER TABLE `chat_rooms`
  ADD CONSTRAINT `chat_rooms_ibfk_1` FOREIGN KEY (`user_id_1`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `chat_rooms_ibfk_2` FOREIGN KEY (`user_id_2`) REFERENCES `users` (`id`);

--
-- Constraints for table `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_parent_comment` FOREIGN KEY (`parent_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `follows`
--
ALTER TABLE `follows`
  ADD CONSTRAINT `follows_ibfk_1` FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `follows_ibfk_2` FOREIGN KEY (`following_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `gift_items`
--
ALTER TABLE `gift_items`
  ADD CONSTRAINT `gift_items_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `gift_categories` (`id`);

--
-- Constraints for table `gift_transactions`
--
ALTER TABLE `gift_transactions`
  ADD CONSTRAINT `gift_transactions_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `gift_transactions_ibfk_2` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `likes`
--
ALTER TABLE `likes`
  ADD CONSTRAINT `likes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `likes_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `chat_rooms` (`room_id`),
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notifications_ibfk_3` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notifications_ibfk_4` FOREIGN KEY (`comment_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `posts`
--
ALTER TABLE `posts`
  ADD CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `stories`
--
ALTER TABLE `stories`
  ADD CONSTRAINT `stories_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `story_views`
--
ALTER TABLE `story_views`
  ADD CONSTRAINT `story_views_ibfk_1` FOREIGN KEY (`story_id`) REFERENCES `stories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `story_views_ibfk_2` FOREIGN KEY (`viewer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
