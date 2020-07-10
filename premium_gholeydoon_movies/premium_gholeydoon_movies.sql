-- Section1

CREATE TRIGGER gender_refactor BEFORE INSERT ON actor FOR EACH ROW
BEGIN
	IF NEW.gender IS NULL THEN SET NEW.gender = 'other';
    END IF;
END;	

-- Section2

SELECT m1.id, MIN(m1.year - m2.year) AS mindif
FROM (SELECT a.id, m.year, m.id As movie_id
	FROM actor AS a, cast AS c, movie As m 
    WHERE a.id = c.pid AND c.mid = m.id) AS m1,
    (SELECT a.id, m.year, m.id As movie_id
	FROM actor AS a, cast AS c, movie As m 
    WHERE a.id = c.pid AND c.mid = m.id) AS m2
WHERE m1.year >= m2.year AND m1.id = m2.id AND m1.movie_id <> m2.movie_id
GROUP BY m1.id
ORDER BY  mindif DESC, m1.id ASC;

-- Section3
 SELECT DISTINCT d.id, d.first_name, d.last_name, ACTOR_NUMBER.num
 FROM director AS d JOIN (SELECT d.id, COUNT(DISTINCT a.id) AS num
    FROM actor AS a RIGHT JOIN cast AS c ON a.id = c.pid RIGHT JOIN movie As m ON c.mid = m.id RIGHT JOIN movie_director AS md ON m.id = md.mid RIGHT JOIN director AS d ON md.did = d.id
    GROUP BY d.id) AS ACTOR_NUMBER ON d.id = ACTOR_NUMBER.id
ORDER BY num DESC, d.id ASC
limit 3;

-- Section4

CREATE VIEW Actors_View AS
SELECT a.first_name, a.last_name, MOVIE_NUMBER.num, (SELECT COUNT(d.id) FROM director AS d) - DIRECTOR_NUMBER.num, CO_STAR.LN 
FROM actor AS a LEFT JOIN
	(SELECT a.id, COUNT(DISTINCT m.id) AS num
    FROM actor AS a LEFT JOIN cast AS c ON a.id = c.pid LEFT JOIN movie As m ON c.mid = m.id
    GROUP BY a.id) 
    AS MOVIE_NUMBER ON a.id = MOVIE_NUMBER.id LEFT JOIN
    (SELECT a.id, COUNT(DISTINCT d.id) AS num
    FROM actor AS a LEFT JOIN cast AS c ON a.id = c.pid LEFT JOIN movie As m ON c.mid = m.id LEFT JOIN movie_director AS md ON m.id = md.mid LEFT JOIN director AS d ON md.did = d.id
    GROUP BY a.id) 
    AS DIRECTOR_NUMBER ON a.id = DIRECTOR_NUMBER.id LEFT JOIN
    (SELECT CO_LIST.ID , MIN(CO_LIST.LN) AS LN, CO_LIST.NUM
	FROM 
		(SELECT a1.id AS ID, a2.last_name AS LN, COUNT(DISTINCT c1.mid) AS NUM
		FROM actor AS a1, cast AS c1, cast AS c2, actor AS a2
		WHERE a1.id = c1.pid AND c1.mid = c2.mid AND c2.pid = a2.id AND a1.id <> a2.id
		GROUP BY a1.id, a2.last_name) AS CO_LIST NATURAL JOIN
        (SELECT CL.id AS ID, MAX(CL.num) AS NUM
        FROM 
			(SELECT a1.id, a2.last_name, COUNT(DISTINCT c1.mid) AS num
			FROM actor AS a1, cast AS c1, cast AS c2, actor AS a2
			WHERE a1.id = c1.pid AND c1.mid = c2.mid AND c2.pid = a2.id AND a1.id <> a2.id
			GROUP BY a1.id, a2.last_name) AS CL
		GROUP BY CL.id) AS MAX_CO
	GROUP BY CO_LIST.ID, CO_LIST.NUM
	)
	AS CO_STAR ON a.id = CO_STAR.ID;


-- Section5

ALTER TABLE cast
	ADD COLUMN last_modified DATETIME DEFAULT NULL;
$$
CREATE TRIGGER update_last_modified_update
BEFORE UPDATE ON cast FOR EACH ROW
BEGIN
	SET NEW.last_modified = CURRENT_TIMESTAMP();
END  
$$
CREATE TRIGGER update_last_modified_insert
BEFORE INSERT ON cast FOR EACH ROW
BEGIN
	SET NEW.last_modified = CURRENT_TIMESTAMP();
END;   