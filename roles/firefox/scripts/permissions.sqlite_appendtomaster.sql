CREATE TABLE moz_perms_newid (
  `id` integer primary key autoincrement,
  `origin` text,
  `type` text,
  `permission` integer,
  `expireType` integer,
  `expireTime` integer,
  `modificationTime` integer
);
INSERT INTO moz_perms_newid
  (`origin`, `type`, `permission`, `expireType`, `expireTime`, `modificationTime`)
SELECT `origin`, `type`, `permission`, `expireType`, `expireTime`, `modificationTime`
FROM moz_perms;

DELETE FROM moz_perms_newid
WHERE rowid NOT IN
  (SELECT min(rowid)
   FROM moz_perms_newid
   GROUP BY `origin`, `type`, `permission`, `expireType`, `expireTime`);

DROP TABLE moz_perms;
ALTER TABLE moz_perms_newid RENAME TO moz_perms;
