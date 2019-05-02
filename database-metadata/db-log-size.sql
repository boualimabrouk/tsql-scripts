-----------------------------------------------------------------
-- SQL Server database and log size
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
SELECT 
	instance_name as [database],
	CAST(MAX(CASE counter_name WHEN 'Data File(s) Size (KB)' THEN cntr_value ELSE 0 END) / 1024.0 as decimal(17,2)) as [data size (MB)],
	CAST(MAX(CASE counter_name WHEN 'Log File(s) Size (KB)' THEN cntr_value ELSE 0 END) / 1024.0 as decimal(17,2)) as [log size (MB)],
	MAX(CASE counter_name WHEN 'Percent Log Used' THEN cntr_value ELSE 0 END) as [Percent Log Used],
	CAST(MAX(CASE counter_name WHEN 'Log File(s) Used Size (KB)' THEN cntr_value ELSE 0 END) / 1024.0 as decimal(17,2)) as [log used (MB)]
FROM sys.dm_os_performance_counters
WHERE object_name LIKE '%:Databases%'
AND counter_name IN ('Log File(s) Size (KB)', 'Percent Log Used', 'Log File(s) Used Size (KB)', 'Data File(s) Size (KB)')
AND instance_name NOT IN ('_Total', 'master', 'model', 'mssqlsystemresource')
GROUP BY instance_name
ORDER BY instance_name;

-- a new one, using PIVOT ...
SELECT 
	instance_name as [database],
	CAST([Log File(s) Size (KB)] / 1024.0 as decimal(20,2)) as log_size_mb,
	[Percent Log Used] as percent_used,
	db.recovery_model_desc as recovery_model,
	db.log_reuse_wait_desc as log_reuse_wait 
FROM (
	SELECT counter_name, cntr_value, instance_name
	FROM sys.dm_os_performance_counters
	WHERE counter_name IN ('Log File(s) Size (KB)', 'Percent Log Used')) as t
	PIVOT  
	(  
	MIN(cntr_value)  
	FOR counter_name IN ([Log File(s) Size (KB)], [Percent Log Used])  
) AS pt
JOIN sys.databases db ON pt.instance_name = db.name
ORDER BY [database];  