--#SET TERMINATOR @

-- release
ALTER TABLE HUBBLE.REPORTATOM DROP CONSTRAINT XFK1REPORTATOM @
ALTER TABLE HUBBLE.REPORTATOM DROP CONSTRAINT XFK2REPORTATOM @

ALTER TABLE HUBBLE.REPORT_SUBJECT_FILTER DROP CONSTRAINT XFK1REPSUBJFIL @

ALTER TABLE HUBBLE.WORKUNITRUN DROP CONSTRAINT XFK1WORKUNITRUN @

ALTER TABLE HUBBLE.REPORTATOM DROP PRIMARY KEY @
ALTER TABLE HUBBLE.REPORTATOM ADD CONSTRAINT XPKREPORTATOM
    PRIMARY KEY (REPORTATOMID)
ENFORCED
ENABLE QUERY OPTIMIZATION @

ALTER TABLE HUBBLE.REPORT_SUBJECT DROP PRIMARY KEY @
ALTER TABLE HUBBLE.REPORT_SUBJECT ADD CONSTRAINT XPKREPORTSUBJECT
    PRIMARY KEY (REPORTSUBJECT_ID)
ENFORCED
ENABLE QUERY OPTIMIZATION @

ALTER TABLE HUBBLE.WORKSETRUN DROP PRIMARY KEY @
ALTER TABLE HUBBLE.WORKSETRUN ADD CONSTRAINT XPKWORKSETRUN
    PRIMARY KEY (WORKSETRUNID)
ENFORCED
ENABLE QUERY OPTIMIZATION @

ALTER TABLE HUBBLE.WORKUNITRUN DROP PRIMARY KEY @
ALTER TABLE HUBBLE.WORKUNITRUN ADD CONSTRAINT XPKWORKUNITRUN
    PRIMARY KEY (WORKUNITRUNID)
ENFORCED
ENABLE QUERY OPTIMIZATION @

-- restore

ALTER TABLE HUBBLE.WORKUNITRUN ADD CONSTRAINT XFK1WORKUNITRUN
    FOREIGN KEY (WORKSETRUNID)
    REFERENCES HUBBLE.WORKSETRUN
                (WORKSETRUNID)
        ON DELETE CASCADE
        ON UPDATE RESTRICT
ENFORCED
ENABLE QUERY OPTIMIZATION @

ALTER TABLE HUBBLE.REPORT_SUBJECT_FILTER ADD CONSTRAINT XFK1REPSUBJFIL
    FOREIGN KEY (REPORTSUBJECT_ID)
    REFERENCES HUBBLE.REPORT_SUBJECT
                (REPORTSUBJECT_ID)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
ENFORCED
ENABLE QUERY OPTIMIZATION @

ALTER TABLE HUBBLE.REPORTATOM ADD CONSTRAINT XFK1REPORTATOM
    FOREIGN KEY (REPORTSUBJECT_ID)
    REFERENCES HUBBLE.REPORT_SUBJECT
                (REPORTSUBJECT_ID)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
ENFORCED
ENABLE QUERY OPTIMIZATION @

ALTER TABLE HUBBLE.REPORTATOM ADD CONSTRAINT XFK2REPORTATOM
    FOREIGN KEY (WORKUNITRUNID)
    REFERENCES HUBBLE.WORKUNITRUN
                (WORKUNITRUNID)
        ON DELETE CASCADE
        ON UPDATE RESTRICT
ENFORCED
ENABLE QUERY OPTIMIZATION @


