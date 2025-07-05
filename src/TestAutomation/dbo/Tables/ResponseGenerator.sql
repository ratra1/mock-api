CREATE TABLE [dbo].[ResponseGenerator] (
    [Id]                INT             CONSTRAINT [DF_ResponseGenerator_Id] DEFAULT ((1)) NOT NULL,
    [StatusCode]        INT             CONSTRAINT [DF_ResponseGenerator_StatusCode] DEFAULT ((200)) NOT NULL,
    [StatusDescription] VARCHAR (500)   CONSTRAINT [DF_ResponseGenerator_StatusDescription] DEFAULT ('') NOT NULL,
    [Header]            NVARCHAR (MAX)  CONSTRAINT [DF_ResponseGenerator_Header] DEFAULT ('{"Content-Type": "application/json"}') NOT NULL,
    [Body]              NVARCHAR (MAX)  CONSTRAINT [DF_ResponseGenerator_Body] DEFAULT ('') NOT NULL,
    [Comment]           NVARCHAR (3000) CONSTRAINT [DF_ResponseGenerator_Comment] DEFAULT ('') NOT NULL,
    [DateModified]      DATETIME2 (7)   CONSTRAINT [DF_ResponseGenerator_DateModified] DEFAULT (getdate()) NOT NULL,
    [Ts]                ROWVERSION      NOT NULL,
    CONSTRAINT [PK_ResponseGenerator_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);

