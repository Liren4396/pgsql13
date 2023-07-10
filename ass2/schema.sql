-- COMP3311 22T3, Movie Database Schema
 
CREATE DOMAIN YearType AS INTEGER CHECK (VALUE > 1000);
CREATE DOMAIN MinutesType AS INTEGER CHECK (VALUE > 0);
CREATE DOMAIN CountType AS INTEGER CHECK (VALUE >= 0);
CREATE DOMAIN RatingType AS FLOAT CHECK (VALUE BETWEEN 0.0 AND 10.0);
CREATE DOMAIN CountryCodeType AS CHAR(2);
 
CREATE TABLE People (
	id      INTEGER,
	name    text NOT NULL,
	born    yeartype,
	died    yeartype,
	PRIMARY KEY (id)
);
 
CREATE TABLE Countries (
	code    CountryCodeType,
	name    text NOT NULL,
	PRIMARY KEY (code)
);
 
CREATE TABLE Movies (
	id      INTEGER,
	title   text NOT NULL,
    YEAR    YearType NOT NULL,
    runtime MinutesType,
	origin  CountryCodeType REFERENCES Countries(code),
	rating  RatingType,
	nvotes  CountType,
	PRIMARY KEY (id)
);
 
CREATE TABLE MovieGenres (
	movie   INTEGER REFERENCES movies(id),
	genre   text,
    PRIMARY KEY (movie,genre)
);
 
CREATE TABLE ReleasedIn (
	movie   INTEGER REFERENCES Movies(id),
	country CountryCodeType REFERENCES Countries(code),
	PRIMARY KEY (movie,country)
);
 
CREATE TABLE KnownFor (
	person  INTEGER REFERENCES People(id),
	movie   INTEGER REFERENCES Movies(id),
	PRIMARY KEY (person,movie)
);
 
CREATE TABLE Principals (
	id      INTEGER,
	movie   INTEGER NOT NULL REFERENCES Movies(id),
	person  INTEGER NOT NULL REFERENCES People(id),
	ord     INTEGER NOT NULL CHECK (ord > 0),
	job     text NOT NULL,
	PRIMARY KEY (id)
);
 
CREATE TABLE PlaysRole (
	inMovie INTEGER REFERENCES Principals(id),
    ROLE    text,
    PRIMARY KEY (inMovie,ROLE)
);