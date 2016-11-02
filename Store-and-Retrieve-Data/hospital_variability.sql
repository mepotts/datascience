SELECT 
ec.Condition,
ROUND(variance(ec.Score)) VarScore
FROM effective_care_parquet ec
GROUP BY ec.Condition
ORDER BY VarScore DESC;
