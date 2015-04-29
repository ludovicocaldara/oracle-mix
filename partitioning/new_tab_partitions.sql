-- gets the three more recent partitions for a table by creation date, including the size of each segment
-- args: &owner, &table_name
with parts as
( SELECT rank() over (partition by o.object_name order by o.created desc) ranking, 
  o.owner OWNER, o.object_name TABLE_NAME, o.subobject_name PARTITION_NAME,  
  o.object_type, o.created, p.high_value, p.num_rows, p.blocks
from dba_objects o
JOIN dba_tab_partitions p ON (o.owner = p.table_owner AND o.object_name = p.table_name AND o.subobject_name = p.partition_name) 
 WHERE o.object_type='TABLE PARTITION'
 AND o.owner='&owner'
 AND o.object_name='&table_name'  
)
select parts.*, s.bytes/1024/1024 Mb from parts 
join dba_segments s on (parts.owner=s.owner and parts.table_name=s.segment_name and parts.partition_name = s.partition_name)
where parts.ranking<4; 
