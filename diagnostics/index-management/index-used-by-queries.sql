SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

;WITH qry AS (
	SELECT st.text, CAST(qp.query_plan as NVARCHAR(MAX)) as query_plan , qs.execution_count, qs.last_elapsed_time, qs.last_execution_time
	FROM sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
)
SELECT 
	OBJECT_NAME(i.object_id) as [table],
	i.name as [index],
	ius.user_seeks,
	ius.user_scans,
	qry.text,
	qry.execution_count,
	qry.last_execution_time,
	qry.last_elapsed_time
FROM sys.indexes i
JOIN sys.dm_db_index_usage_stats ius ON i.object_id = ius.object_id AND i.index_id = ius.index_id
JOIN qry ON qry.query_plan LIKE '%' + i.name + '%'
WHERE i.name LIKE 'index-name%'
AND ius.database_id = DB_ID()
ORDER BY [table], [index]
OPTION (RECOMPILE);