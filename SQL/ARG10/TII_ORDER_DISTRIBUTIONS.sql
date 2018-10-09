USE [ARG10]
GO

/****** Object:  StoredProcedure [dbo].[TII_ORDER_DISTRIBUTIONS]    Script Date: 07/10/2018 18:10:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TII_ORDER_DISTRIBUTIONS]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TII_ORDER_DISTRIBUTIONS]
GO

USE [ARG10]
GO

/****** Object:  StoredProcedure [dbo].[TII_ORDER_DISTRIBUTIONS]    Script Date: 07/10/2018 18:10:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[TII_ORDER_DISTRIBUTIONS] @VCHRNMBR CHAR(21) 
AS

DECLARE @LASTDSTSQ INT, @LASTSPECDIST INT, @SPCLDIST INT

SELECT @LASTDSTSQ = MAX(DSTSQNUM) FROM PM10100 WHERE VCHRNMBR = @VCHRNMBR AND SPCLDIST = 0
SELECT @LASTSPECDIST = MAX(DSTSQNUM) FROM PM10100 WHERE VCHRNMBR = @VCHRNMBR AND SPCLDIST = 1

IF @LASTSPECDIST > @LASTDSTSQ
BEGIN
	RETURN
END

DECLARE DISTRIBUCIONES CURSOR STATIC FOR SELECT DSTSQNUM FROM PM10100 WHERE VCHRNMBR = @VCHRNMBR AND SPCLDIST = 1 ORDER BY SPCLDIST
OPEN DISTRIBUCIONES
FETCH NEXT FROM DISTRIBUCIONES INTO @SPCLDIST 
WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @LASTDSTSQ = @LASTDSTSQ + 16384
	UPDATE PM10100 SET DSTSQNUM = @LASTDSTSQ WHERE VCHRNMBR = @VCHRNMBR AND DSTSQNUM = @SPCLDIST
	IF EXISTS(SELECT name from sysobjects where name = 'AAG20000' AND xtype = 'U')
	BEGIN
		UPDATE AAG20001 SET SEQNUMBR = @LASTDSTSQ 
		FROM AAG20000 A INNER JOIN AAG20001 B ON A.aaSubLedgerHdrID = B.aaSubLedgerHdrID
		WHERE A.DOCNUMBR = @VCHRNMBR AND A.SERIES = 4 AND A.DOCTYPE = 1 AND B.SEQNUMBR = @SPCLDIST
	END
	FETCH NEXT FROM DISTRIBUCIONES INTO @SPCLDIST 
END

CLOSE DISTRIBUCIONES
DEALLOCATE DISTRIBUCIONES




GO

