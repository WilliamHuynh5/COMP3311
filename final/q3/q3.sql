-- COMP3311 20T3 Final Exam
-- Q3:  performer(s) who play many instruments

-- ... helper views (if any) go here ...

drop view if exists q3_1 cascade;
drop view if exists q3 cascade;

create or replace view q3_1(performer, name) as
select performer, instrument from playson where instrument not in ('lead guitar', 'rythm guitar', 'acoustic guitar','guitars') and instrument <> 'vocals'
union
select performer, 'guitar' from playson where instrument in ('lead guitar', 'rythm guitar', 'acoustic guitar','guitars');

create or replace view q3(performer,ninstruments) as
select p.name, count(distinct q.name)
from performers as p, q3_1 as q
where p.id = q.performer
group by p.id 
having 2 * count(distinct q.name) > (select count(distinct name) from q3_1);

