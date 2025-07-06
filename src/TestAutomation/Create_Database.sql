USE [master];
GO

DECLARE @kill VARCHAR(8000) = '';
SET @kill =
      (SELECT TOP (1) @kill + 'kill ' + CONVERT(VARCHAR(5), [session_id]) + ';'
       FROM [sys].[dm_exec_sessions]
       WHERE [database_id] = DB_ID('TestAutomation'));
EXEC (@kill);
GO

DROP DATABASE IF EXISTS [TestAutomation];
GO

CREATE DATABASE [TestAutomation]
  ON
  ( NAME = TestAutomation_Data,
    FILENAME = 'c:\DB\Data\TestAutomation.mdf',
    SIZE = 10 MB, -- Initial size
    MAXSIZE = 2048 MB, -- Maximum size
    FILEGROWTH = 10 MB -- Growth increment
    )
  LOG ON
  ( NAME = TestAutomation_Log,
    FILENAME = 'c:\DB\Logs\TestAutomation_log.ldf',
    SIZE = 5 MB, -- Initial size
    MAXSIZE = 2048 MB, -- Maximum size
    FILEGROWTH = 5 MB -- Growth increment
    );
GO

/* DDL creation */

USE [TestAutomation];
GO

CREATE TABLE [dbo].[Request] (
  [Id]          INT IDENTITY (1, 1)                                                  NOT NULL,
  [Method]      VARCHAR(7) CONSTRAINT [DF_Request_Method] DEFAULT ('')               NOT NULL,
  [URL]         NVARCHAR(MAX) CONSTRAINT [DF_Request_URL] DEFAULT ('')               NOT NULL,
  [Header]      NVARCHAR(MAX) CONSTRAINT [DF_Request_Header] DEFAULT ('')            NOT NULL,
  [Body]        NVARCHAR(MAX) CONSTRAINT [DF_Request_Body] DEFAULT ('')              NOT NULL,
  [DateCreated] DATETIME2(7) CONSTRAINT [DF_Request_DateCreated] DEFAULT (GETDATE()) NOT NULL,
  [Ts]          ROWVERSION                                                           NOT NULL,
  CONSTRAINT [PK_Request_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO

CREATE TABLE [dbo].[ResponseGenerator] (
  [Id]                INT CONSTRAINT [DF_ResponseGenerator_Id] DEFAULT (1)                                                    NOT NULL,
  [StatusCode]        INT CONSTRAINT [DF_ResponseGenerator_StatusCode] DEFAULT (200)                                          NOT NULL,
  [StatusDescription] VARCHAR(500) CONSTRAINT [DF_ResponseGenerator_StatusDescription] DEFAULT ('')                           NOT NULL,
  [Header]            NVARCHAR(MAX) CONSTRAINT [DF_ResponseGenerator_Header] DEFAULT ('{"Content-Type": "application/json"}') NOT NULL,
  [Body]              NVARCHAR(MAX) CONSTRAINT [DF_ResponseGenerator_Body] DEFAULT ('')                                       NOT NULL,
  [Comment]           NVARCHAR(3000) CONSTRAINT [DF_ResponseGenerator_Comment] DEFAULT ('')                                   NOT NULL,
  [DateModified]      DATETIME2(7) CONSTRAINT [DF_ResponseGenerator_DateModified] DEFAULT (GETDATE())                         NOT NULL,
  [Ts]                ROWVERSION                                                                                              NOT NULL,
  CONSTRAINT [PK_ResponseGenerator_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO

/* DML creation */

USE [TestAutomation];
GO

MERGE [dbo].[ResponseGenerator] AS [t]
USING
  (
    VALUES 
      (1, 200, 'OK', '{"Content-Type": "application/json"}', '{"key1": value1, "key2": "Value2"}', '')
  )
  AS [s] ([Id], [StatusCode], [StatusDescription], [Header], [Body], [Comment])
ON [t].[Id] = [s].[Id]
WHEN NOT MATCHED BY TARGET
  THEN
  INSERT
  (
    [Id],
    [StatusCode],
    [StatusDescription],
    [Header],
    [Body],
    [Comment]
  )
  VALUES 
  (
    [s].[Id],
    [s].[StatusCode],
    [s].[StatusDescription],
    [s].[Header],
    [s].[Body],
    [s].[Comment]
  )
WHEN MATCHED
  THEN
  UPDATE
  SET [t].[StatusCode]        = [s].[StatusCode],
      [t].[StatusDescription] = [s].[StatusDescription],
      [t].[Header]            = [s].[Header],
      [t].[Body]              = [s].[Body],
      [t].[Comment]           = [s].[Comment],
      [t].[DateModified]      = GETDATE();
GO
