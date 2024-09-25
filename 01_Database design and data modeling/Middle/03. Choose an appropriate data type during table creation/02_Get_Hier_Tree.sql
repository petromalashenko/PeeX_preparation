
-- find level of location in hierarchy and build hierarchy path

WITH hier
     AS (SELECT child_location_cd,
                parent_location_cd,
                0                          AS level,
                Cast('/' AS VARCHAR(max)) AS hier_path
         FROM   dbo.th_location_relationship
         WHERE  parent_location_cd IS NULL
         UNION ALL
         SELECT lr.child_location_cd,
                lr.parent_location_cd,
                h.level + 1 AS level,
                h.hier_path
                + Cast(lr.parent_location_cd AS VARCHAR)
                + '/'       AS hier_path
         FROM   dbo.th_location_relationship lr
                INNER JOIN hier h
                        ON lr.parent_location_cd = h.child_location_cd)
SELECT *
FROM   hier
-- if recursion step is exceeded, beed to apply MAXRECURSION option
--OPTION(MAXRECURSION 0)
;

