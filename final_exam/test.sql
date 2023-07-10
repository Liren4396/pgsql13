
create or replace view test1(name, count)
as
select races.name,count(races.name) from horses,runners,races
where runners.horse = horses.id and runners.race = races.id
group by races.name
;
create or replace view max_count1(name, count)
as
select * from test1 where count = (select min(count) from test1)
;


create or replace view test2(name, count)
as
select jockeys.name,count(jockeys.name)from runners,races,jockeys 
where runners.race = races.id and runners.jockey = jockeys.id
group by jockeys.name
order by name
;

create or replace view max_count2(name, count)
as
select * from test2 where count = (select max(count) from test2)
;

create or replace view test3(name, count)
as
select horses.name,count(horses.name)from runners,horses,jockeys 
where  runners.jockey = jockeys.id and runners.horse = horses.id
group by horses.name
order by name
;

create or replace view max_count3(name, count)
as
select * from test3 where count = (select max(count) from test3)
;


drop type if exists newtype cascade;
create type newtype as (jockey text, gender char(1));
create or replace function test4(curr date) returns text
as
$$
declare
    r1 record;
    r2 record;
	new newtype;
begin
    for r1 in select * from Meetings where Meetings.run_on = curr
    loop
        
        for r2 in 
            select jockeys.name, jockeys.gender from horses,jockeys,races,runners 
            where races.part_of = r1.id and runners.horse = horses.id and runners.jockey = jockeys.id and runners.race = races.id
        loop
            new.jockey := r2.name;
            new.gender := r2.gender;
            
        end loop;
            return next new;
    end loop;
    return new;
end;
$$ language plpgsql;










#!/usr/bin/python3

# COMP3311 22T3 Assignment 2
# Print info about one movie; may need to choose

import sys
import psycopg2
import helpers
import re

### Globals

db = psycopg2.connect("dbname=ass2")
usage = f"Usage: {sys.argv[0]} 'PartialMovieName'"

### Command-line args

if len(sys.argv) < 2:
   print(usage)
   exit(1)
# process the command-line args ...

### Queries
query = f'''
'''
### Manipulating database

try:
   # your code goes here
   cur = db.cursor()
   cur.execute(query)
    for t in cur.fetchall():

   


except Exception as err:
   print("DB error: ", err)
finally:
   if db:
      db.close()

