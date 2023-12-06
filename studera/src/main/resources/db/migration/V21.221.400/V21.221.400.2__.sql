
--#SET TERMINATOR @


CREATE OR REPLACE PROCEDURE TOOLBOX.CHECK_TABLE_STATUS()
LANGUAGE SQL
BEGIN
    DECLARE TMP INT;
    DECLARE EXIT HANDLER FOR SQLSTATE VALUE '02000'
        SIGNAL SQLSTATE '75000'
            SET MESSAGE_TEXT = 'A table is in an invalid state';

    SELECT CNT INTO TMP
    FROM (
        SELECT COUNT(1) AS CNT
        FROM SYSCAT.TABLES WHERE STATUS <> 'N'
        AND TABSCHEMA IN (SELECT SCHEMANAME FROM NYA.VALIDATION_SCHEMAS)
    )
    WHERE CNT = 0;

    SELECT CNT INTO TMP
    FROM (
        SELECT COUNT(1) AS CNT
        FROM SYSIBMADM.ADMINTABINFO WHERE NUM_REORG_REC_ALTERS > 2
        AND TABSCHEMA IN (SELECT SCHEMANAME FROM NYA.VALIDATION_SCHEMAS)
    )
    WHERE CNT = 0;

END @
