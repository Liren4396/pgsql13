-- COMP3311 20T3 Final Exam
-- Q5: find genres that groups worked in

-- ... helper views and/or functions go here ...

drop function if exists q5();
drop type if exists GroupGenres;

create type GroupGenres as ("group" text, genres text);

create or replace function
    q5() returns setof GroupGenres
as $$
declare
    r1 record;
    r2 record;
    res GroupGenres;
    genre text;
begin
    for r1 in select id,name from groups
    loop
        res."group" := r1.name;
        genre := '';
        for r2 in 
            select distinct(name), albums.genre from albums, groups 
            where albums.made_by = groups.id and groups.id = r1.id
            order by groups.name, albums.genre
        loop
            if genre = '' then
                genre := r2.genre;
            else
                genre := genre||','||r2.genre;
            end if;
        end loop;
        res.genres = genre;
        return next res;
    end loop;
end;
$$ language plpgsql
;