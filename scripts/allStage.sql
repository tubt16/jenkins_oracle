create table test (
	name varchar(10),
	age int,
	locate varchar(10),
	gender varchar(10),
	color varchar(10)
);
insert into test (name, age, locate, gender, color) values ('tubt', 24, 'Dong Anh', 'male', 'red');
insert into test (name, age, locate, gender, color) values ('tu1', 23, 'Ha Noi', 'male', 'blue');
insert into test (name, age, locate, gender, color) values ('tu2', 25, 'HN', 'male', 'green');
select * from test;