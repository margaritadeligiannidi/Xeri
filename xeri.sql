-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.32-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.14.0.7165
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table xeri.cards
DROP TABLE IF EXISTS `cards`;
CREATE TABLE IF NOT EXISTS `cards` (
  `card_id` int(11) NOT NULL AUTO_INCREMENT,
  `value` enum('A','2','3','4','5','6','7','8','9','10','J','Q','K') NOT NULL,
  `suit` enum('H','D','C','S') NOT NULL,
  `location` enum('deck','table','hand_P1','hand_P2','captured_P1','captured_P2') DEFAULT NULL,
  `table_order` int(11) DEFAULT NULL,
  PRIMARY KEY (`card_id`)
) ENGINE=InnoDB AUTO_INCREMENT=157 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table xeri.cards: ~52 rows (approximately)
INSERT INTO `cards` (`card_id`, `value`, `suit`, `location`, `table_order`) VALUES
	(105, 'A', 'H', 'hand_P2', NULL),
	(106, 'A', 'D', 'deck', NULL),
	(107, 'A', 'C', 'deck', NULL),
	(108, 'A', 'S', 'deck', NULL),
	(109, '2', 'H', 'deck', NULL),
	(110, '2', 'D', 'deck', NULL),
	(111, '2', 'C', 'deck', NULL),
	(112, '2', 'S', 'hand_P2', NULL),
	(113, '3', 'H', 'deck', NULL),
	(114, '3', 'D', 'deck', NULL),
	(115, '3', 'C', 'deck', NULL),
	(116, '3', 'S', 'table', 5),
	(117, '4', 'H', 'hand_P1', NULL),
	(118, '4', 'D', 'hand_P1', NULL),
	(119, '4', 'C', 'deck', NULL),
	(120, '4', 'S', 'hand_P1', NULL),
	(121, '5', 'H', 'deck', NULL),
	(122, '5', 'D', 'deck', NULL),
	(123, '5', 'C', 'table', 1),
	(124, '5', 'S', 'deck', NULL),
	(125, '6', 'H', 'hand_P2', NULL),
	(126, '6', 'D', 'hand_P1', NULL),
	(127, '6', 'C', 'deck', NULL),
	(128, '6', 'S', 'hand_P2', NULL),
	(129, '7', 'H', 'deck', NULL),
	(130, '7', 'D', 'deck', NULL),
	(131, '7', 'C', 'deck', NULL),
	(132, '7', 'S', 'table', 2),
	(133, '8', 'H', 'deck', NULL),
	(134, '8', 'D', 'deck', NULL),
	(135, '8', 'C', 'hand_P1', NULL),
	(136, '8', 'S', 'deck', NULL),
	(137, '9', 'H', 'deck', NULL),
	(138, '9', 'D', 'hand_P2', NULL),
	(139, '9', 'C', 'deck', NULL),
	(140, '9', 'S', 'deck', NULL),
	(141, '10', 'H', 'deck', NULL),
	(142, '10', 'D', 'deck', NULL),
	(143, '10', 'C', 'deck', NULL),
	(144, '10', 'S', 'deck', NULL),
	(145, 'J', 'H', 'deck', NULL),
	(146, 'J', 'D', 'deck', NULL),
	(147, 'J', 'C', 'deck', NULL),
	(148, 'J', 'S', 'deck', NULL),
	(149, 'Q', 'H', 'deck', NULL),
	(150, 'Q', 'D', 'deck', NULL),
	(151, 'Q', 'C', 'hand_P2', NULL),
	(152, 'Q', 'S', 'deck', NULL),
	(153, 'K', 'H', 'deck', NULL),
	(154, 'K', 'D', 'deck', NULL),
	(155, 'K', 'C', 'table', 3),
	(156, 'K', 'S', 'table', 4);

