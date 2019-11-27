-----------------------------------------------------------------
-- list currently running stored procedure
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT
	DB_NAME(er.database_id) AS [db], 
	CONCAT(OBJECT_SCHEMA_NAME(st.objectid, er.database_id), '.', object_name(st.objectid, er.database_id)) as ProcName, 
	DATEDIFF(SECOND, er.start_time, CURRENT_TIMESTAMP) AS running_seconds,
	CONCAT('KILL ', qs.session_id) AS [kill] -- if we need to kill the session
FROM sys.dm_exec_connections as qs
JOIN sys.dm_exec_requests AS er ON qs.session_id = er.session_id AND qs.connection_id = er.connection_id
CROSS APPLY sys.dm_exec_sql_text(qs.most_recent_sql_handle) st 
WHERE object_name(st.objectid, er.database_id) is not NULL;
