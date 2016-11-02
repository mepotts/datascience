SELECT ec.ProviderID,
MAX(h.State) State,
ROUND(AVG(ec.Score)) AvgScore,
ROUND(AVG(sr.HCAHPSBaseScore)) SurveyScore
FROM effective_care_parquet ec
LEFT JOIN hospitals_parquet h ON ec.ProviderID = h.ProviderID
LEFT JOIN surveys_responses_parquet sr ON ec.ProviderID = sr.ProviderID
GROUP BY ec.ProviderID
ORDER BY SurveyScore DESC
LIMIT 10;


SELECT
h.State,
ROUND(AVG(ec.Score)) AvgScore,
ROUND(AVG(sr.HCAHPSBaseScore)) SurveyScore
FROM effective_care_parquet ec
LEFT JOIN hospitals_parquet h ON ec.ProviderID = h.ProviderID
LEFT JOIN surveys_responses_parquet sr ON ec.ProviderID = sr.ProviderID
GROUP BY h.State
ORDER BY SurveyScore DESC
LIMIT 25;
