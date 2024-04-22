/*Comparing PROC SQL with SAS DATA Step */

proc import datafile = "/home/u61870367/score_data_id" 
DBMS = xlsx out = score_data ;
run;

/*get obs/rows with gender = 'm'*/

proc sql;
   create table scoredata0 as
   select stu_id,
          gender,
          name
   from score_data
   where gender in  ('m');
quit;

data scoredata1;
set score_data;
if gender in  ('m');
keep stu_id gender name;
run;

proc print data = scoredata0;
title ' data from proc sql';
run;

proc print data = scoredata1;
title ' data from data step';
run; /*Both way, you would get the same result */


/*SELECT statement & its clauses*/

proc sql;
   create table scoredata0 as
   select *
   from score_data
   where gender in  ('m')
   order by name;
quit;
proc print data = scoredata0;
run;

/* The following query uses the MEAN function to list the average 
of score1 of each gender.  The GROUP BY clause groups the students by gender, 
and the ORDER BY clause puts the values of gender in  alphabetical order */

proc sql;
   create table scoredata1 as
   select *, 
   mean(score1)as score1_ave,
   mean(score2)as score2_ave,
   mean(score3)as score3_ave
   
   from score_data
   group by gender
   order by gender;
quit;
proc print data = scoredata1;
run;

/*The having clause restricts the groups to include only gender = ‘f’ (female) in the query's results*/
proc sql;
   create table scoredata2 as
   
   select *, 
   mean(score1)as score1_ave,
   mean(score2)as score2_ave,
   mean(score3)as score3_ave
   
   from score_data
   group by gender
   having gender = 'f'
   order by gender;
quit;
proc print data = scoredata2;
run;


/*eliminating duplicate rows*/

proc import datafile = "/home/u61870367//score_data_id_dups" 
DBMS = xlsx out = score_data replace ;
run;

proc sql;
SELECT gender
FROM score_data;
quit;

proc sql;
SELECT DISTINCT gender
FROM score_data;
quit;

proc sql;
SELECT DISTINCT * /*Outputs only unique records in the table */
FROM score_data
ORDER BY name;
quit;


/*To obtain a list of all of the columns in a table and their attributes*/

proc sql;
   describe table score_data;

/*create columns*/

proc import datafile = "/home/u61870367/score_data_id" 
DBMS = xlsx out = score_data ;
run;

/*Adding Text to Output*/
proc sql;
select "Math Score 1 for", Name, "is", Score1
      from score_data;

/*PROC SQL does not output the column name when a label is assigned, 
and it does not output labels that begin with special characters. */
proc sql;
select "Math Score 1 for", Name label='#', "is", Score1 label='#'
      from score_data;


/*Calculating Values, Assigning a Column Alias,
Referring to a Calculated Column by Alias*/
proc sql;
   create table scoredata1 as
/*By specifying a column alias, you can assign a new name 
to any column within a PROC SQL query.*/   
select *, 
   mean(score1) as score1_ave format 4.1 ,
   mean(score2) as score2_ave format 4.1 ,
   mean(score3) as score3_ave format 4.1 ,
/*When you use a column alias to refer to a calculated value, you must 
use the CALCULATED keyword with the alias to inform PROC SQL that the 
value is calculated within the query. */
(Calculated score1_ave - Calculated score2_ave)
                   as Diff12 format=4.1

   from score_data
   group by gender
   order by gender;
quit;

proc print data = scoredata1;
run;


/* assign values conditionally*/


proc import datafile = "/home/u61870367/score_data_id" 
DBMS = xlsx out = score_data replace;
run; /*vars: score 1-3, gender*/

/*Using a Simple CASE Expression  --- can use comparison operators or other types of operators
Please Note: You must close the CASE logic with the END keyword.*/
proc sql;
   select *,
   sum (score1, score2, score3 )/3 as score_ave,
          case
             when Calculated score_ave >= 90 then 'A'
             when 80 <= Calculated score_ave < 90 then 'B'
             when 70 <= Calculated score_ave < 80 then 'C'
             when 60 <= Calculated score_ave < 70 then 'D'
             when 0< Calculated score_ave < 60 then 'F'
             else 'Absent'
          end as Grade
      from score_data
      order by Name;
quit;      
      
/*Using the CASE-OPERAND Form --- must all be equality tests*/

proc sql;
   select *,
          case gender
             when 'f' then 'female'
             when 'm' then 'male'
          end as gender_new
      from score_data
      order by Name;
