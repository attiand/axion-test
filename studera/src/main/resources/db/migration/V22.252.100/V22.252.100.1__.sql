--#SET TERMINATOR @

DROP VIEW STUDERA.VISIBLE_SUBJECT_AND_DIPLOMA @

CREATE TABLE TMP.VISIBLE_DIPLOMA LIKE STUDERA.VISIBLE_DIPLOMA @
INSERT INTO TMP.VISIBLE_DIPLOMA SELECT * FROM STUDERA.VISIBLE_DIPLOMA @
DROP TABLE STUDERA.VISIBLE_DIPLOMA @

--

CREATE TABLE STUDERA.VISIBLE_DIPLOMA
( DIPLOMA_ID INTEGER NOT NULL
, VISIBLE_NAME VARCHAR(64) NOT NULL
, VISIBLE_ENGLISH_NAME VARCHAR(64) NOT NULL
) IN TBLSPC1 INDEX IN INXSPC1
COMPRESS YES ADAPTIVE
ORGANIZE BY ROW @

CREATE UNIQUE INDEX STUDERA.XPKVISIBLE_DIPLOMA ON STUDERA.VISIBLE_DIPLOMA
    (DIPLOMA_ID)
COMPRESS YES
ALLOW REVERSE SCANS
COLLECT SAMPLED DETAILED STATISTICS @

CREATE UNIQUE INDEX STUDERA.XAKVISIBLE_DIPLOMA ON STUDERA.VISIBLE_DIPLOMA
    (VISIBLE_NAME)
COMPRESS YES
ALLOW REVERSE SCANS
COLLECT SAMPLED DETAILED STATISTICS @

ALTER TABLE STUDERA.VISIBLE_DIPLOMA ADD CONSTRAINT XPKVISIBLE_DIPLOMA
    PRIMARY KEY (DIPLOMA_ID)
ENFORCED
ENABLE QUERY OPTIMIZATION @

ALTER TABLE STUDERA.VISIBLE_DIPLOMA ADD CONSTRAINT XAKVISIBLE_DIPLOMA
    UNIQUE (VISIBLE_NAME)
ENFORCED
ENABLE QUERY OPTIMIZATION @

ALTER TABLE STUDERA.VISIBLE_DIPLOMA ADD CONSTRAINT XFKVISIBLE_DIPLOMA
    FOREIGN KEY (DIPLOMA_ID)
    REFERENCES STUDERA.DIPLOMA
                (ID)
        ON DELETE CASCADE
        ON UPDATE RESTRICT
ENFORCED
ENABLE QUERY OPTIMIZATION @

COMMENT ON TABLE STUDERA.VISIBLE_DIPLOMA IS 'Examina som ska visas på studera.nu' @

COMMENT ON COLUMN STUDERA.VISIBLE_DIPLOMA.DIPLOMA_ID IS 'Examen id' @
COMMENT ON COLUMN STUDERA.VISIBLE_DIPLOMA.VISIBLE_NAME IS 'Namn med vilket examen ska visas på studera.nu. Avviker från name i DIPLOMA' @
COMMENT ON COLUMN STUDERA.VISIBLE_DIPLOMA.VISIBLE_ENGLISH_NAME IS 'Engelskt namn med vilket examen ska visas på studera.nu. Avviker från english_name i DIPLOMA' @

INSERT INTO STUDERA.VISIBLE_DIPLOMA SELECT * FROM TMP.VISIBLE_DIPLOMA  @
DROP TABLE TMP.VISIBLE_DIPLOMA @

--

CREATE OR REPLACE VIEW STUDERA.VISIBLE_SUBJECT_AND_DIPLOMA
    (VISIBLE_NAME, VISIBLE_ENGLISH_NAME, DIPLOMA_ID, SUBJECT_NODEID) AS 
(
    select subject_name, subject_english_name, cast(null as int), subject_nodeid
    from STUDERA.SUBJECT
    where SUBJECT_NODE_DEPTH <= 3
    union all
    select visible_name, VISIBLE_ENGLISH_NAME, diploma_id, cast(null as char)
    from STUDERA.VISIBLE_DIPLOMA
) @

COMMENT ON TABLE STUDERA.VISIBLE_SUBJECT_AND_DIPLOMA IS 'Union av ämnen och examina som ska visas på studera.nu. Exakt 1 av diploma_id eller subject_nodeid är null'@

COMMENT ON COLUMN  STUDERA.VISIBLE_SUBJECT_AND_DIPLOMA.VISIBLE_NAME IS  'Namn med vilket examen eller ämne ska visas på studera.nu'@
COMMENT ON COLUMN  STUDERA.VISIBLE_SUBJECT_AND_DIPLOMA.VISIBLE_ENGLISH_NAME IS  'Engelskt namn med vilket examen eller ämne ska visas på studera.nu'@
COMMENT ON COLUMN  STUDERA.VISIBLE_SUBJECT_AND_DIPLOMA.DIPLOMA_ID IS  'Examen id'@
COMMENT ON COLUMN  STUDERA.VISIBLE_SUBJECT_AND_DIPLOMA.SUBJECT_NODEID IS  'Det aktuella ämnets placering i ämnesträdet'@

