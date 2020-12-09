-- COMP3311 20T3 Final Exam
-- Q5: find genres that groups worked in

-- ... helper views and/or functions go here ...

drop function if exists q5();
drop type if exists GroupGenres;

create type GroupGenres as ("group" text, genres text);

create or replace function q5() returns setof GroupGenres
as $$
declare
	g groups;
	curr text; 
	ret GroupGenres;
begin
	for g in (select * from groups) loop
		ret."group" = g.name;
		ret.genres = '';
		for curr in (select distinct genre from albums where made_by = g.id order by genre) loop
			if ret.genres = '' then
				ret.genres := curr;
			else
				ret.genres := ret.genres || ',' || curr;
			end if;
		end loop;
		return next ret;
	end loop;
end;
$$ language plpgsql;

