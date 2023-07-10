create table Groups (
	id          integer,
	name        text not null,
	formed      date not null, -- when the group formed
	disbanded   date, -- when they split up (null if still together)
	primary key (id)
);

create table Albums (
	id          integer,
	title       text not null,
	year        integer not null check (year >= 1980),
	made_by     integer not null, -- which group made this album
	genre       text not null,
	primary key (id),
	foreign key (made_by) references Groups(id)
);

create table Performers (
	id          integer,
	name        text not null,
	birthday    date,
	primary key (id)
);

create table Songs (
	id          integer,
	title       text not null,
	length      integer not null check (length > 0), -- seconds
	on_album    integer not null, -- which album this song appears on
	trackNo     integer not null check (trackNo > 0), -- position
	primary key (id),
	foreign key (on_album) references Albums(id)
);

create table PlaysOn (
	performer   integer,
	song        integer,
	instrument  text,
	primary key (performer,song,instrument),
	foreign key (performer) references Performers(id),
	foreign key (song) references Songs(id)
);

create table MemberOf (
	in_group    integer,
	performer   integer,
	primary key (in_group,performer),
	foreign key (in_group) references Groups(id),
	foreign key (performer) references Performers(id)
);