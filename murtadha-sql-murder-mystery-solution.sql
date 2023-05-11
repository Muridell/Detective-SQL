--QUERY crime_scene_report and check for Murder case
select * from crime_scene_report
where date = 20180115 and city = 'SQL City';

/* DESCRIPTION:
Security footage shows that there were 2 witnesses. 
The first witness lives at the last house on "Northwestern Dr". 
The second witness, named Annabel, lives somewhere on "Franklin Ave".
*/

--Find the first witness who lives at the last house on Northwestern Dr.
select * from person 
where address_street_name = 'Northwestern Dr' 
order by address_number DESC;

/*I get a list of people and I have a lead. How about I query the interview table 
and compare see those who live on Northwestern Dr and have a transcript*/
SELECT p.id, name, address_number, address_street_name, transcript
from person p
join interview i 
ON I.person_id = P.id
order by address_number DESC;

/*After comparing the transcripts of the individuals on Northwestern Dr.,
Person ID: 14887, with the name: Morty Schapiro looks like the first suspect.*/

--Find the second witness, named Annabel, lives somewhere on "Franklin Ave".
select * from person 
where name LIKE '%Annabel%' AND address_street_name = 'Franklin Ave' 
order by address_number DESC;
--Annabel has ID: 16371

--View the two suspects' interview transcripts
select p.name, i.* 
from interview i
join person p 
ON I.person_id = P.id
WHERE person_id IN (16371,14887);

/* Using Morty and Annabel's transcripts:
Morty: I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. 
The membership number on the bag started with "48Z". Only gold members have those bags. 
The man got into a car with a plate that included "H42W".

Annabel: I saw the murder happen, and I recognized the killer from my gym when 
I was working out last week on January the 9th.
*/

--Using Morty's transcript:
--Query Get Fit Now data
select * from get_fit_now_member 
where id LIKE '48Z%' and membership_status = 'gold';
/*Two names pop up: Joe Germuska and Jeremy Bowers*/

--Using Annabel's transcript:
select * from get_fit_now_check_in
WHERE check_in_date = '20180109' and membership_id in ('48Z7A', '48Z55');
/*This shows that the suspect checked-in the gym on January 9th, 2018 as mentioned by Annabel*/

--Query Drivers License record
SELECT p.name, p.license_id, dl.* 
FROM drivers_license dl
JOIN person p
ON dl.id = p.license_id
WHERE dl.plate_number like '%H42W%';
/*Three names pop up: Tushar Chandra, Jeremy Bowers and Maxine Whitely*/

--Let's get the common suspect from the descriptions given 
WITH GOLD_MEM AS (
select id, person_id, name, membership_start_date, membership_status
from get_fit_now_member 
where id LIKE '48Z%' and membership_status = 'gold')
, PLATE_NUM AS (
SELECT p.name, p.license_id, dl.* 
FROM drivers_license dl
JOIN person p
ON dl.id = p.license_id
WHERE dl.plate_number like '%H42W%'
)

SELECT gm.name from GOLD_MEM gm
inner join PLATE_NUM pn
on gm.name = pn.name;

--Jeremy Bowers is the criminal
INSERT INTO solution VALUES (1, 'Jeremy Bowers');
SELECT value FROM solution;

--LET'S FIND THE REAL VILLIAN BEHIND THE MURDER
--Jeremy's Person ID is 67318, let's check his interview

SELECT * FROM interview
WHERE person_id = 67318

/* He said: "I was hired by a woman with a lot of money. I don't know her name 
but I know she's around 5'5" (65") or 5'7" (67"). 
She has red hair and she drives a Tesla Model S. 
I know that she attended the SQL Symphony Concert 3 times in December 2017."
*/

--Let's check who she is using his description
select * 
from drivers_license dl
join person p 
on dl.id = p.license_id
INNER JOIN (
select person_id, count(event_id) Attended_event
  from facebook_event_checkin 
  join person on facebook_event_checkin.person_id = person.id 
  where event_name = 'SQL Symphony Concert' and date like '201712%'
  group by 1 
  having count(person_id) = 3) e
ON p.id = e.person_id
where car_make = 'Tesla' and car_model = 'Model S' 
and gender = 'female' and hair_color = 'red' AND height between 65 and 67;

/*GOT IT!!! Miranda Priestly is the REAL VILLIAN*/

INSERT INTO solution VALUES (1, 'Miranda Priestly');
SELECT value FROM solution;
