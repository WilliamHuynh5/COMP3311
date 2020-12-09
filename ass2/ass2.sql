-- Q1
-- quite simple, strategy: find all people such that id is in the
-- id which has > 65 course enrolments
drop view if exists Q1 cascade;
create or replace view Q1(unswid, name) as
select p.unswid, p.name
from People as p
where p.id in (
	select s.id 
	from Students as s, Course_enrolments as c 
	where s.id = c.student
	group by s.id
	having count(*) > 65 -- be careful here is more than no =
);


-- Q2
-- set operations: _1 and _2 are set difference, _3 is set intersection
drop view if exists Q2_1 cascade;
drop view if exists Q2_2 cascade;
drop view if exists Q2_3 cascade;
drop view if exists Q2 cascade;
create or replace view Q2(nstudents, nstaff, nboth) as
select 
	(select count(*) from Students
	where id in (select id from Students except select id from Staff)) 
	as nstudents, -- division
	(select count(*) from Staff
	where id in (select id from Staff except select id from Students))
	as nstaff, -- division
	(select count(*) from Staff 
	where id in (select id from Staff intersect select id from Students))
	as nboth; -- intersection

-- Q3
drop view if exists Q3 cascade;
drop view if exists Q3_ncourse cascade; -- similar to the nbeer in the lecture
create or replace view Q3_ncourse as
select p.id, p.name, count(*) as ncourse
from People as p, Staff as s, Staff_roles as r, Course_staff as c
where p.id = s.id and s.id = c.staff 
      and r.id = c.role and r.name = 'Course Convenor'
group by p.id, p.name;
-- now we can finish up the problem
create or replace view Q3(name, ncourses) as
select name, ncourse  
from Q3_ncourse
where ncourse = (select max(ncourse) from Q3_ncourse);


-- Q4
drop view if exists Q4a cascade;
drop view if exists Q4b cascade;
create or replace view Q4a(id, name) as
select p.unswid, p.name
from Students as s, People as p, Program_enrolments as pe,
     Programs as pg, Terms as t
where s.id = p.id and pe.student = s.id and pe.term = t.id 
      and pe.program = pg.id and t.year = 2005 and t.session = 'S2'
      and pg.code = '3978';
-- exactly the same just change the year and session
create or replace view Q4b(id, name) as
select p.unswid, p.name
from Students as s, People as p, Program_enrolments as pe,
     Programs as pg, Terms as t
where s.id = p.id and pe.student = s.id and pe.term = t.id 
      and pe.program = pg.id and t.year = 2017 and t.session = 'S1'
      and pg.code = '3778';

-- Q5
-- we firstly generate a view with all commitees and its direct faculty
drop view if exists Q5_fac_cnt cascade;
create or replace view Q5_fac_cnt as
select f.id as fid, c.id as cid
from OrgUnits as f, OrgUnits as c, OrgUnit_groups as g, 
	 OrgUnit_types as tp1, OrgUnit_types as tp2
where f.id = g.owner and c.id = g.member -- faculty and committee 
	  and tp1.id = f.utype and tp2.id = c.utype
	  and tp1.name = 'Faculty' and tp2.name = 'Committee';  

-- next we find the schools and all commities directly 
-- associated with it
drop view if exists Q5_sch_cnt cascade;
create or replace view Q5_sch_cnt as
select f.id as fid, c.id as cid
from OrgUnits as f, OrgUnits as c, OrgUnit_groups as g, 
	 OrgUnit_types as tp1, OrgUnit_types as tp2
where f.id = g.owner and c.id = g.member -- school and committee 
	  and tp1.id = f.utype and tp2.id = c.utype
	  and tp1.name = 'School' and tp2.name = 'Committee';
-- then we constuct the "union" of the previous 2 views
drop view if exists Q5_fac_sch cascade;
create or replace view Q5_fac_sch as
select o.id as faculty, q.cid as committee 
from OrgUnits as o, Q5_sch_cnt as q
where o.id = facultyof(q.fid)
union 
select fid as faculty, cid as committee
from Q5_fac_cnt;
-- create the (faculty id, count committee) view, 
-- must do left outer join!! to avoid the case when all count = 0
drop view if exists Q5_fac_com cascade;
create or replace view Q5_fac_com as
select o.id as faculty, count(q.committee) as ncom
from OrgUnits as o
	left outer join Q5_fac_sch as q on o.id = q.faculty
where o.utype in (select id from OrgUnit_types where name = 'Faculty')
group by o.id;

-- get the answer
drop view if exists Q5 cascade;
create or replace view Q5(name) as
select o.name 
from Q5_fac_com as q, OrgUnits as o 
where q.faculty = o.id and ncom = (select max(ncom) from Q5_fac_com);


-- Q6
-- just a set union operation
create or replace function Q6(id integer) returns text
as $$
	select distinct name from People where id = $1
	union 
	select distinct name from People where unswid = $1;
$$ language sql;

-- Q7
create or replace function Q7(subject text)
	returns table (subject text, term text, conventor text)
