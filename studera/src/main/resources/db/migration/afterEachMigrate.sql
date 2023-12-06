--#SET TERMINATOR @

create or replace procedure toolbox.compile_schema(in_schema varchar(128))
language sql
begin

    -- call dbms_output.put_line(in_schema) ;

    -- views and mqt
    call dbms_output.put_line('Recreating views');
    call dbms_output.put_line('................');
    for c1 as c1 cursor for 
	select rtrim(v.viewschema) || '.' || rtrim(v.viewname) as v
	     , t.type
	     , v.text 
	from syscat.tables t
	join syscat.views v
	    on (t.tabschema, t.tabname)
	     = (v.viewschema, v.viewname)
	where t.tabschema = in_schema 
	  and t.status <> 'N'
	order by t.create_time
    do
	call dbms_output.put_line(v);
	if type = 'V' then
	    execute immediate 'drop view ' || v;
	    execute immediate text;
	elseif type = 'S' then
	    execute immediate 'drop table ' || v;
	    execute immediate text;
	    execute immediate 'refresh table ' || v;
	end if;
    end for;
   
    -- functions
    call dbms_output.put_line('Recreating functions');
    call dbms_output.put_line('....................');
    for c1 as c1 cursor for
        select rtrim(f.funcschema) || '.' || rtrim(f.funcname) as f
            ,  rtrim(f.funcschema) || '.' || rtrim(f.specificname) as s
            ,  f.body 
        from syscat.functions f 
        join syscat.routines r 
            on (f.funcschema, f.specificname) = (r.routineschema, r.specificname) 
        where f.funcschema = in_schema
          and r.valid <> 'Y' 
          and f.language = 'SQL'
    do
        call dbms_output.put_line(f);
        execute immediate 'drop specific function ' || s;
        execute immediate body;
    end for;

 
    -- procedures
    call dbms_output.put_line('Recreating procedures');
    call dbms_output.put_line('.....................');
    for c1 as c1 cursor for
    select rtrim(procschema) || '.' || rtrim(procname) as p
        ,  rtrim(procschema) || '.' || rtrim(specificname) as s
        ,  text
    from syscat.procedures
    where procschema = in_schema
      and valid <> 'Y'
      and language = 'SQL'
    order by create_time
    do
    call dbms_output.put_line(p);
    execute immediate 'drop specific procedure ' || s;
    execute immediate text;
    end for;
	
    -- routines
    call dbms_output.put_line('Rebinding packages');
    call dbms_output.put_line('..................');
    for c1 as c1 cursor for
	select rtrim(y.routineschema) || '.' || rtrim(y.routinename) as p
        from syscat.routinedep x		    
        join syscat.routines y
            on x.routinename = y.specificname
        join syscat.packages z
	    on (x.bschema, x.bname) = (z.pkgschema, z.pkgname)
	where z.pkgschema = in_schema
	  and z.valid <> 'Y'
    do
	call dbms_output.put_line(p);
	call sysproc.rebind_routine_package('P',p,'ANY');
    end for;

    -- triggers
    call dbms_output.put_line('Recreating triggers');
    call dbms_output.put_line('...................');
    for c1 as c1 cursor for
        select rtrim(trigschema) || '.' || rtrim(trigname) as t
             , text
        from syscat.triggers
	where trigschema = in_schema
          and valid <> 'Y'
    do
        call dbms_output.put_line(t);
        execute immediate 'drop trigger ' || t;
        execute immediate text;
    end for;

end @

CREATE OR REPLACE PROCEDURE TOOLBOX.COMPILE_SCHEMA2(IN_SCHEMA VARCHAR(128))
LANGUAGE SQL
BEGIN
    -- cursor error
    DECLARE EXIT HANDLER FOR SQLSTATE '24501' 
        CALL TOOLBOX.COMPILE_SCHEMA(IN_SCHEMA);

    CALL TOOLBOX.COMPILE_SCHEMA(IN_SCHEMA);
END @


CREATE OR REPLACE PROCEDURE TOOLBOX.COMPILE_SCHEMAS()
LANGUAGE SQL
DYNAMIC RESULT SETS 0
BEGIN
    FOR v AS c1 CURSOR FOR SELECT SCHEMANAME FROM NYA.VALIDATION_SCHEMAS
    DO
        CALL TOOLBOX.COMPILE_SCHEMA2(v.SCHEMANAME);
    END FOR;
END @

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

CREATE OR REPLACE PROCEDURE TOOLBOX.CHECK_TABLE_STATUS(SCHEMANAME VARCHAR(128))
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
        AND TABSCHEMA = SCHEMANAME
    )
    WHERE CNT = 0;

    SELECT CNT INTO TMP
    FROM (
        SELECT COUNT(1) AS CNT
        FROM SYSIBMADM.ADMINTABINFO WHERE NUM_REORG_REC_ALTERS > 2
        AND TABSCHEMA = SCHEMANAME
    )
    WHERE CNT = 0;

END @

call toolbox.compile_schemas() @
call toolbox.check_table_status() @
