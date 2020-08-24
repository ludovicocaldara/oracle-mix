-- Author    : Ludovico Caldara
-- Version   : 0.1
-- Purpose   : check/change RMAN configuration according to list of values
-- Run as    : SYSDBA 

set serveroutput on format wrapped
set lines 200
DECLARE
	v_num_errors BINARY_INTEGER := 0;
	v_num_warnings BINARY_INTEGER := 0;

	CURSOR c_rmanconfig IS
		SELECT name, value
			FROM v$rman_configuration
			WHERE con_id=0;

	r_rmanconfig c_rmanconfig%ROWTYPE;

	-- it does not like referencing cursor.value%type here
	TYPE ty_rc_newvalues IS TABLE OF VARCHAR2(1025)
		INDEX BY VARCHAR2(65);

	a_rc_newvalues ty_rc_newvalues;

	i 	VARCHAR2(65);
	v_sql   VARCHAR2(32767);
	recno   BINARY_INTEGER;


BEGIN
	-- if something screws up, exec dbms_backup_restore.resetconfig will reset the whole config
	a_rc_newvalues('RETENTION POLICY') := 'TO RECOVERY WINDOW OF 30 DAYS';
	a_rc_newvalues('CONTROLFILE AUTOBACKUP') := 'ON'; -- default on CDB only, non-CDB default is OFF
	a_rc_newvalues('DEVICE TYPE DISK') := 'PARALLELISM 1 BACKUP TYPE TO COMPRESSED BACKUPSET';
	dbms_output.put_line('---------------------------------------------------------------');
	dbms_output.put_line('-- Checking RMAN Configuration for '||sys_context('USERENV','DB_UNIQUE_NAME'));
	dbms_output.put_line('---------------------------------------------------------------');

	v_sql := 'SELECT name, value FROM v$rman_configuration WHERE con_id=0 AND name = :1';
	i := a_rc_newvalues.FIRST;
	WHILE i IS NOT NULL LOOP
		-- dbms_output.put_line ('_INFO: ''' || i || ''' must be ''' || TO_CHAR(a_rc_newvalues(i)) || '''');

		BEGIN
			execute immediate v_sql into r_rmanconfig using i;
			IF r_rmanconfig.value = a_rc_newvalues(i) THEN
				dbms_output.put_line ('___OK: Parameter ''' || i || '''');
				dbms_output.put_line ('       - expected   : '''||a_rc_newvalues(i)||'''');
				dbms_output.put_line ('       - configured : '''||r_rmanconfig.value||'''');
			ELSE
				dbms_output.put_line ('ERROR: Parameter ''' || i || '''');
				dbms_output.put_line ('       - expected   : '''||a_rc_newvalues(i)||'''');
				dbms_output.put_line ('       - configured : '''||r_rmanconfig.value||'''');
                		v_num_errors := v_num_errors + 1;
			END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				dbms_output.put_line ('_WARN: Parameter ''' || i || '''');
				dbms_output.put_line ('       - expected   : '''||a_rc_newvalues(i)||'''');
				dbms_output.put_line ('       - configured : not set');
                		v_num_warnings := v_num_warnings + 1;
				BEGIN
					dbms_output.put_line('       CONFIGURE '||i||' '||a_rc_newvalues(i)||';');
					recno := sys.dbms_backup_restore.setconfig(i,a_rc_newvalues(i));
					dbms_output.put_line('       - new value set ('||to_char(recno)||')');
				END;
			WHEN TOO_MANY_ROWS THEN
				dbms_output.put_line ('_WARN: Parameter ''' || i || '''');
				dbms_output.put_line ('       - expected   : '''||a_rc_newvalues(i)||'''');
				dbms_output.put_line ('       - configured : multiple values configured');
                		v_num_warnings := v_num_warnings + 1;
		END;

		--dbms_output.new_line;
		i := a_rc_newvalues.NEXT(i);
	END LOOP;


        <<stop_checks>>

        dbms_output.put_line('--------------------------------------');
        IF v_num_errors > 0 THEN
                dbms_output.put_line('RESULT: ERROR: '||to_char(v_num_errors)||' errors - '||to_char(v_num_warnings)||' warnings');
        ELSIF v_num_warnings > 0 THEN
                dbms_output.put_line('RESULT: _WARN: '||to_char(v_num_errors)||' errors - '||to_char(v_num_warnings)||' warnings');
        ELSE
                dbms_output.put_line('RESULT: ___OK: '||to_char(v_num_errors)||' errors - '||to_char(v_num_warnings)||' warnings');
        END IF;

END;
/
