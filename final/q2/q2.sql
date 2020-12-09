-- COMP3311 20T3 Final Exam
-- Q2: group(s) with no albums

-- ... helper views (if any) go here ...
drop view if exists q2;

create or replace view q2("group") as
select g.name
from groups as g left outer join albums as a on (g.id = a.made_by)
group by g.id
having count(a.made_by) = 0;

