SET SERVEROUTPUT ON
DECLARE
  ext_name VARCHAR2(30);
BEGIN
  ext_name := DBMS_STATS.create_extended_stats (ownname   => '&user', tabname   => '&table', extension => '(&commasep_cols)');
  DBMS_OUTPUT.put_line('ext_name=' || ext_name);
END;
/
