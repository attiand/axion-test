--#SET TERMINATOR @

CREATE OR REPLACE PROCEDURE toolbox.drop_function (funcschema varchar(128), 
                                        funcname   varchar(128))
LANGUAGE SQL
BEGIN
    DECLARE tmpstmt VARCHAR(100);
    SET tmpstmt = 'drop function ' || funcschema || '.' || funcname;

    A: BEGIN
        -- Do nothing if drop function fails
        DECLARE CONTINUE HANDLER FOR SQLSTATE '42704'
                BEGIN
                END;

        DECLARE CONTINUE HANDLER FOR SQLSTATE '42883'
                BEGIN
                END;

        EXECUTE IMMEDIATE tmpstmt;
    END;
END @

COMMENT ON PROCEDURE toolbox.drop_function IS 'Drop given function if it exists.' @


CREATE OR REPLACE PROCEDURE toolbox.drop_procedure (procschema varchar(128), 
                                         procname   varchar(128))
LANGUAGE SQL
BEGIN
    DECLARE tmpstmt VARCHAR(100);
    SET tmpstmt = 'drop procedure ' || procschema || '.' || procname;

    A: BEGIN
        -- Do nothing if drop table fails
        DECLARE CONTINUE HANDLER FOR SQLSTATE '42704'
                BEGIN
                END;

        EXECUTE IMMEDIATE tmpstmt;
    END;
END @

COMMENT ON PROCEDURE toolbox.drop_procedure IS 'Drop given procedure if it exists.' @


CALL TOOLBOX.DROP_FUNCTION('TOOLBOX', 'CASTALESCE_DATE') @
CALL TOOLBOX.DROP_PROCEDURE('TOOLBOX', 'CASTALESCE_DATE_CHECK_') @

CREATE OR REPLACE FUNCTION TOOLBOX.CASTALESCE_DATE(STRVAL VARCHAR(100))
RETURNS DATE
DETERMINISTIC
NO EXTERNAL ACTION
READS SQL DATA
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        RETURN NULL;
    END;
    RETURN date(strval);
END @

