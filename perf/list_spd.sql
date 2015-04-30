-- lists SQL Plan directives (12c) for a given table
col created for a22
col last_modified for a21
col last_used for a21
col notes for a40
col owner for a20
col object_name for a32
col subobject_name for a32
alter session set nls_timestamp_format='YYYY-MM-DD HH24:MI:SS';
select * from dba_sql_plan_directives d join dba_sql_plan_dir_objects o on (d.directive_id=o.directive_id) 
where o.owner='&&owner' and o.object_name='&&object_name';

-- undef object_name
-- undef owner
