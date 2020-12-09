-- COMP3311 20T3 Ass3 ... extra database definitions
-- add any views or functions you need to this file
-- extract all movies that match the regular expression rep
create or replace function Q2_1(rep text) returns setof Movies as
$$
declare
    curr record;
    -- sub  text;
begin
    -- sub := '%' || rep || '%';
    for curr in (select * from Movies where title ~* rep order by start_year, title) loop
        return next curr;
    end loop; 
end;
$$ language plpgsql;

create or replace function Q2_2(id integer) returns setof Aliases as
$$
declare
    curr record;
begin
    for curr in (select * from Aliases where movie_id = $1 order by ordering) loop
        return next curr;
    end loop; 
end;
$$ language plpgsql;

create or replace function Q3_1(rep text, yr integer) returns setof Movies as
$$
declare
    curr record;
begin
    for curr in (select * from Movies where title ~* rep and start_year = yr 
                 order by start_year, title) loop
        return next curr;
    end loop; 
end;
$$ language plpgsql;

create or replace function Q4_1(rep text) returns setof Names as
$$
declare
    curr record;
begin
    for curr in (select * from Names where name ~*rep order by name, birth_year, id) loop
        return next curr;
    end loop;
end;
$$ language plpgsql;

create or replace function Q4_2(rep text, yr integer) returns setof Names as
$$
declare
    curr record;
begin
    for curr in (select * from Names where name ~*rep and birth_year = yr order by name, birth_year, id) loop
        return next curr;
    end loop;
end;
$$ language plpgsql;

