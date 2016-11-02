SELECT h.HospitalName,
MAX(h.City) City,
MAX(h.State) State,
ROUND(AVG(ec.Score)) AvgScore,
ROUND(variance(ec.Score)) VarScore
FROM effective_care_parquet ec
LEFT JOIN hospitals_parquet h ON ec.ProviderID = h.ProviderID
GROUP BY h.HospitalName
ORDER BY AvgScore DESC
LIMIT 10;