-- Dumping structure for table xeri.game_status
DROP TABLE IF EXISTS `game_status`;
CREATE TABLE IF NOT EXISTS `game_status` (
  `status` enum('not active','started','ended','aborted') DEFAULT NULL,
  `p_turn` enum('P1','P2') DEFAULT NULL,
  `result` enum('P1','P2','D') DEFAULT NULL,
  `last_change` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_event` varchar(64) DEFAULT NULL,
  `p1_score` int(11) DEFAULT 0,
  `p2_score` int(11) DEFAULT 0,
  `last_capturer` enum('P1','P2') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table xeri.game_status: ~1 rows (approximately)
INSERT INTO `game_status` (`status`, `p_turn`, `result`, `last_change`, `last_event`, `p1_score`, `p2_score`, `last_capturer`) VALUES
	('aborted', 'P2', 'P2', '2026-01-13 10:20:38', 'PLAYER_QUIT_P1', 0, 0, NULL);

-- Dumping structure for procedure xeri.play_card
DROP PROCEDURE IF EXISTS `play_card`;
DELIMITER //
CREATE PROCEDURE `play_card`(
	IN `p_player` CHAR(2),
	IN `p_card_id` INT
)
proc: BEGIN

    DECLARE card_value VARCHAR(2);
    DECLARE last_value VARCHAR(2);
    DECLARE table_count INT DEFAULT 0;
    DECLARE next_order INT;
    DECLARE current_turn CHAR(2);

    DECLARE p1_count INT;
    DECLARE p2_count INT;
    DECLARE deck_count INT;
    DECLARE table_left INT;

    DECLARE p1_pile INT DEFAULT 0;
    DECLARE p2_pile INT DEFAULT 0;

    DECLARE p1_score INT DEFAULT 0;
    DECLARE p2_score INT DEFAULT 0;
    DECLARE result CHAR(2) DEFAULT NULL;

    /* =====================================
        Έλεγχος σειράς
    ===================================== */
    SELECT p_turn INTO current_turn FROM game_status LIMIT 1;
    IF current_turn <> p_player THEN
        LEAVE proc;
    END IF;

    /* =====================================
       Έλεγχος έγκυρου χαρτιού
    ===================================== */
    SELECT value INTO card_value
    FROM cards
    WHERE card_id = p_card_id
      AND location = CONCAT('hand_', p_player);

    IF card_value IS NULL THEN
        LEAVE proc;
    END IF;

    /*  καταγραφή πραγματικής κίνησης */
    UPDATE players
    SET last_action = CURRENT_TIMESTAMP
    WHERE player_id = p_player;

    /* =====================================
        Παίζουμε χαρτί στο τραπέζι
    ===================================== */
    SELECT COUNT(*) INTO table_count
    FROM cards
    WHERE location = 'table';

    SELECT value INTO last_value
    FROM cards
    WHERE location = 'table'
    ORDER BY table_order DESC
    LIMIT 1;

    SELECT IFNULL(MAX(table_order),0) + 1
    INTO next_order
    FROM cards
    WHERE location = 'table';

    UPDATE cards
    SET location = 'table',
        table_order = next_order
    WHERE card_id = p_card_id;

    /* =====================================
        Μάζεμα + Ξερή
    ==================================== */
    IF table_count > 0
   AND (card_value = 'J' OR last_value = card_value) THEN

        UPDATE game_status
        SET last_capturer = p_player;

        IF table_count = 1 THEN
            IF card_value = 'J' THEN
                UPDATE players
                SET xeri_j_count = xeri_j_count + 1
                WHERE player_id = p_player;

                UPDATE game_status
                SET last_event = CONCAT(p_player, '_XERI_J_', UNIX_TIMESTAMP());
            ELSE
                UPDATE players
                SET xeri_count = xeri_count + 1
                WHERE player_id = p_player;

                UPDATE game_status
                SET last_event = CONCAT(p_player, '_XERI', UNIX_TIMESTAMP());
            END IF;
        END IF;

        UPDATE cards
        SET location = CONCAT('captured_', p_player),
            table_order = NULL
        WHERE location = 'table';
    END IF;

    /* =====================================
        Αλλαγή σειράς
    ===================================== */
    UPDATE game_status
    SET p_turn = IF(p_player='P1','P2','P1'),
        last_change = CURRENT_TIMESTAMP;

    /* =====================================
        Μοίρασμα
    ===================================== */
    SELECT COUNT(*) INTO p1_count FROM cards WHERE location='hand_P1';
    SELECT COUNT(*) INTO p2_count FROM cards WHERE location='hand_P2';
    SELECT COUNT(*) INTO deck_count FROM cards WHERE location='deck';

    IF p1_count = 0 AND p2_count = 0 AND deck_count >= 12 THEN
        UPDATE cards SET location='hand_P1'
        WHERE card_id IN (
            SELECT card_id FROM (
                SELECT card_id FROM cards
                WHERE location='deck'
                ORDER BY RAND()
                LIMIT 6
            ) t
        );

        UPDATE cards SET location='hand_P2'
        WHERE card_id IN (
            SELECT card_id FROM (
                SELECT card_id FROM cards
                WHERE location='deck'
                ORDER BY RAND()
                LIMIT 6
            ) t
        );
    END IF;

    /* =====================================
        Τέλος παιχνιδιού – ΣΚΟΡ
    ===================================== */
    SELECT COUNT(*) INTO deck_count FROM cards WHERE location='deck';
    SELECT COUNT(*) INTO p1_count FROM cards WHERE location='hand_P1';
    SELECT COUNT(*) INTO p2_count FROM cards WHERE location='hand_P2';
    SELECT COUNT(*) INTO table_left FROM cards WHERE location='table';

    IF p1_count = 0 AND p2_count = 0 AND deck_count < 12 THEN

        IF table_left > 0 THEN
            UPDATE cards
            SET location = CONCAT(
                'captured_',
                (SELECT last_capturer FROM game_status)
            ),
            table_order = NULL
            WHERE location='table';
        END IF;

        /* περισσότερα χαρτιά */
        SELECT COUNT(*) INTO p1_pile FROM cards WHERE location='captured_P1';
        SELECT COUNT(*) INTO p2_pile FROM cards WHERE location='captured_P2';

        IF p1_pile > p2_pile THEN
            SET p1_score = p1_score + 3;
        ELSEIF p2_pile > p1_pile THEN
            SET p2_score = p2_score + 3;
        END IF;

        /* 2♠ */
        IF EXISTS (
            SELECT 1 FROM cards
            WHERE location='captured_P1' AND value='2' AND suit='S'
        ) THEN SET p1_score = p1_score + 1; END IF;

        IF EXISTS (
            SELECT 1 FROM cards
            WHERE location='captured_P2' AND value='2' AND suit='S'
        ) THEN SET p2_score = p2_score + 1; END IF;

        /* 10♦ */
        IF EXISTS (
            SELECT 1 FROM cards
            WHERE location='captured_P1' AND value='10' AND suit='D'
        ) THEN SET p1_score = p1_score + 1; END IF;

        IF EXISTS (
            SELECT 1 FROM cards
            WHERE location='captured_P2' AND value='10' AND suit='D'
        ) THEN SET p2_score = p2_score + 1; END IF;

        /* φιγούρες + 10 */
        SELECT COUNT(*) INTO p1_pile
        FROM cards
        WHERE location='captured_P1'
          AND (value IN ('K','Q','J') OR (value='10' AND suit<>'D'));

        SELECT COUNT(*) INTO p2_pile
        FROM cards
        WHERE location='captured_P2'
          AND (value IN ('K','Q','J') OR (value='10' AND suit<>'D'));

        SET p1_score = p1_score + p1_pile;
        SET p2_score = p2_score + p2_pile;

        /* ξερές */
        SELECT (xeri_count * 10 + xeri_j_count * 20)
        INTO p1_pile FROM players WHERE player_id='P1';

        SELECT (xeri_count * 10 + xeri_j_count * 20)
        INTO p2_pile FROM players WHERE player_id='P2';

        SET p1_score = p1_score + p1_pile;
        SET p2_score = p2_score + p2_pile;

        /* νικητής */
        IF p1_score > p2_score THEN
            SET result = 'P1';
        ELSEIF p2_score > p1_score THEN
            SET result = 'P2';
        ELSE
            SET result = 'D';
        END IF;

        UPDATE game_status
        SET status='ended',
            p1_score=p1_score,
            p2_score=p2_score,
            result=result,
				last_change=NULL;
    END IF;

END//
DELIMITER ;

-- Dumping structure for table xeri.players
DROP TABLE IF EXISTS `players`;
CREATE TABLE IF NOT EXISTS `players` (
  `player_id` enum('P1','P2') NOT NULL,
  `username` varchar(20) DEFAULT NULL,
  `token` varchar(100) DEFAULT NULL,
  `last_action` timestamp NULL DEFAULT NULL,
  `xeri_count` int(11) DEFAULT 0,
  `xeri_j_count` int(11) DEFAULT 0,
  `last_seen` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table xeri.players: ~2 rows (approximately)
INSERT INTO `players` (`player_id`, `username`, `token`, `last_action`, `xeri_count`, `xeri_j_count`, `last_seen`) VALUES
	('P1', 'nikos', '3f42a9387d843d7519f04fe901055609', '2026-01-13 10:20:38', 0, 0, '2026-01-13 10:21:30'),
	('P2', 'Iee2021034', 'be2a53e485cfd4439d89d8e03bd6ba1d', '2026-01-13 10:20:08', 0, 0, '2026-01-13 10:21:31');

-- Dumping structure for procedure xeri.start_game
DROP PROCEDURE IF EXISTS `start_game`;
DELIMITER //
CREATE PROCEDURE `start_game`()
BEGIN

    /*  reset game_status */
    UPDATE game_status
    SET
        status = 'started',
        p_turn = 'P1',
        result = NULL,
        last_change = CURRENT_TIMESTAMP,
        last_event = NULL,
        p1_score = 0,
        p2_score = 0,
        last_capturer = NULL;

    /*  reset παικτών */
    UPDATE players
    SET
        xeri_count = 0,
        xeri_j_count = 0;

    /*  reset τράπουλας */
    UPDATE cards
    SET
        location = 'deck',
        table_order = NULL;

    /*  κάρτες στο τραπέζι (ΧΩΡΙΣ J) */
    SET @row := 0;

    UPDATE cards
    SET
        location = 'table',
        table_order = (@row := @row + 1)
    WHERE card_id IN (
        SELECT card_id FROM (
            SELECT card_id
            FROM cards
            WHERE location = 'deck'
              AND value != 'J'
            ORDER BY RAND()
            LIMIT 4
        ) t
    );

    /*  κάρτες στον P1 */
    UPDATE cards
    SET location = 'hand_P1'
    WHERE card_id IN (
        SELECT card_id FROM (
            SELECT card_id
            FROM cards
            WHERE location = 'deck'
            ORDER BY RAND()
            LIMIT 6
        ) t
    );

    /*  κάρτες στον P2 */
    UPDATE cards
    SET location = 'hand_P2'
    WHERE card_id IN (
        SELECT card_id FROM (
            SELECT card_id
            FROM cards
            WHERE location = 'deck'
            ORDER BY RAND()
            LIMIT 6
        ) t
    );

    UPDATE game_status
    SET last_event = CONCAT('NEW_GAME_', UNIX_TIMESTAMP()),
    last_change = CURRENT_TIMESTAMP;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
