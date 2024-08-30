1) Share the SQL query to remove all duplicate data from the employee table

with cte as (
select *,
row_number() over(partition by employeeid, empname, departmentid, EmpCTC order by employeeid asc) as rn
from employee)
select employeeid, empname, departmentid, empctc
from cte
where rn = 1

2) Share the SQL query to find the top 2nd most earning employee name from each department (department name)

with cte as (
select e.employeeid, e.empname, d.departmentid, d.departmentname, e.EmpCTC,
DENSE_RANK() over(partition by d.departmentname order by EmpCTC DESC) as rank
from employee e
join department d
on e.departmentid = d.departmentid
)
select empname, departmentname
from cte where rank = 2

3) Share the SQL query to find the employee worked in most of departments

with cte as ( select employeeid, empname, departmentid
from employee
group by employeeid, empname, departmentid
), cte1 as (select employeeid, empname, count(*) as count_of_departmentid,
DENSE_RANK() over(order by count(*) desc) as rank
from cte
group by employeeid, empname
) 
select employeeid, empname 
from cte1
where rank = 1
