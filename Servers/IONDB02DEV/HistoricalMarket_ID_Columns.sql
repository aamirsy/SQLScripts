USE HistoricalMarketTradesDB
GO
SELECT COUNT(*) FROM dbo.TRACE

SELECT DISTINCT COUNT(Id) FROM dbo.TRACE

SELECT ID,tradeDate,TradeSeqNo, Count(*) from dbo.TRACE (NOLOCK)
GROUP BY ID,tradeDate, TradeSeqNo
HAVING COUNT(*) > 1

SELECT * FROM dbo.TRACE
WHERE ID = '369604BC6_37528' AND 
TradeDate = '2017-02-13 00:00:00.000'
AND tradeSeqNo = 37528

SELECT bbgId, COUNT(*) from dbo.TRACE (NOLOCK)
GROUP BY bbgId
HAVING COUNT(*) > 1
