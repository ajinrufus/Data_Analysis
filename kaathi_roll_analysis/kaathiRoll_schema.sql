CREATE DATABASE IF NOT EXISTS `kaathi_roll`;

USE `kaathi_roll`;

DROP TABLE IF EXISTS `driver`;
CREATE TABLE `driver` 
(`driver_id` INT NOT NULL PRIMARY KEY, 
`reg_date` DATE); 

INSERT INTO `driver`(`driver_id`, `reg_date`) 
 VALUES (1,'2024-08-01'),
(2,'2024-08-02'),
(3,'2024-08-03'),
(4,'2024-08-05');

DROP TABLE IF EXISTS `ingredients`;
CREATE TABLE `ingredients`
(`ingredients_id` TINYINT PRIMARY KEY, `ingredients_name` VARCHAR(30) NOT NULL); 

INSERT INTO ingredients(`ingredients_id`, `ingredients_name`) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');


CREATE TABLE IF NOT EXISTS `rolls`
(`roll_id` TINYINT PRIMARY KEY,
`roll_name` varchar(30) NOT NULL); 

INSERT INTO `rolls`(`roll_id` , `roll_name`) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

# junction table
drop table if exists `rolls_recipes`;
CREATE TABLE `rolls_recipes`
(`roll_id` TINYINT NOT NULL,
`ingredients` TINYINT NOT NULL,
FOREIGN KEY(`roll_id`) REFERENCES `rolls`(`roll_id`),
FOREIGN KEY(`ingredients`) REFERENCES `ingredients`(`ingredients_id`));

INSERT INTO `rolls_recipes`(`roll_id`, `ingredients`) 
 VALUES
(1,2), (1,3), (1,4), (1,5), (1,6), (1,7), (1,8), (1,10),
(2,4), (2,6), (2,7), (2,9), (2,11), (2,12);


DROP TABLE IF EXISTS `driver_order`;
CREATE TABLE `driver_order`
(`order_id` INT NOT NULL AUTO_INCREMENT,
`driver_id` INT NOT NULL,
`pickup_time` DATETIME, 
`distance` TINYINT,
`duration_mins` SMALLINT,`cancellation` VARCHAR(23),
FOREIGN KEY(`driver_id`) REFERENCES `driver`(`driver_id`),
FOREIGN KEY(`order_id`) REFERENCES `customer_orders`(`order_id`));

INSERT INTO `driver_order`(`order_id`, `driver_id`, `pickup_time`, `distance`, `duration_mins`, `cancellation`) 
 VALUES(1,1,'2024-08-02 18:15:34',20,32,''),
(2,1,'2024-08-05 19:10:54',20, 27,''),
(3,1,'2024-08-05 00:12:37',13.4, 20,'NaN'),
(4,2,'2024-08-06 13:53:03', 23.4, 40,'NaN'),
(5,3,'2024-08-06 21:10:57', 10, 15,'NaN'),
(6,3, NULL, NULL , NULL,'Cancellation'),
(7,2,'2024-08-07 21:30:45',25, 25, NULL),
(8,2,'2024-08-04 00:15:02', 23.4, 15, NULL),
(9,2, NULL, NULL, NULL,'Customer Cancellation'),
(10,1,'2024-08-09 18:50:20', 10, 10, NULL);


drop table if exists `customer_orders`;
CREATE TABLE `customer_orders`
(`order_id` INT PRIMARY KEY,
`customer_id` INT NOT NULL,
`n_veg` SMALLINT NOT NULL,
`n_nveg` SMALLINT NOT NULL,
`not_include_items` VARCHAR(20),
`extra_items_included` VARCHAR(20),
`order_date` DATETIME NOT NULL);
#FOREIGN KEY(`roll_id`) REFERENCES `rolls`(`roll_id`));

