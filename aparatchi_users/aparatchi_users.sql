-- Section1
	SELECT CONCAT(u.first_name, ' ', u.last_name) AS username, SUM(v.is_valid) AS 'up vote', COUNT(v.is_valid)-SUM(v.is_valid) AS 'down vote'
	FROM user_clients AS u, clips AS c, votes AS v
	WHERE u.client_id = c.client_id && c.clip_id = v.clip_id
	GROUP BY u.first_name, u.last_name ;
    
-- Section2
	SELECT u.client_id, SUM(IF(v.is_valid = 1, 1, 0))/COUNT(c.clip_id) AS 'total precision', SUM(IF(c.created_at > now() - INTERVAL 6 DAY && v.is_valid = 1, 1, 0))/COUNT(IF(c.created_at > now() - INTERVAL 6 DAY, c.clip_id, NULL))  AS 'weekly precision'
    FROM user_clients AS u, clips AS c, votes AS v
    WHERE u.client_id = c.client_id && c.clip_id = v.clip_id
    GROUP BY u.client_id;
-- Section3
	SELECT u.client_id, 
	CASE
		WHEN SUM(IF(c.created_at > now() - INTERVAL 6 DAY && v.is_valid = 1, 1, 0))/COUNT(IF(c.created_at > now() - INTERVAL 6 DAY, c.clip_id, NULL)) >= SUM(IF(v.is_valid = 1, 1, 0))/COUNT(c.clip_id) THEN 'appropriate'
		ELSE 'inappropriate'
	END AS 'improvement status'
	FROM user_clients AS u, clips AS c, votes AS v
    WHERE u.client_id = c.client_id && c.clip_id = v.clip_id
	GROUP BY u.client_id ;
    
-- Section4
	SELECT p.age, AVG(p.amount)  'average precision'
	FROM (
		SELECT  u.client_id, u.age, SUM(IF(v.is_valid = 1, 1, 0))/COUNT(c.clip_id) AS amount
		FROM user_clients AS u, clips AS c, votes AS v
		WHERE u.client_id = c.client_id && c.clip_id = v.clip_id
		GROUP BY u.client_id) AS p
	GROUP BY p.age ;
    
-- Section5
	SELECT DISTINCT u.age
	FROM user_clients AS u,( 
		SELECT u.age ,COUNT(*) AS works
		FROM user_clients AS u, clips AS c
		WHERE u.client_id = c.client_id
		GROUP BY u.age) AS w
	WHERE w.age = u.age && w.works = ( SELECT MAX(Works) FROM ( 
		SELECT u.age ,COUNT(*) AS works
		FROM user_clients AS u, clips AS c
		WHERE u.client_id = c.client_id
		GROUP BY u.age) AS w);
    
-- Section6
	SELECT u.age
	FROM user_clients AS u,( 
		SELECT u.client_id ,COUNT(*) AS works
		FROM user_clients AS u, clips AS c
		WHERE u.client_id = c.client_id
		GROUP BY u.client_id) AS w
	WHERE w.client_id = u.client_id && w.works = ( SELECT MAX(Works) FROM ( 
		SELECT u.client_id ,COUNT(*) AS works
		FROM user_clients AS u, clips AS c
		WHERE u.client_id = c.client_id
		GROUP BY u.client_id) AS w);
    

