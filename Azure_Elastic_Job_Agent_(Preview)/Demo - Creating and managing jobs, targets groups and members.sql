CREATE MASTER KEY ENCRYPTION BY PASSWORD='@wallyData2022';  
  
-- Create two database scoped credentials.  
-- The credential to connect to the Azure SQL logical server, to execute jobs
CREATE DATABASE SCOPED CREDENTIAL job_credential WITH IDENTITY = 'user_elasticjob_cred',
    SECRET = '@wallyData2022';
GO
-- The credential to connect to the Azure SQL logical server, to refresh the database metadata in server
CREATE DATABASE SCOPED CREDENTIAL refresh_credential WITH IDENTITY = 'user_elasticjob_cred',
    SECRET = '@wallyData2022';
GO


EXEC jobs.sp_add_target_group 'tg-wallyDataManager';

-- Add a server target member
-- Will be executed the job against all databases in this server
EXEC jobs.sp_add_target_group_member
@target_group_name = 'tg-wallyDataManager',
@target_type = 'SqlServer',
@refresh_credential_name = 'refresh_credential', --credential required to refresh the databases in a server
@server_name = 'az-srv-wallydata-all.database.windows.net';

-- Will be executed the job against all databases in this server EXCLUDING dbManaus database
EXEC jobs.sp_add_target_group_member
@target_group_name = 'tg-wallyDataManager',
@target_type = 'SqlServer',
@refresh_credential_name = 'refresh_credential', --credential required to refresh the databases in a server
@server_name = 'az-srv-wallydata-exclude.database.windows.net';
GO

EXEC [jobs].sp_add_target_group_member
@target_group_name = N'tg-wallyDataManager',
@membership_type = N'Exclude',
@target_type = N'SqlDatabase',
@server_name = N'az-srv-wallydata-exclude.database.windows.net',
@database_name = N'dbManaus';
GO

-- Will be executed the job against the database dbParana
EXEC [jobs].sp_add_target_group_member
@target_group_name = N'tg-wallyDataManager',
@membership_type = N'include',
@target_type = N'SqlDatabase',
@server_name = N'az-srv-wallydata-specific.database.windows.net',
@database_name = N'dbParana';
GO

-- Will be executed the job against all databases in poolUSA
EXEC jobs.sp_add_target_group_member
@target_group_name = 'tg-wallyDataManager',
@target_type = 'SqlElasticPool',
@refresh_credential_name = 'refresh_credential', --credential required to refresh the databases in a server
@server_name = 'az-srv-wallydata-pool.database.windows.net',
@elastic_pool_name = 'pooldb';

--View target group and target group members
/*
SELECT * FROM jobs.target_groups 
SELECT * FROM jobs.target_group_members
*/

--Add job 
EXEC jobs.sp_add_job @job_name = 'jobCreateDBATables', 
@description = 'job Create DBA Tables',
@enabled = 0, --bit Default 0
@schedule_interval_type = 'Minutes', --'Once','Minutes','Hours','Days','Weeks','Months' - Default Once
@schedule_interval_count = 15, -- Default 1
@schedule_start_time = '2022-04-01 15:00:00',
@schedule_end_time = '2023-04-05 15:00:00';

-- Add job step for create table
DECLARE @command nvarchar(max) =  N'IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id(''tb_wallyDataDBAs''))
CREATE TABLE [dbo].[tb_wallyDataDBAs]([id] [int] identity primary key ,[CollectionDate] [datetime] DEFAULT (GETDATE()), [Descr] [varchar](250) );'

EXEC jobs.sp_add_jobstep
@job_name = 'jobCreateDBATables',
@step_name = 'tb_wallyDataDBAs create',
@command = @command,
@credential_name = 'job_credential',
@target_group_name = 'tg-wallyDataManager',
@retry_attempts = 10,
@initial_retry_interval_seconds = 5, -- Default 1
@maximum_retry_interval_seconds = 120, -- Default 120
@retry_interval_backoff_multiplier = 2, --Default 2
@step_timeout_seconds =300; --Default 43,200 seconds (12 hours).


/*
Select Cases 

@output_type = 'SqlDatabase',
@output_credential_name = 'job_credential',
@output_server_name = 'server1.database.windows.net',
@output_database_name = '<resultsdb>',
@output_schema_name = '<resultsschema>', 
@output_table_name = '<resultstable>'; --If not exists, job creates. Required ddl permission
*/


