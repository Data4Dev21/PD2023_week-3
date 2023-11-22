/*Data Source Bank has some quarterly targets for the value of transactions that are being performed in-person and online.
It's our job to compare the transactions to these target figures.

Input the data
For the transactions file:
Filter the transactions to just look at DSB (help)
These will be transactions that contain DSB in the Transaction Code field
Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values
Change the date to be the quarter (help)
Sum the transaction values for each quarter and for each Type of Transaction (Online or In-Person) (help)
For the targets file:
Pivot the quarterly targets so we have a row for each Type of Transaction and each Quarter (help)
 Rename the fields
Remove the 'Q' from the quarter field and make the data type numeric (help)
Join the two datasets together (help)
You may need more than one join clause!
Remove unnecessary fields
Calculate the Variance to Target for each row (help)
Output the data*/

--A.For the transactions file: 

--1.Filter the transactions to just look at DSB 
SELECT *
    FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK01
    WHERE TRANSACTION_CODE LIKE '%DSB_%';
    
--2.Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values
SELECT CASE
       WHEN online_or_in_person = 1 THEN 'Online'
       ELSE 'In-person'
       END AS online_or_in_person
    FROM "TIL_PLAYGROUND"."PREPPIN_DATA_INPUTS"."PD2023_WK01";

--3.Change the date to be the quarter 
select quarter(to_date(transaction_date, 'DD/MM/YYYY 00:00:00')) AS quarter
       from "TIL_PLAYGROUND"."PREPPIN_DATA_INPUTS"."PD2023_WK01"; 

--4.Sum the transaction values for each quarter and for each Type of Transaction (Online or In-Person) 
select online_or_in_person
      ,quarter(to_date(transaction_date, 'DD/MM/YYYY 00:00:00')) AS quarter
      ,sum(value) AS total_value
    from "TIL_PLAYGROUND"."PREPPIN_DATA_INPUTS"."PD2023_WK01"
    group by 1,2
    order by 1,2;        
    
--1,2,3.Filter the transactions to just look at DSB 
SELECT 
       CASE WHEN online_or_in_person = 1 THEN 'Online'
       ELSE 'In-Person'
       END AS online_or_in_person
      ,quarter(to_date(transaction_date, 'DD/MM/YYYY 00:00:00')) AS quarter
      ,sum(value)
    FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK01
    WHERE TRANSACTION_CODE LIKE '%DSB_%'
    GROUP BY 1,2
    ORDER BY 1,2;

--B.For the target file: 
select *
    from TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK03_TARGETS;

--Pivot the quarterly targets so we have a row for each Type of Transaction and each Quarter 
SELECT online_or_in_person
      ,cast(replace(quarter, 'Q', '') as int) as quarter
      ,quarterly_targets
FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK03_TARGETS
    UNPIVOT(quarterly_targets FOR quarter IN (q1, q2, q3, q4) ;--(Unpivot: row to column)

--Joining the two tables

WITH cte AS 
(
SELECT 
       CASE WHEN tr.online_or_in_person = 1 THEN 'Online'
       ELSE 'In-Person'
       END AS online_or_in_person
      ,quarter(to_date(tr.transaction_date, 'DD/MM/YYYY 00:00:00')) AS quarter
      ,sum(tr.value) AS value
    FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK01 tr
    WHERE TRANSACTION_CODE LIKE '%DSB_%'
    GROUP BY 1,2
    --ORDER BY 1,2
)
SELECT tr.online_or_in_person
      --,tr.quarter
      --,online_or_in_person
      ,cast(replace(t.quarter, 'Q', '') as int) as quarter
      ,tr.value
      ,quarterly_targets
      ,(value-quarterly_targets) as variance
FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK03_TARGETS t
     UNPIVOT(quarterly_targets FOR quarter IN (q1, q2, q3, q4)) 
join cte tr on t.ONLINE_OR_IN_PERSON = tr.online_or_in_person and cast(replace(t.quarter, 'Q', '') as int) = tr.quarter;     
