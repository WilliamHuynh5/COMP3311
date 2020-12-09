-- COMP3311 20T3 Final Exam
-- Q4: list of long and short songs by each group

-- ... helper views and/or functions (if any) go here ...

drop function if exists q4();
drop type if exists SongCounts;
create type SongCounts as ( "group" text, nshort integer, nlong integer );

create or replace function q4() returns setof SongCounts 
as $$
declare
	g groups;
	ret SongCounts;
begin
	for g in (select * from groups) loop
		ret.nshort := 0;
		ret.nlong := 0;
		ret."group" := g.name;
		select count(distinct s.id) into ret.nshort
		from albums as a, songs as s
		where s.length < 180 and a.made_by = g.id and s.on_album = a.id;
		select count(distinct s.id) into ret.nlong
		from albums as a, songs as s
		where s.length > 360 and a.made_by = g.id and s.on_album = a.id;	
		return next ret;
	end loop;
end;
$$ language plpgsql;
