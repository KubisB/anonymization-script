USE [db_prod_ano]
GO
DBCC SHRINKDATABASE(N'db_prod_ano' )
GO
USE [db_prod_ano]
GO
DBCC SHRINKFILE (N'db_prod' , 0, TRUNCATEONLY)
GO
