-- COMP3311 20T3 Assignment 1
-- Calendar schema
-- Written by Yifan He, z5173587

-- Types

create type AccessibilityType as enum ('read-write','read-only','none');
create type InviteStatus as enum ('invited','accepted','declined');
create type VisibilityType as enum('public', 'private');
create type WeekDayType as enum('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun');
-- add more types/domains if you want

-- Tables

create table Users (
	id          		  serial,
	name	    		  text not null,
	email       		  text not null unique, -- no two users have the same email
	passwd      		  text not null,		  
	is_admin    		  boolean not null default false, -- since very few users are admin, default is false
	primary key (id)
);

create table Groups (
	id          		  serial,
	name        		  text not null,
	owner	    		  integer not null, -- total participation
	primary key (id),
	foreign key (owner) references Users(id)
);

-- map the n:m relationship Member
create table Member (
	user_id    			  integer,
	group_id   			  integer,
	primary key (user_id, group_id)	,
	foreign key (user_id) references Users(id),
	foreign key (group_id) references Groups(id)
);

create table Calendars (
	id	                  serial,
	name	              text not null,
	colour	              text not null,
	default_access        AccessibilityType not null default 'none',
	owner	              integer not null, --total participation
	foreign key (owner) references Users(id),
	primary key (id)
);

-- map the n:m relationship subscribed
create table Subscribed (
	color        		  text, -- the spec says "may set a color", means this can be null
	user_id      		  integer,
	calendar_id  		  integer,
	primary key (user_id, calendar_id),	
	foreign key (user_id) references Users(id),
	foreign key (calendar_id) references Calendars(id)
);

-- map the n:m relationship accessibility
create table Accessibility (
	access       	      AccessibilityType not null default 'none',
	user_id      		  integer,
	calendar_id  		  integer,
	primary key (user_id, calendar_id),
	foreign key (user_id) references Users(id),
	foreign key (calendar_id) references Calendars(id)	
);

-- note that both the total participation and the disjoint 
-- cannot be mapped successfully if we use the ER mapping
create table Events (
	id          		  serial,
	start_time  		  time,   
	end_time    		  time, 
	location    		  text, -- the spec used "may", hence can be null
	visibility  		  VisibilityType not null default 'private',
	title       		  text not null,
	part_of     		  integer not null, -- total participation
	created_by  		  integer not null, -- total participation
	foreign key (created_by) references Users(id),
	foreign key (part_of) references Calendars(id),
	primary key (id)
);

-- map the n:m relationship between Events and User (invited)
create table Invited (
	event_id   			  integer,
	user_id    			  integer,
	status     			  InviteStatus not null default 'invited', -- quite reasonable to set invited as default 
	primary key (event_id, user_id),
	foreign key (event_id) references Events(id),
	foreign key (user_id) references Users(id)
);

-- map the multi-value attributes alarms
create table Alarms (
	event_id  			  integer,
    alarm     			  interval,
	primary key (event_id, alarm),
	foreign key (event_id) references Events(id)
);

create table One_Day_Events (
	event_id      	      integer,	
	date          		  date not null,
	primary key (event_id),
	foreign key (event_id) references Events(id)
);

create table Spanning_Events (
	event_id              integer,	
	start_date            date not null,
	end_date              date not null check(end_date >= start_date),
	primary key (event_id),
	foreign key (event_id) references Events(id)
);

create table Recurring_Events (
	event_id              integer,	
	start_date            date not null,
	end_date              date check(end_date >= start_date), -- can be null means still running
	ntimes                integer check (ntimes >= 1), -- can be null
	primary key (event_id),
	foreign key (event_id) references Events(id)
);

create table Weekly_Events (
	recurring_event_id    integer,
	day_of_week           WeekDayType not null,
	frequency             integer not null check (frequency >= 1),
	primary key (recurring_event_id),
	foreign key (recurring_event_id) references Recurring_Events(event_id)
);

create table Monthly_By_Day_Events (
	recurring_event_id    integer,
	day_of_week           WeekDayType not null,
	week_in_month         integer not null check (week_in_month >= 1 AND week_in_month <= 5),
	primary key (recurring_event_id),
	foreign key (recurring_event_id) references Recurring_Events(event_id)
);

create table Monthly_By_Date_Events (
	recurring_event_id    integer,
	date_in_month         integer not null check (date_in_month >= 1 AND date_in_month <= 31),
	primary key (recurring_event_id),
	foreign key (recurring_event_id) references Recurring_Events(event_id)
);

create table Annual_Events (
	recurring_event_id    integer,
	date                  date not null,
	primary key (recurring_event_id),
	foreign key (recurring_event_id) references Recurring_Events(event_id)	
);