--Start Job
EXECUTE [jobs].sp_start_job 'jobCreateDBATables'

--Stop Job
EXECUTE [jobs].sp_stop_job '2471A3FC-E830-4FA8-ADCC-7697D9E1151C'

--Enabling Job
EXECUTE [jobs].sp_update_job 
@job_name = 'jobCreateDBATables',
@enabled = 1,
@schedule_interval_type = 'Hours'

--Tables and views for troubleshooting
SELECT * FROM [jobs].[job_executions] 
WHERE job_execution_id = (SELECT MAX(job_execution_id) FROM [jobs].[job_executions] )
ORDER BY target_server_name 


SELECT * FROM [jobs_internal].[job_task_executions]
SELECT * FROM [jobs_internal].[job_cancellations]
SELECT * FROM [jobs_internal].[visible_jobs]

SELECT * FROM [jobs].[target_groups]
SELECT * FROM [jobs].[target_group_members] 
ORDER BY server_name, membership_type DESC

SELECT * FROM [jobs].[jobs]
SELECT * FROM [jobs].[jobsteps]

--Delete a target group member
EXEC jobs.sp_delete_target_group_member
@target_group_name = 'tg-wallyDataManager',
@target_id = '49B57937-BAFE-4478-8D5A-939C8AB5AABA'

--Delete a target group 
EXEC jobs.sp_delete_target_group 
@target_group_name = 'tg-wallyDataManager'
GO

--------------------------*****************************************---------------------------
CREATE OR ALTER PROC jobs.sp_job_task_next_execution 
@job_name NVARCHAR(200)
AS
BEGIN --BEGIN PROC
	PRINT ''
	--DECLARE @@job_name NVARCHAR(200) = 'jobCreateDBATables'

	DECLARE @schedule_interval_type VARCHAR(10) 
	DECLARE @schedule_interval_count INT
	DECLARE @schedule_start_time DATETIME
	DECLARE @next_start_time DATETIME
	DECLARE @CMD NVARCHAR(MAX)

	SELECT 
		@schedule_interval_type = schedule_interval_type
		,@schedule_interval_count = schedule_interval_count
		,@schedule_start_time = schedule_start_time
		,@next_start_time = schedule_start_time
	FROM [jobs].[jobs]
	WHERE job_name = @job_name

	IF @next_start_time IS NULL
		PRINT 'JOB "'+@job_name+'" WAS NOT FOUND'

	IF @schedule_start_time >= GETDATE()
		PRINT 'THE NEXT EXECUTION FOR JOB "'+@job_name+'" WILL BE ON "'+CONVERT (VARCHAR(24),@next_start_time,121)+'"'
	ELSE
		BEGIN --BEGIN ELSE 1
			IF @schedule_interval_type = 'ONCE'
				PRINT 'THE NEXT EXECUTION FOR JOB "'+@job_name+'" WILL BE NEVER'
			ELSE
			BEGIN --BEGIN ELSE 2
				WHILE @next_start_time < GETDATE()
					BEGIN --BEGIN WHILE
						IF @schedule_interval_type = 'Minutes'
							SET @next_start_time = DATEADD("MINUTE",@schedule_interval_count,@next_start_time)
						IF @schedule_interval_type = 'Hours'
							SET @next_start_time = DATEADD("HOUR",@schedule_interval_count,@next_start_time)
						IF @schedule_interval_type = 'Days'
							SET @next_start_time = DATEADD("DAY",@schedule_interval_count,@next_start_time)
						IF @schedule_interval_type = 'Weeks'
							SET @next_start_time = DATEADD("WEEK",@schedule_interval_count,@next_start_time)
						IF @schedule_interval_type = 'Months'
							SET @next_start_time = DATEADD("MONTH",@schedule_interval_count,@next_start_time)
					END --END WHILE
			END --END ELSE 2
			PRINT 'THE NEXT EXECUTION FOR JOB "'+@job_name+'" WILL BE ON "'+CONVERT (VARCHAR(24),@next_start_time,121)+'"'
		END --END ELSE 1
END --END PROC
GO
--------------------------*****************************************---------------------------

EXECUTE jobs.sp_job_task_next_execution 
	@job_name = 'jobCreateDBATables'
