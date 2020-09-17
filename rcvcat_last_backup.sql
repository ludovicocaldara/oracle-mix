-- to be run in the catalog
-- get all the DBs in the catalog and show the last inc0, inc1 and arc for each one
-- useful to get if any backup is not configured
-- Note: use bs table so backup sets only, not datafile copies.
set pages 100 lines 180
WITH db AS (
    SELECT
        name,
        dbid,
        dbinc_key,
        db_key
    FROM
        rc_database
), 
lastinc0 AS (
    SELECT
        *
    FROM
        (
            SELECT
                db_key,
                completion_time,
                RANK() OVER(
                    PARTITION BY db_key
                    ORDER BY
                        completion_time DESC
                ) AS nrank
            FROM
                bs
            WHERE
                bck_type = 'I'
                AND incr_level = 0
        ) i0
    WHERE
        nrank = 1
), 
lastinc1 AS (
    SELECT
        *
    FROM
        (
            SELECT
                db_key,
                completion_time,
                RANK() OVER(
                    PARTITION BY db_key
                    ORDER BY
                        completion_time DESC
                ) AS nrank
            FROM
                bs
            WHERE
                bck_type = 'I'
                AND incr_level = 1
        ) i1
    WHERE
        nrank = 1
), 
lastarc AS (
    SELECT
        *
    FROM
        (
            SELECT
                db_key,
                completion_time,
                RANK() OVER(
                    PARTITION BY db_key
                    ORDER BY
                        completion_time DESC
                ) AS nrank
            FROM
                bs
            WHERE
                bck_type = 'L'
        ) a
    WHERE
        nrank = 1
)
SELECT
    db.dbid,
    db.name,
    db.db_key,
    lastinc0.completion_time   AS last_inc0,
    lastinc1.completion_time   AS last_inc1,
    lastarc.completion_time    AS last_arc
FROM
    db
    LEFT OUTER JOIN lastinc0 ON ( db.db_key = lastinc0.db_key )
    LEFT OUTER JOIN lastinc1 ON ( db.db_key = lastinc1.db_key )
    LEFT OUTER JOIN lastarc ON ( db.db_key = lastarc.db_key )
ORDER BY least (
	lastinc0.completion_time,
	lastinc1.completion_time,
	lastarc.completion_time 
) NULLS FIRST;
