CREATE TABLE [dbo].[Request] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Method]      VARCHAR (7)    CONSTRAINT [DF_Request_Method] DEFAULT ('') NOT NULL,
    [URL]         NVARCHAR (MAX) CONSTRAINT [DF_Request_URL] DEFAULT ('') NOT NULL,
    [Header]      NVARCHAR (MAX) CONSTRAINT [DF_Request_Header] DEFAULT ('') NOT NULL,
    [Body]        NVARCHAR (MAX) CONSTRAINT [DF_Request_Body] DEFAULT ('') NOT NULL,
    [DateCreated] DATETIME2 (7)  CONSTRAINT [DF_Request_DateCreated] DEFAULT (getdate()) NOT NULL,
    [Ts]          ROWVERSION     NOT NULL,
    CONSTRAINT [PK_Request_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);

