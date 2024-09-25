
-- Add LocationID as hierarchiid data type
ALTER TABLE dbo.th_location_relationship
ADD LocationID hierarchyid;


WITH hier
     AS (SELECT child_location_cd,
                parent_location_cd,
                0                          AS level,
                Cast('/' + CAST(child_location_cd as varchar) + '/' AS VARCHAR(max)) AS hier_path
         FROM   dbo.th_location_relationship
         WHERE  parent_location_cd IS NULL
         UNION ALL
         SELECT lr.child_location_cd,
                lr.parent_location_cd,
                h.level + 1 AS level,
                h.hier_path
                + Cast(lr.child_location_cd AS VARCHAR)
                + '/'       AS hier_path
         FROM   dbo.th_location_relationship lr
                INNER JOIN hier h
                        ON lr.parent_location_cd = h.child_location_cd)
update lr
   SET LocationID = h.hier_path
  FROM dbo.th_location_relationship lr
       INNER JOIN hier h
               on lr.child_location_cd = h.child_location_cd
;

-- Check parent, root and level
select LocationID.GetAncestor(1) as parent_cd, hierarchyid::GetRoot() as root_cd, LocationID.GetLevel() as level , *
from dbo.th_location_relationship
;


-- Alter table removing redundant columns
ALTER TABLE dbo.th_location_relationship DROP CONSTRAINT FK_th_location_relationship;

ALTER TABLE dbo.th_location_relationship DROP COLUMN parent_location_cd;

EXEC sp_rename 'dbo.th_location_relationship.child_location_cd', 'location_cd', 'COLUMN';