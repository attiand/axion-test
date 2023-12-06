--#SET TERMINATOR @

-- initial check to make sure that nothing is added in old migration system
call toolbox.assert('select 1 from (values substr(nya.get_db_version(),1,locate(CHR(9),nya.get_db_version())-1))t (v) where v=''21.212.300.1''') @

DROP FUNCTION NYA.GET_DB_VERSION () @
DROP FUNCTION NYA.GET_DB_VERSION (INT) @
DROP FUNCTION NYA.GET_DB_VERSION (INT, INT) @
DROP FUNCTION NYA.GET_DB_VERSION (INT, INT, INT) @

DROP TABLE NYA.DATABASE_INFO @

