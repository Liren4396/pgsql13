-- COMP3311 22T3 Final Exam Q1
-- Horse(s) that have won the most Group 1 races

-- put helper views (if any) here

-- answer: Q1(horse)
create or replace view race_1_max(horse, count) 
as
    select horses.name, count(horses.name) 
    from horses, races, runners 
    where runners.horse = horses.id and races.id = runners.race 
    and races.level = 1 and runners.finished = 1 
    group by horses.name order by count desc;
;
create or replace view Q1(horse) 
as
    select horse from race_1_max where count = (select max(count) from race_1_max);
;
