   
-- Section1

ALTER TABLE payments
	ADD COLUMN comment INT;
$$
UPDATE payments AS p, (
	SELECT u.client_id , month(c.created_at) AS month, SUM(CASE WHEN V.IS_VALID = 1 THEN 500 WHEN V.IS_VALID = 0 THEN 100 ELSE NULL END) AS SALARY
	FROM (user_clients AS u INNER JOIN clips AS c ON u.client_id = c.client_id) INNER JOIN votes AS v ON c.clip_id = v.clip_id
	GROUP BY u.client_id, month
	HAVING month<5) AS realp
SET p.comment = CASE WHEN realp.SALARY IS NULL THEN 0 ELSE realp.SALARY - p.wage END
WHERE p.client_id = realp.client_id AND p.month < 5 AND p.month = realp.month ;
$$
UPDATE payments AS p
SET p.wage = p.wage + p.comment
WHERE p.comment IS NOT NULL;
-- Section2

INSERT INTO payments(client_id, month, wage)
SELECT realp.client_id, realp.month, realp.salary AS wage
FROM (
	SELECT u.client_id , month(c.created_at) AS month, SUM(CASE WHEN V.IS_VALID = 1 THEN 500 WHEN V.IS_VALID = 0 THEN 100 ELSE 0 END) AS salary
	FROM user_clients AS u, clips AS c, votes AS v
	WHERE u.client_id = c.client_id AND c.clip_id = v.clip_id
	GROUP BY u.client_id, month
	HAVING month > 0 AND month < 5 ) AS realp
WHERE (realp.client_id, realp.month) NOT IN (SELECT p.client_id, p.month FROM payments AS p);


-- Section3

SELECT MIN(p.comment), MAX(p.comment), SUM(p.comment), AVG(p.comment), IF(SUM(p.comment) > 0, 'debtor', 'creditor')
FROM payments AS p;

-- Section4

SELECT MAX(comment)
FROM payments
WHERE ABS(comment) > (
	SELECT MAX(CASE WHEN comment IS NULL OR comment = 0 THEN wage ELSE 0 END)
	FROM payments);

-- Section5

SELECT p.client_id, p.comment
FROM payments AS p;
$$
ALTER TABLE payments
	DROP COLUMN comment;

-- Section6

SELECT u.client_id, SUM(IF(v.is_valid = 1, 1, 0))/COUNT(c.clip_id) AS t, SUM(IF(c.created_at > now() - INTERVAL 6 DAY AND v.is_valid = 1, 1, 0))/COUNT(IF(c.created_at > now() - INTERVAL 6 DAY, c.clip_id, NULL))  AS w
FROM user_clients AS u, clips AS c, votes AS v
WHERE u.client_id = c.client_id AND c.clip_id = v.clip_id
GROUP BY u.client_id
HAVING t>0.5 AND w>0.7;
    
-- Section7

SELECT SUM(p.wage)*0.15
FROM payments AS p NATURAL JOIN (
	SELECT u.client_id, SUM(IF(v.is_valid = 1, 1, 0))/COUNT(c.clip_id) AS t
	FROM user_clients AS u, clips AS c, votes AS v
	WHERE u.client_id = c.client_id AND c.clip_id = v.clip_id
	GROUP BY u.client_id
	HAVING t>0.6
) AS temp   