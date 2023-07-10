-- COMP3311 22T3 Final Exam Q2
-- List of races with only Mares

-- put helper views (if any) here

-- answer: Q2(name,course,date)

create or replace view count_races(name,course,date)
as
select distinct(races.name), racecourses.name, meetings.run_on, count(races.name) from horses,races,runners, meetings, racecourses 
where runners.horse = horses.id and runners.race = races.id and races.part_of = meetings.id 
and meetings.run_at = racecourses.id group by races.name, racecourses.name, meetings.run_on
order by races.name
;


create or replace view create_m_races(name,course,date,count)
as
select distinct(races.name), racecourses.name, meetings.run_on, count(races.name) from horses,races,runners, meetings, racecourses 
where horses.gender = 'M' and runners.horse = horses.id 
and runners.race = races.id and races.part_of = meetings.id 
and meetings.run_at = racecourses.id group by races.name, racecourses.name, meetings.run_on
order by races.name
;

create or replace view step_3(name,course,date, count)
as
select * from count_races
intersect
select * from create_m_races
;


create or replace view Q2(name,course,date)
as
select name, course, date from step_3
order by name;

