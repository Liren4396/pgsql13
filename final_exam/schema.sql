create table Horses (
	id          integer,
	name        text not null unique,
	gender      char(1) not null check (gender in ('S','G','M','F')),
	age         integer not null check (age between 2 and 8),
	primary key (id)
);

create table Jockeys (
	id          integer,
	name        text not null unique,
	gender      char(1),
	primary key (id)
);

create table RaceCourses (
	id          integer,
	name        text not null unique,
	city        text not null,
	primary key (id)
);

create table Meetings (
	id          integer,
	run_on      date not null,
	run_at      integer not null references RaceCourses(id),
	primary key (id)
);

create table Races (
	id          integer,
	name        text not null,
	ord         integer not null check (ord between 1 and 15),
	level       integer not null check (level between 1 and 4),
	prize       integer not null check (prize >= 1000),
	length      integer not null check (length >= 1000),
	part_of     integer not null references Meetings(id),
	primary key (id)
);

create table Runners (
	id          integer,
	horse       integer not null references Horses(id),
	race        integer not null references Races(id),
	jockey      integer not null references Jockeys(id),
	finished    integer check (finished > 0),
	primary key (id)
);
