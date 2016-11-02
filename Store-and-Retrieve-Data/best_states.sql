SELECT
h.State,
ROUND(AVG(ec.Score)) AvgScore,
ROUND(variance(ec.Score)) VarScore,
COUNT(ec.Score) SumScore
FROM effective_care_parquet ec
LEFT JOIN hospitals_parquet h ON ec.ProviderID = h.ProviderID
GROUP BY h.State
ORDER BY AvgScore DESC
LIMIT 10;
