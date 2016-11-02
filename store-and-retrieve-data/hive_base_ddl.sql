#Create schema for the hospitals table

DROP TABLE IF EXISTS hospitals;
CREATE EXTERNAL TABLE IF NOT EXISTS hospitals
(ProviderID string,
HospitalName string,
Address string,
City string,
State string,
ZIPCode string,
CountyName string,
PhoneNumber string,
HospitalType string,
HospitalOwnership string,
EmergencyServices string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar" = '"',
"escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/hospital_compare/hospitals';

#Create schema for the measures table

DROP TABLE IF EXISTS measures;
CREATE EXTERNAL TABLE IF NOT EXISTS measures
(MeasureName string,
MeasureID string,
MeasureStartQuarter string,
MeasureStartDate date,
MeasureEndQuarter string,
MeasureEndDate date
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar" = '"',
"escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/hospital_compare/measures';


#Create schema for the effective_care table

DROP TABLE IF EXISTS effective_care;
CREATE EXTERNAL TABLE IF NOT EXISTS effective_care
(ProviderID string,
HospitalName string,
Address string,
City string,
State string,
ZIPCode string,
CountyName string,
PhoneNumber string,
Condition string,
MeasureID string,
MeasureName string,
Score varchar(550),
Sample string,
Footnote string,
MeasureStartDate date,
MeasureEndDate date
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar" = '"',
"escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/hospital_compare/effective_care';


#Create schema for the readmissions table

DROP TABLE IF EXISTS readmissions;
CREATE EXTERNAL TABLE IF NOT EXISTS readmissions
(ProviderID string,
HospitalName string,
Address string,
City string,
State string,
ZIPCode string,
CountyName string,
PhoneNumber string,
MeasureName string,
MeasureID string,
ComparedtoNational string,
Denominator string,
Score string,
LowerEstimate string,
HigherEstimate string,
Footnote string,
MeasureStartDate date,
MeasureEndDate date
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar" = '"',
"escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/hospital_compare/readmissions';

#Create schema for the surveys_responses table

DROP TABLE IF EXISTS surveys_responses;
CREATE EXTERNAL TABLE IF NOT EXISTS surveys_responses
(ProviderNumber string,
HospitalName string,
Address string,
City string,
State string,
ZIPCode string,
CountyName string,
CommunicationwithNursesAchievementPoints string,
CommunicationwithNursesImprovementPoints string,
CommunicationwithNursesDimensionScore string,
CommunicationwithDoctorsAchievementPoints string,
CommunicationwithDoctorsImprovementPoints string,
CommunicationwithDoctorsDimensionScore string,
ResponsivenessofHospitalStaffAchievementPoints string,
ResponsivenessofHospitalStaffImprovementPoints string,
ResponsivenessofHospitalStaffDimensionScore string,
PainManagementAchievementPoints string,
PainManagementImprovementPoints string,
PainManagementDimensionScore string,
CommunicationaboutMedicinesAchievementPoints string,
CommunicationaboutMedicinesImprovementPoints string,
CommunicationaboutMedicinesDimensionScore string,
CleanlinessandQuietnessofHospitalEnvironmentAchievementPoints string,
CleanlinessandQuietnessofHospitalEnvironmentImprovementPoints string,
CleanlinessandQuietnessofHospitalEnvironmentDimensionScore string,
DischargeInformationAchievementPoints string,
DischargeInformationImprovementPoints string,
DischargeInformationDimensionScore string,
OverallRatingofHospitalAchievementPoints string,
OverallRatingofHospitalImprovementPoints string,
OverallRatingofHospitalDimensionScore string,
HCAHPSBaseScore int,
HCAHPSConsistencyScore int
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar" = '"',
"escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/hospital_compare/surveys_responses';