INSERT INTO `customer_orders`(`order_id`,`customer_id`,`n_veg`, `n_nveg`, `not_include_items`,`extra_items_included`,`order_date`)
values (1,101, 2, 1,'','','2024-08-02  18:05:02'),
(2,101,3, 2, '','','2024-08-05 19:00:54'),
(3,102,1, 0, '','','2024-08-05 00:00:37'),
(4,103,5, 10, '4','','2024-08-06 13:40:03'),
(5,103,3, 2, '4','','2024-08-06 21:00:46'),
(6,103,5, 3, '4','','2024-08-06 18:00:57'),
(7,104,4, 2, null,'1','2024-08-07 21:00:57'),
(8,101,2, 1, null,null,'2024-08-04 00:02:13'),
(9,105,2, 15, null,'1','2024-08-07 21:20:45'),
(10,102,1, 6, null,null,'2024-08-09 18:45:33'),
(11,103,1, 7, '4','1,5','2024-08-09 11:15:59'),
(12,104,1, 0, null,null,'2024-08-09 18:34:49'),
(13,104,1, 3, '2,6','1,4','2024-08-10 18:34:49'),
(14,102,2, 5, '','NaN','2024-08-11 23:25:23');


SELECT * FROM `driver`;
SELECT * FROM `driver_order`;
SELECT * FROM `rolls`;
SELECT * FROM `ingredients`;
SELECT * FROM `customer_orders`;
SELECT * FROM `rolls_recipes`;

-- ------------------------ Queries --------------------------

####### 1. How many rolls were ordered? #######
SELECT (SUM(`n_veg`) + SUM(`n_nveg`)) AS `tot_orders`
FROM `customer_orders`;

####### How many unique customer have made orders? ######
SELECT COUNT(DISTINCT(`customer_id`)) AS `n_customers`
FROM `customer_orders`;

####### how many sucessful order were made by each driver ######

/* clean cancellation column */
UPDATE `driver_order` 
SET `cancellation` = (CASE 
WHEN `cancellation` IN ('Cancellation', 'Customer Cancellation') THEN 1
ELSE 0
END);

ALTER TABLE `driver_order` 
MODIFY `cancellation` 
TINYINT NOT NULL;

DESCRIBE `driver_order`;

/* clean cancellation column */

SELECT `driver_id`, COUNT(`driver_id`) AS `successful_orders`
FROM `driver_order`
WHERE `cancellation` != 1
GROUP BY `driver_id`;

####### how many of each type of roll was delivered? ######

SELECT SUM(`n_veg`) AS `n_veg_delivered`, SUM(`n_nveg`) AS `n_nveg_delivered`
FROM `customer_orders` 
WHERE `order_id` IN (
	SELECT `order_id` FROM `driver_order`
	WHERE `cancellation` != 1
	);

SELECT SUM(`n_veg`) AS `n_veg_delivered`, SUM(`n_nveg`) AS `n_nveg_delivered`
FROM `customer_orders` 
WHERE `order_id` IN (
	SELECT `order_id` FROM `driver_success`
	WHERE `cancellation` != 1
	);

####### maximum number of rolls delivered in a single order #######

SELECT `customer_id`, SUM(`n_veg`) + SUM(`n_nveg`) AS `tot_delivered` FROM 
`customer_orders` WHERE
`order_id` IN (SELECT `order_id` FROM 
`customer_orders` WHERE
`order_id` IN
	(SELECT `order_id` FROM
	`driver_order` WHERE `cancellation` = 0)
	) GROUP BY `order_id` ORDER BY `tot_delivered` DESC LIMIT 1;

####### For each customer, how many delivered rolls had atleast one extras ##########

/* need to perform cleaning first of the extra_items_included column */
# without altering the actual data

CREATE VIEW `extras` AS 
SELECT `order_id`, `extra_items_included`, (
CASE WHEN `extra_items_included` IN (NULL, 'NaN', ' ') THEN '0'
ELSE `extra_items_included`
END) AS `extra_items`
FROM `customer_orders` WHERE 
`order_id` IN
	(SELECT `order_id` FROM
	`driver_order` WHERE `cancellation` = 0);

/* need to perform cleaning first of the extra_items_included column */

SELECT COUNT(`extra_items`) AS `n_cust_ext_delivered`
FROM `extras`
WHERE `extra_items` != 0;
SELECT * FROM `rolls_recipes`;

