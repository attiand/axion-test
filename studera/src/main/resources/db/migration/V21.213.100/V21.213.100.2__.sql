--#SET TERMINATOR @

CREATE OR REPLACE FUNCTION NYA.GET_DB_VERSION()
RETURNS VARCHAR(100)
LANGUAGE SQL
READS SQL DATA
NO EXTERNAL ACTION
DETERMINISTIC
    RETURN select "version" from nya_flyway.flyway_schema_history 
           order by "installed_rank" desc fetch first 1 rows only
@

