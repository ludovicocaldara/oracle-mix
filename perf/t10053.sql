-- forces a new hard parse, take care of the session parameters that influence the optimizer!
begin
dbms_sqldiag.dump_trace(
p_sql_id => '&sql_id',
p_child_number => &child_num,
p_component => 'Optimizer',
p_file_id => 'mytrace'
);
end;
/

--  prior to 11.2: 
-- https://bdrouvot.wordpress.com/2013/09/16/flush-a-single-sql-statement-and-capture-a-10053-trace-for-it/

-- prior to 11:
-- https://blogs.oracle.com/optimizer/entry/how_do_i_capture_a