as $$
	select text(s.code), termname(t.id), p.name
	from Subjects as s, Terms as t, People as p, Staff as st,
		Course_staff as cs, Courses as c, Staff_roles as r
    where s.id = c.subject and t.id = c.term and cs.course = c.id
    	and cs.staff = st.id and st.id = p.id and r.id = cs.role
    	and r.name = 'Course Convenor' and text(s.code) = $1;
$$ language sql;

-- Q8
-- method: firstly select all the required fields with a join of 7 tables
-- then perform the calculation
create or replace function Q8(zid integer)
	returns setof TranscriptRecord
as $$
declare
	curr TranscriptRecord;
	it   Record;
	cnt  integer;
	totaluoc integer;
	uocpass integer;
	weightmark integer;
begin
	select count(*) into cnt	
	from Students as s, People as p
	where s.id = p.id and p.unswid = zid;
	
	if cnt = 0 then
		raise exception 'Invalid student %', zid;
	end if;
	cnt := 0;
	totaluoc := 0;
	uocpass := 0;
	weightmark := 0;
	for it in 
		(select s.code as sc, t.id as tm, pg.code as pc,
				s.name as nm, ce.mark as mk, ce.grade as gd, s.uoc as cd
		from Programs as pg, Program_enrolments as pe,
				Subjects as s, Courses as c, Course_enrolments as ce,
				Terms as t, People as p
		where p.id = ce.student and pg.id = pe.program 
				and p.unswid = zid and pe.student = ce.student 
				and ce.course = c.id and pe.term = t.id 
				and c.term = t.id and c.subject = s.id
		order by t.id)
	loop
		curr.code := it.sc;
		curr.term := termname(it.tm);
		curr.prog := it.pc;
		curr.name := substr(it.nm, 1, 20);
		curr.mark := it.mk;
		curr.grade := it.gd;
		curr.uoc := null;
		if curr.grade is not null and it.cd is not null then -- don't include any with null grade
			totaluoc := totaluoc + it.cd; -- avoid add null
		end if;
		if curr.grade in ('SY', 'PT', 'PC', 'PS', 
				'CR', 'DN', 'HD', 'A', 'B', 'C', 'XE', 'T', 'PE', 'RC', 'RS') then
			if it.cd is not null then  -- avoid add null
				curr.uoc := it.cd;
				uocpass := uocpass + it.cd;
			end if;
			if curr.grade in ('SY', 'XE', 'T', 'PE') then
				if it.cd is not null then
					totaluoc := totaluoc - it.cd; -- eliminate it from wam calculation
				end if;
				curr.mark := null; -- deal with 'bad' data, can be deleted?
			end if;
		end if;
		if it.mk is not null and it.cd is not null then
			weightmark := weightmark + it.mk * it.cd;
		end if;
		cnt := cnt + 1;
		return next curr;
	end loop;
	curr.code := null;
	curr.term := null;
	curr.prog := null;
	curr.grade := null;
	-- raise info '% %', weightmark, totaluoc;
	if cnt = 0 or totaluoc = 0 then -- avoid division by 0
		curr.name := 'No WAM available';
		curr.mark := null;
		curr.uoc := null;
	else
		curr.name := 'Overall WAM/UOC';
		
		curr.mark := round(1.0 * weightmark / totaluoc);
		curr.uoc := uocpass;
	end if;
	return next curr;
end;
$$ language plpgsql;

-- Q9
-- this is a tricky one, firstly we generate all the ids
-- of academic group that is a child of the gid group
-- if the current group has invalid gtype, negated value, 
-- pattern, definition, if should be excluded in this step
create or replace function Q9_gen_groups(gid integer) 
	returns setof integer
as $$
declare
	curr Record;
	cnt integer;
begin	
	for curr in (select g2.id as nxt 
		 		 from acad_object_groups as g1
					, acad_object_groups as g2
			where g2.parent = g1.id and g1.id = gid) loop
		return next Q9_gen_groups(curr.nxt);
	end loop;
	 
	select count(*) into cnt
	from acad_object_groups
	where id = gid and gtype <> 'rule' and gdefby <> 'query'
		and negated <> 'true';
	if cnt = 0 then 
		return;
	end if;
	return next gid; 
end;
$$ language plpgsql;

-- dynamic query
create or replace function Q9_getcode(gid integer, tp text)
returns setof text
as $$
declare 
	ret text;
begin
	for ret in execute 'select text(s.code) ' || 'from ' || tp || 's as s, ' || tp 
				|| '_group_members as sg where ' || gid || '= sg.ao_group and '|| 's.id = sg.' || tp loop
			return next ret;      
	end loop; 
end;
$$ language plpgsql;

-- return a match of the substring
create or replace function Q9_substr(ptr text)
returns setof text
as $$
declare
	arr text[];
	rep text;	
	len integer;
	i   integer;
	ret text;
	match text;
