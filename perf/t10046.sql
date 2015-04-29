-- alter session
ALTER SESSION SET events '10046 trace name context forever, level 24';
/* your queries here */
ALTER SESSION SET events '10046 trace name context off';

-- pl/sql
exec DBMS_SYSTEM.set_ev(si=>&sid, se=>&serial, ev=>10046, le=>24, nm=>' ');
/* your queries here */
exec DBMS_SYSTEM.set_ev(si=>&sid, se=>&serial, ev=>10046, le=>0,  nm=>' ');

-- additional doc:
-- http://oracle-base.com/articles/misc/sql-trace-10046-trcsess-and-tkprof.php

-- http://antognini.ch/2012/08/event-10046-full-list-of-levels/
Level 	Description
0 	The debugging event is disabled.
1 	The debugging event is enabled. For each processed database call, the following information is given: SQL statement, response time, service time, number of processed rows, number of logical reads, number of physical reads and writes, execution plan, and little additional information.
    Up to 10.2 an execution plan is written to the trace file only when the cursor it is associated with is closed. The execution statistics associated to it are values aggregated over all executions.
    As of 11.1 an execution plan is written to the trace file only after the first execution of every cursor. The execution statistics associated to it are the ones of the first execution only.
4 	As in level 1, with additional information about bind variables. Mainly, the data type, its precision, and the value used for each execution.
8 	As in level 1, plus detailed information about wait time. For each wait experienced during the processing, the following information is given: the name of the wait event, the duration, and a few additional parameters identifying the resource that has been waited for.
16 	As in level 1, plus the execution plans information is written to the trace file for each execution. Available as of 11.1 only.
32 	As in level 1, but without the execution plans information. Available as of 11.1 only.
64 	As in level 1, plus the execution plans information might be written for executions following the first one. The condition is that, since the last write of execution plans information, a particular cursor consumed at least one additional minute of DB time. This level is interesting in two cases. First, when the information about the first execution is not enough for analysing a specific issue. Second, when the overhead of writing the information about every execution (level 16) is too high. Generally available as of 11.2.0.2 only.