quit;         

/*replace missing values*/

	/score_data_miss" 
DBMS = xlsx out = score_data replace;
run; /*score1, gender*/

/*using Coalesce function: 
The COALESCE function enables you to replace missing values in a column with a new value that you specify.
The following query 
replaces missing values in the Score1 column in the score_data table with the value -7
and replaces missing values in the Gender column with the word Missing */
proc sql;
select Name, 
coalesce(score1, -7) as score1, 
coalesce(gender, 'Missing') as gender
from score_data;
quit;

/* use Case expression:
The following CASE expression shows another way to perform the same replacement of missing values. 
However, the COALESCE function requires fewer lines of code to obtain the same results */
proc sql;
select Name, 

case
when Score1 = . then -7
     else Score1
end as Score1,

case
when Gender = ' ' then 'Missing'
     else Gender
end as Gender

from score_data;
quit;


/*sorting data --- Order By clause*/

proc import datafile = "/home/u61870367/score_data_miss" 
DBMS = xlsx out = score_data replace;
run;

/*sort by one or multiple columns (the column names separated by commas)
Note: The results list student with missing Gender first 
because PROC SQL sorts missing values first in an ascending sort.*/
proc sql;
select *
from score_data
order by Gender, Name desc;
quit;

/*Sorting by Calculated Column
You can sort by a calculated column by specifying its alias in the ORDER BY clause. */
proc sql;
   select *, sum (score1, score2, score3 )/3 as score_ave
      from score_data
      order by score_ave;
quit;      

/*Sorting by Column Position
You can sort by any column within the SELECT clause by specifying its numerical position. 
By specifying a position instead of a name, 
you can sort by a calculated column that has no alias*/

proc sql;
   select name, score1, score2, score3,gender, sum (score1, score2, score3 )/3 /*as score_ave*/
      from score_data
      order by 6;
quit;

/* Sorting by Columns That Are Not Selected
You can sort query results by columns that are not included in the query. */
proc sql;
   select name, score1, score2, score3,/*gender*/ sum (score1, score2, score3 )/3 /*as score_ave*/
      from score_data
      order by gender desc, 5; /*need to change the position of the calculated column*/
quit;

/*Summarizing Data*/

/*Overview of Summarizing Data
You can use an aggregate function (or summary function) to produce a statistical summary of 
data in a table. 
The aggregate function instructs PROC SQL in how to combine data in one or 
more columns. 
when you use an aggregate function, PROC SQL applies the function to the entire table, 
unless you use a GROUP BY clause. You can use aggregate functions in the SELECT or HAVING clauses.
*/
proc import datafile = "/home/u61870367/score_data_miss" 
DBMS = xlsx out = score_data replace;
run;

/*Using the MEAN Function with a WHERE Clause*/
proc sql;
   SELECT *, mean (score1, score2, score3 ) AS score_mean
      FROM score_data
      WHERE calculated score_mean >= 0
      ORDER BY score_mean;
quit; 

/*Displaying Sums*/
/*The SUM function produces a single row of output for the requested sum
because no non-aggregate value appears in the SELECT clause.
--- an example of PROC SQL combined information from multiple rows of data 
into a single row of output:*/

proc sql;
   SELECT sum(score1) AS score1_sum
      FROM score_data;
quit; 

/*Remerging Summary Statistics
Aggregate functions, such as the MAX function, can cause the same calculation to 
repeat for every row. This occurs whenever PROC SQL remerges data. */
proc sql;
   SELECT *,mean(score1, score2, score3 ) AS score_mean,
   max(calculated score_mean) AS max_mean, min(calculated score_mean) AS min_mean
      FROM score_data;
      ORDER BY score_mean;
quit; 

/*Using Aggregate Functions with Unique Values*/
/*Counting Unique Values
You can use DISTINCT with an aggregate function to cause the function to use only unique 
values from a column.*/
proc sql;
   SELECT COUNT(DISTINCT gender) AS count
      FROM score_data;
quit; *2;

/*Counting Nonmissing Values --- all nonmissing values are counted including duplicated values 
Compare the previous example with the following query, which does not use 
the DISTINCT keyword. */
proc sql;
   select COUNT(gender) AS count
      FROM score_data;
quit; *11;

/*Counting All Rows
In the previous two examples, the missing values are ignored by the COUNT function. 
To obtain a count of all rows in the table: */
proc sql;
   SELECT count(*) AS total_num
      FROM score_data;
quit; *12;


