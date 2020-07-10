  -- Section1
SELECT a.id, a.first_name, a.last_name
FROM actor AS a, cast AS c1, cast AS c2, movie AS m1, movie AS m2
WHERE a.id = c1.pid && c1.mid = m1.id && m1.id IN (
	SELECT m.id
    FROM movie AS m
    WHERE m.year BETWEEN 1980 AND 1995)
    && a.id = c2.pid && c2.mid = m2.id && m2.id IN (
    SELECT m.id
    FROM movie AS m
    WHERE m.year BETWEEN 2005 AND 2010)
GROUP BY a.id;

-- Section2
SELECT m.id, m.title
FROM movie AS m, (
    SELECT m.year, m.rating
    FROM movie AS m
    WHERE m.title = 'ALABAMA DEVIL') AS ad
WHERE m.year = ad.year && m.rating > ad.rating ;

-- Section3
SELECT a.id, a.first_name, a.last_name
FROM actor AS a, cast AS c, movie AS m, (
	SELECT m.id
    FROM movie AS m
    WHERE m.title = 'ALASKA PHANTOM') AS ap
WHERE a.id = c.pid && c.mid = m.id && m.id =ap.id;

-- Section4
SELECT d.id AS id, d.first_name, d.last_name, COUNT(md.mid) AS numberOfMovies
FROM director AS d LEFT JOIN movie_director AS md ON d.id = md.did
GROUP BY d.id
ORDER BY numberOfMovies DESC, id ASC;

-- Section5
SELECT m.title, nc.numberofCast
FROM movie AS m,( 
		SELECT m.id ,COUNT(c.pid) AS numberofCast
		FROM movie AS m, cast As c
		WHERE m.id = c.mid
		GROUP BY m.id) AS nc
WHERE m.id = nc.id && nc.numberofCast = (
	SELECT MAX(numberofCast) FROM(
		SELECT m.id ,COUNT(c.pid) AS numberofCast
		FROM movie AS m, cast As c
		WHERE m.id = c.mid
		GROUP BY m.id) AS nc);

-- Section6
SELECT a.id, a.first_name, a.last_name, nd.numberofDirector
FROM actor as a,(
	SELECT a.id, COUNT(DISTINCT md.did) AS numberofDirector
    FROM actor AS a, cast AS c, movie AS m, movie_director AS md
    WHERE a.id = c.pid && c.mid = m.id && m.id = md.mid
    GROUP BY a.id) AS nd
WHERE a.id = nd.id && nd.numberofDirector >= 10;

-- Section7
SELECT m.id, m.title
FROM movie AS m, (
	SELECT m.id, SUM(IF(a.gender = 1,1,0))/SUM(IF(a.gender = 2,1,0)) AS FoverM
    FROM movie AS m, cast AS c, actor AS a
    WHERE m.id = c.mid && c.pid = a.id
    GROUP BY m.id) AS fm
WHERE m.id = fm.id && fm.FoverM > 1;

-- Section8
SELECT am.first_name, am.last_name, af.first_name, af.last_name, COUNT(*) AS num
FROM actor AS am, cast As cm, cast AS cf, actor AS af
Where am.gender = 2 && am.id = cm.pid && cm.mid = cf.mid && cf.pid = af.id && af.gender = 1
GROUP BY am.id, af.id
ORDER BY num DESC, af.id ASC, am.id ASC;

-- Section9
SELECT a.first_name, a.last_name, m.title
FROM (((Actor a JOIN Cast c ON a.id = c.pid) JOIN Movie m ON c.mid = m.id) JOIN (
  SELECT a.id, MIN(m.year) AS year
    FROM actor AS a JOIN (cast AS c JOIN movie AS m ON c.mid = m.id) ON a.id = c.pid
    GROUP BY a.id) AS miny ON a.id = miny.id)
WHERE m.year = miny.year
ORDER BY a.last_name;

-- Section10
SELECT a.id, a.first_name, a.last_name
FROM actor AS a
WHERE a.id NOT IN (
	SELECT DISTINCT a.id
	FROM actor AS a, cast AS c, movie AS m
	WHERE a.id = c.pid && c.mid = m.id && m.year >= 2000)
      