####### how many rolls were delivered that had both exclusions and extras #######
SELECT COUNT(`order_id`) AS `excl_extra`
FROM `customer_orders`
WHERE `order_id` IN(
	SELECT `order_id`
	FROM `extras`
	WHERE `extra_items` != 0);

###### total number of rolls ordered in a day ##########

SELECT (SUM(`n_veg`) + SUM(`n_nveg`)) AS `day's qty`, 
DATE(`order_date`) AS `day_name`
FROM `customer_orders` 
GROUP BY `day_name` 
ORDER BY `day's qty`;

###### total number of orders for each hour of the day ##########

SELECT `hr_range`, COUNT(`hr_range`)  AS `hourly_orders`
FROM (
    SELECT *,
           CONCAT(CAST(HOUR(`order_date`) AS CHAR), '-', 
           CAST(HOUR(`order_date`) + 1 AS CHAR)) AS `hr_range`
    FROM `customer_orders`
) AS derived_table_alias
GROUP BY `hr_range` ORDER BY `hourly_orders` DESC;

########## average time difference between time of order and the pickup for each driver ###########

SELECT `do`.`driver_id`, ROUND(AVG(TIMESTAMPDIFF(MINUTE, `co`.`order_date`, `do`.`pickup_time`)),2) AS `avg_time_tkn (in mins)` 
FROM `customer_orders` AS `co`
JOIN
	(SELECT `order_id`, `pickup_time`, `driver_id` 
	FROM `driver_order` 
    WHERE `pickup_time` IS NOT NULL) AS `do`
ON `do`.`order_id` = `co`.`order_id`
GROUP BY `do`.`driver_id`;

#### is there any relationship between number of rolls and how long the order takes to prepare ####

SELECT `co`.`order_id`, 
ROUND(TIMESTAMPDIFF(MINUTE, `co`.`order_date`, `do`.`pickup_time`),2) AS `time_tkn (in mins)` ,
(`co`.`n_veg` + `co`.`n_nveg`) AS `n_orders`
FROM `customer_orders` AS `co`
JOIN
	(SELECT `order_id`, `pickup_time`, `driver_id` 
	FROM `driver_order` 
    WHERE `pickup_time` IS NOT NULL) AS `do`
ON `do`.`order_id` = `co`.`order_id`;

#### average distance travelled for each customer ######

SELECT `customer_id`, ROUND(AVG(`do`.`distance`), 2) AS `avg_dist_per_customer`
FROM `customer_orders` AS `co`
JOIN
(SELECT `order_id`, `distance`
	FROM `driver_order` 
    WHERE `pickup_time` IS NOT NULL) AS `do`
    ON `do`.`order_id` = `co`.`order_id`
GROUP BY `customer_id`;

####### average speed of delivery of each order ########

SELECT ROUND(`distance` *  `duration_mins`/60, 2) AS `speed (kmph)`
	FROM `driver_order` 
    WHERE `pickup_time` IS NOT NULL;
    
###### what is the successful delivery percentage for each driver ########

# creating a view of aliased cancellation value
DROP VIEW `driver_success`;
CREATE VIEW `driver_success` AS
SELECT `order_id`,
`driver_id`,
`pickup_time`,
`distance`,
`duration_mins`,(
CASE WHEN TRIM(`cancellation`) IN ('Cancellation', 'customer_cancellation') THEN 1
ELSE 0
END) AS `cancellation` FROM `driver_order`;


SELECT `t`.`driver_id`, ROUND(`s`.`success`/`t`.`total_count` * 100, 2) AS `success_dly_pct` FROM
(SELECT `driver_id`, COUNT(*) AS `success` FROM `driver_success` 
WHERE `cancellation` = 0
GROUP BY `driver_id`) AS `s`
RIGHT JOIN
(SELECT `driver_id`,COUNT(*) `total_count` 
FROM `driver_success` AS `ds`
GROUP BY `driver_id`) AS `t`
ON `t`.`driver_id` = `s`.`driver_id`;

# or - easier method #

SELECT `driver_id`,
ROUND((COUNT(*)-SUM(`cancellation`))*100/COUNT(*),2) AS `success_dly_pct` 
FROM `driver_success`
GROUP BY `driver_id`;