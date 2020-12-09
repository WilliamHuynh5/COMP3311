-- COMP3311 20T3 Final Exam
-- Q1: longest album(s)

-- ... helper views (if any) go here ...
drop view if exists q11s cascade;
drop view if exists q1 cascade; 
create or replace view q11s(id, tol) as
select s.on_album, sum(s.length)
from Songs as s
group by s.on_album;

create or replace view q1("group",album,year) as
select g.name, a.title, a.year
from groups as g, albums as a, q11s as q
where g.id = a.made_by and a.id = q.id and q.tol = (select max(tol) from q11s); 

