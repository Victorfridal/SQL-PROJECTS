/* Crash Report Data Exploration 
Skills used: Common Where Clause, Group by,Sub-queries,Views,
Stored Procedures, Joins, Case Statements Etc
*/

-- Select Tables we are going to be working on 

select * from Carcrashproject..crash_report_drivers;

select * from Carcrashproject..crash_report_Non_motorist;

-- we will be starting with the Crash_Report_drivers table 

-- Analysis looking at the frequency of crash incident overtime and identifying any patterns and trends 
select 
convert(Date,Crash_date_time) as Crash_dates,
  Count(*) as Num_crashes
from Carcrashproject..crash_report_drivers
group by 
Convert(Date,crash_date_time)
order by crash_dates;

-- Looking at the top 10 Areas with High frequency of crashes 


select top 10  route_type,road_name,municipality,count(*) as num_crashes 
from CarCrashProject..Crash_Report_Drivers
where Route_type is not null
group by route_type,road_name,municipality
order by num_crashes desc


--Analyzing the primary causes of crashes in different conditions and scenerios

select weather, 
	  surface_condition,
	  light,
	  traffic_control,
	  driver_substance_abuse,
	  driver_distracted_by,
	  count(*) as crash_count
	from 
	CarCrashProject..crash_report_drivers
	group by 
	weather, 
	  surface_condition,
	  light,
	  traffic_control,
	  driver_substance_abuse,
	  driver_distracted_by
	  order by 
	  crash_count desc

/*Looking at the percentage where the driver was at fault and
the speed limit they went 
*/

select Municipality,
AVG(Speed_limit) as 
average_speed_limt,
	(count(Case When Driver_At_Fault =
	'Yes' Then 1 End )) * 100.0 / COUNT(*)
AS
	Percentage_at_fault
FROM 
CarCrashProject..Crash_Report_Drivers
--Where Municipality is not null
group by 
	municipality
order by 
average_speed_limt desc

-- Looking at the Vehicles that are more prone to accidents 

Select Vehicle_Make,Vehicle_model,vehicle_year,Vehicle_body_type,
COUNT(*) As Num_Accidents
from 
CarCrashProject..Crash_Report_Drivers
Group by Vehicle_Make,Vehicle_model,vehicle_year,Vehicle_body_type
order by Num_Accidents DESC



-- Lets join the Tables and Analyze 



select * from CarCrashProject..Crash_Report_Drivers cd
join CarCrashProject..Crash_Report_Non_Motorist cnd 
on cd.ACRS_Report_Type = cnd.ACRS_Report_Type



-- Looking at the most common pedestrian actions and aggregating the data to find the total numbers of pedestrian involved in crashes 


Select cnd.Municipality,
pedestrian_actions,
count(*) As 
Num_crashes_involving_pedestrian
from 
	CarCrashProject..Crash_Report_Non_Motorist cnd 
join
	CarCrashProject..Crash_Report_Drivers cd 
ON cnd.Report_Number = cd.Report_Number
Where 
cnd.Municipality is not null AND
cnd.Pedestrian_Actions IS NOT NULL
GROUP BY 
cnd.Municipality,Pedestrian_Actions
ORDER BY 
Num_crashes_involving_pedestrian DESC

-- Lets create a view to Analyze the injury severity for both "Motorist" and "Non-Motorist" involved in crashes 
Create View CrashInjurySeverity AS
Select 'Motorist' AS Participant_Type,
					Report_Number,
					Driver_At_Fault,
					Injury_severity,
					weather,
					surface_condition
FROM CarCrashProject..Crash_Report_Drivers
UNION ALL
SELECT 'Pedestrian' AS Participant_Type,
					Report_Number,
					At_Fault,
					Injury_severity,
					weather,
					surface_condition
FROM CarCrashProject..Crash_Report_Non_Motorist

SELECT * from CrashInjurySeverity

/*CTE to find the Highest Average Speed Limit for each Municipality 
And the top 5 municipality with the highest speed limit
*/



WITH AvgSpeedByMunicipality
AS (
    SELECT 
        Municipality,
        AVG(Speed_Limit) AS Avg_Speed_Limit
    FROM 
        CarCrashProject..Crash_Report_Drivers
    WHERE 
        Speed_Limit IS NOT NULL
    GROUP BY 
        Municipality
)

SELECT 
    Municipality,
    Avg_Speed_Limit
FROM 
    (
        SELECT 
            Municipality,
            Avg_Speed_Limit,
            ROW_NUMBER() OVER (ORDER BY Avg_Speed_Limit DESC) AS Row_Num
        FROM 
            AvgSpeedByMunicipality
    ) AS ranked
WHERE 
    Row_Num <= 5;