begin
	rep := replace(ptr, '#', '.'); -- replace # with .
	rep := replace(rep, '{', ','); -- replace all the other delimiters with ,
	rep := replace(rep, '}', ',');
	rep := replace(rep, ';', ',');
	arr := regexp_split_to_array(rep, ',');
	i := 1;
	len := array_length(arr, 1);
	while i <= len loop
		if arr[i] is not null then
			return next arr[i];
		end if;
		i := i + 1;
	end loop;
end;
$$ language plpgsql;


create or replace function Q9_support(txt text) returns setof text
as $$
declare ret record;
begin
	for ret in execute 'select * from ' || txt || 's' loop
		return next text(ret.code);
	end loop;
end;
$$ language plpgsql;

-- generate all items (probably with duplicate) given id
create or replace function Q9_gen_item(gid integer)
	returns setof AcObjRecord 
as $$
declare
	curr Record;
	cid  integer;
	ret  AcObjRecord;
	names text;
	subj text;
	rep  text; -- the regular expression of description
begin
	for cid in (select Q9_gen_groups(gid)) loop
		select * into curr 
		from acad_object_groups 
		where id = cid;
		ret.objtype := curr.gtype;
		if curr.gdefby = 'enumerated' then
			for names in select Q9_getcode(cid, curr.gtype) loop
				ret.objcode := names;
				return next ret;
			end loop;
		else
			
			for rep in (select Q9_substr(curr.definition)) loop 
				if rep is null then continue;
				end if;
				if rep similar to '[A-Z]{4}[0-9]{4}' and -- direct matches
					curr.gtype = 'subject' then
					ret.objcode := rep;
					return next ret;
				elsif rep similar to '[A-Z0-9]{6}' and -- stream
					curr.gtype = 'stream' then
					ret.objcode := rep;
					return next ret;
				elsif rep similar to '[A-Z0-9]{4}' and -- program
				      curr.gtype = 'program' then
					ret.objcode := rep;
					return next ret;
				else 
					if rep like '%GEN%' then continue;
					end if;
					if rep like '%FREE%' then continue; -- the three excluded
					end if;
					if rep like '%F=%' then continue;
					end if;
					for subj in (
						select * from Q9_support(curr.gtype)) loop
						if subj ~ text('^' || rep || '$') then
							ret.objcode := subj;
							return next ret;
						end if;
					end loop;
				end if;
			end loop;		
		end if;
	end loop;
end;
$$ language plpgsql; 

-- use group by to eliminate possible duplicate, solution Q9
create or replace function Q9(gid integer) 
returns setof AcObjRecord as $$
declare 
	curr AcObjRecord;
	cnt  integer;
begin
	select count(*) into cnt from acad_object_groups 
	where id = gid;
	if cnt = 0 then 
		raise exception 'No such group %' ,gid;
	end if;
	for curr in (select objtype, objcode from Q9_gen_item(gid)
				 group by objtype, objcode) loop
		return next curr;
	end loop;
end;
$$ language plpgsql; 

-- return the id of all acad_object_groups that is 
-- part of a 'RQ' rule and gtype = 'subject'
create or replace function Q10_gen_group()
returns setof integer as $$
declare
	ret integer;
begin
	for ret in (select id 
				from acad_object_groups 
				where gtype = 'subject' and id in (
					select ao_group 
					from rules  as r
					where r.type = 'RQ'
				)) loop
		return next ret;
	end loop; 
end;
$$ language plpgsql;

-- precondition gid exists and type = 'subject'
-- check if a course code is in an academic group
create or replace function Q10_is_related(cd text, gid integer) 
returns integer as $$
declare
	curr Record;
	cid  integer;
	names text;
	subj text;
	rep  text;
begin
	cid := gid;
	select * into curr 
	from acad_object_groups 
	where id = cid;
	if curr.gdefby = 'enumerated' then
		for names in select Q9_getcode(cid, curr.gtype) loop
			if names = cd then return 1;
			end if;
		end loop;
	elsif curr.gdefby = 'pattern' then
		for rep in (select Q9_substr(curr.definition)) loop 				
			if rep is null then continue;
			end if;
			if cd similar to rep then -- here we only consider direct match
				return 1;
			end if;
		end loop;		
	end if;
	return 0;
end;
$$ language plpgsql;

-- return all the relevant acad_group_id related to the code
create or replace function Q10_filter(code text) returns setof integer as $$
declare
	ret integer;
begin
	for ret in (select Q10_gen_group()) loop
		if 1 = (select Q10_is_related(code, ret)) then
			return next ret;
		end if;
	end loop;
end;
$$ language plpgsql;
-- finish Q10
create or replace function Q10(code text) returns setof text as $$
declare
	ret text;
begin
	for ret in (select distinct s.code 
				from subjects as s, rules as r, subject_prereqs as sp
				where s.id = sp.subject and r.id = sp.rule
					and r.ao_group in (select * from Q10_filter($1)) and 
					r.type = 'RQ') loop
		return next ret;
	end loop; 
end;
$$ language plpgsql;

