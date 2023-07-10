-- COMP3311 22T3 Assignment 1
--
-- Fill in the gaps ("...") below with your code
-- You can add any auxiliary views/function that you like
-- The code in this file *MUST* load into an empty database in one pass
-- It will be tested as follows:
-- createdb test; psql test -f ass1.dump; psql test -f ass1.sql
-- Make sure it can load without error under these conditions


-- Q1: new breweries in Sydney in 2020


create or replace view Q1(brewery,suburb)
as select breweries.name as brewery, locations.town as suburb from breweries 
	join locations on breweries.located_in = locations.id 
	where founded = 2020 and metro = 'Sydney'
;

-- Q2: beers whose name is same as their style

create or replace view Q2(beer,brewery)
as select beers.name, breweries.name as brewery from beers
	join styles on styles.name = beers.name
	join Brewed_by on Brewed_by.beer = beers.id
	join breweries on breweries.id = Brewed_by.brewery
	where beers.style = styles.id
;

-- Q3: original Californian craft brewery

create or replace view Q3(brewery,founded)
as select breweries.name as brewery, breweries.founded as founded from breweries 
where founded = (select min(founded) from breweries 
	join locations on locations.id = breweries.located_in 
	where locations.region = 'California')
;

-- Q4: all IPA variations, and how many times each occurs

create or replace view Q4(style,count)
as select styles.name, count(styles.id) from styles
	join beers on beers.style = styles.id
	where styles.name like '%IPA%'
	group by styles.name
	order by name
;

-- Q5: all Californian breweries, showing precise location

create or replace view Q5(brewery,location)
as
select breweries.name as brewery, 
	case when locations.town != '' then locations.town else locations.metro end as location 
	from breweries
		join locations on locations.id = breweries.located_in
		where locations.region = 'California' 
		order by brewery
;

-- Q6: strongest barrel-aged beer

create or replace view Q6(beer,brewery,abv)
as
select beers.name as beer, breweries.name as brewery, beers.abv
from beers
	join Brewed_by on brewed_by.beer = beers.id
	join Breweries on Breweries.id = brewed_by.brewery
	where beers.abv = (select max(beers.abv) from beers where beers.notes like '%barrel%' and beers.notes like '%aged%')
		order by beers.abv desc
;

-- Q7: most popular hop

create or replace view Q7(hop)
as
select name from ingredients
	join contains on contains.ingredient = ingredients.id
	where itype = 'hop'  
	group by name
	having count(name) = (select max(a1.num) from (select count(name) as num from ingredients 
		join contains on contains.ingredient = ingredients.id
		where itype = 'hop' group by name order by num desc) a1)
;

-- Q8: breweries that don't make IPA or Lager or Stout (any variation thereof)

create or replace view Q8(brewery)
as
select name from breweries
where breweries.name not in (
	select distinct(breweries.name) from breweries
		join Brewed_by on Brewed_by.brewery = breweries.id
		join Beers on beers.id = Brewed_by.beer
		join styles on styles.id = beers.style
		where styles.name like '%IPA%' or styles.name like '%Lager%' or styles.name like '%Stout%'
		order by breweries.name)
			order by name
;
-- Q9: most commonly used grain in Hazy IPAs

create or replace view Q9(grain)
as
select Ingredients.name from Ingredients
	join contains on contains.ingredient = ingredients.id
	join Beers on beers.id = contains.beer
	join styles on styles.id = beers.style
	where itype = 'grain' and styles.name = 'Hazy IPA'
	group by Ingredients.name
	having count(Ingredients.name) = (select max(a1.num) from (
		select count(Ingredients.name) as num from Ingredients 
			join contains on contains.ingredient = ingredients.id
			join Beers on beers.id = contains.beer
			join styles on styles.id = beers.style
			where itype = 'grain' and styles.name = 'Hazy IPA'
			group by Ingredients.name order by num desc) a1)
;

-- Q10: ingredients not used in any beer

create or replace view Q10(unused)
as
select name as unused from Ingredients
where Ingredients.id not in (select contains.ingredient from contains)
;

-- Q11: min/max abv for a given country

drop type if exists ABVrange cascade;
create type ABVrange as (minABV float, maxABV float);

create or replace function
	Q11(_country text) returns ABVrange
as $$
declare new ABVrange;
begin
	select min(beers.abv::numeric(4,1)), max(beers.abv::numeric(4,1)) into new from beers
		join brewed_by on brewed_by.beer = beers.id
		join breweries on breweries.id = brewed_by.brewery
		join locations on locations.id = breweries.located_in
	where locations.country = _country;
	if new is null then
		select 0,0 into new;
	end if;	
		return new;
end;
$$
language plpgsql;

-- Q12: details of beers


drop type if exists BeerData cascade;
create type BeerData as (beer text, brewer text, info text);




create or replace function
	Q12(partial_name text) returns setof BeerData
as $$
declare 
beer text := '';
    brewer text := '';
    info text := '';
    cur_itype text;
    cur_beers record;
    v_keybeer text;
    v_itype text;
BEGIN
    v_keybeer := '%' || partial_name || '%';
    for cur_beers in
        select B.name as beer_name,
    (select string_agg (Breweries.name, ' + ' order by Breweries.name) 
	from Breweries, Brewed_by 
    where Brewed_by.brewery = Breweries.id 
	and B.id = Brewed_by.beer group by B.id ) as brew_name,
    I.itype, I.name as ingre
        from Beers as B
        left outer join Contains C  on C.beer = B.id
        left outer join Ingredients I on I.id = C.ingredient
        where lower (B.name) like lower (v_keybeer)
		order by B.brewed asc,B.id desc,B.name desc, brew_name, I.itype, I.name ,B.style,B.Volume 
    
    loop
        if cur_beers.itype = 'grain' then 
            v_itype := 'Grain';
        elseif  cur_beers.itype = 'adjunct' then
            v_itype := 'Extras';
        elseif  cur_beers.itype = 'hop'  then  
            v_itype = 'Hops';
        end if;

        if beer = '' THEN
            beer := cur_beers.beer_name;
            brewer := cur_beers.brew_name;
            cur_itype := v_itype;
            info = cur_itype || ': ' || cur_beers.ingre;
        
        else
            if cur_itype != v_itype and cur_beers.beer_name = beer and cur_beers.brew_name = brewer  THEN
                cur_itype := v_itype;
                info := info || E'\n' || cur_itype || ':' || cur_beers.ingre;
            ELSEIF cur_itype = v_itype  and cur_beers.beer_name = beer and cur_beers.brew_name = brewer  THEN
                info := info || ',' || cur_beers.ingre;
            ELSE
                return next (beer, brewer, info);
                cur_itype := v_itype;
                beer := cur_beers.beer_name;
                brewer := cur_beers.brew_name;
                info := cur_itype || ':' || cur_beers.ingre;
            end if;
        end if;
    end loop;

    
    if beer != '' THEN
        return next (beer, brewer, info);
    end if;
end;
$$
language plpgsql;
