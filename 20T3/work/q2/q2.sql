-- COMP3311 20T3 Final Exam
-- Q2: group(s) with no albums

-- ... helper views (if any) go here ...

create or replace view q2("group")
as
select name from groups left join albums on albums.made_by = groups.id where albums.title is null;
;

