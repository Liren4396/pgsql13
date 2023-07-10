-- COMP3311 22T3 Final Exam Q3
-- List Gender/Age for all horses for all races of a specified type

drop type if exists race_horses cascade;
create type race_horses as (race text, horses text);

-- put helper views (if any) here

-- answer: Q3(text) -> setof race_horses

create or replace function Q3(text) returns setof race_horses
as
$$


begin

	select races.name, horses.gender, horses.age from races, horses,runners where runners.horse = horses.id 
	and runners.race = raaces.id and races.name like %text% into ra
	
		

    return '';
end;
$$
language sql;
