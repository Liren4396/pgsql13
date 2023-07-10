-- COMP3311 20T3 Final Exam
-- Q1: longest album(s)

-- ... helper views (if any) go here ...

create or replace view AlbumLengths("group",title,year,length)
as
select g.name,a.title,a.year,sum(s.length)
from   Groups g join Albums a on g.id = a.made_by
    join Songs s on s.on_album = a.id
group  by g.name,a.title,a.year
;

create or replace view Q1("group",album,year)
as
select "group",title,year
from   AlbumLengths
where  length = (select max(length) from AlbumLengths)
;

