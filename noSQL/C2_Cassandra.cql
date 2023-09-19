/*
Student Name: An JU
Assignment 1 C2
*/

/*
C2.1
 */
DESCRIBE KEYSPACES;
CREATE KEYSPACE monugov_keyspace WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
DESCRIBE KEYSPACES;

/*
C2.2
 */
USE monugov_keyspace;

/*
    create table
 */

CREATE TABLE landmarks (
 landmark_id VARCHAR,
 category TEXT,
 theme TEXT,
 landmarkName TEXT,
 lat DECIMAL,
 lon DECIMAL,
 houseNo TEXT,
 street TEXT,
 suburb TEXT,
 postcode INT,
 PRIMARY KEY(landmark_id,landmarkName)
);
CREATE TABLE suburbs (
 suburb_id VARCHAR,
 councilArea TEXT,
 suburb TEXT,
 regionName TEXT,
 postcode INT,
 propertyCount INT,
 PRIMARY KEY(suburb_id, suburb, postcode)
);

/*
 define a type for propertyHistory in properties
 */
CREATE TYPE history (
 sold_by TEXT,
 date TIMESTAMP,
 price INT);

/*
 create table with frozen datatype
 */

CREATE TABLE properties (
 property_id VARCHAR,
 address TEXT,
 postcode INT,
 propertyHistory set<frozen<history>>,
 rooms INT,
 suburb TEXT,
 type TEXT,
 PRIMARY KEY(property_id)
);

/*
 import the csv file
 */

COPY landmarks (landmark_id, category, theme, landmarkName, lat, lon, houseNo, street, suburb, postcode) FROM 'C:\Users\user\Desktop\landmarks.csv' WITH HEADER = TRUE;
COPY suburbs (suburb_id, councilArea, suburb, regionName, postcode, propertyCount) FROM 'C:\Users\user\Desktop\suburbs.csv' WITH HEADER = TRUE;
COPY properties (property_id, address, postcode, propertyHistory, rooms, suburb, type) FROM 'C:\Users\user\Desktop\properties.csv' WITH DELIMITER = '|' AND HEADER = TRUE;


/*
 C2.3
 */

/*
 insert into different tables
 */

insert into properties (property_id, address, postcode, propertyHistory, rooms, suburb, type)
VALUES ('insert1', '19 Kinlock St', 3085, {{sold_by: 'Darren', date: '1970-01-01T00:00:00Z', price: 1120000}}, 5, 'Macleod', 'house');
insert into landmarks (landmark_id, landmarkName, category, theme, lat, lon, houseNo, street)
VALUES ('insert2','Gresswell Theatre','Place Of Assembly', 'Theatre Live', -37.712422, 145.072617, '1', 'Forrest Road');

/*
 output after insert
 */

SELECT *
FROM properties
WHERE property_id = 'insert1';

SELECT *
FROM landmarks
WHERE landmark_id = 'insert2';

/*
 Alternate solution
 */
CREATE INDEX ON properties ( address );
SELECT *
FROM properties
WHERE address = '19 Kinlock St';
CREATE INDEX ON landmarks ( landmarkName );
SELECT *
FROM landmarks
WHERE landmarkName = 'Gresswell Theatre';


/*
 C2.4 i
 */
CREATE INDEX ON suburbs ( suburb );
SELECT * FROM suburbs WHERE suburb = 'Caulfield';

/*
 alternate solution
 */
SELECT * FROM suburbs WHERE suburb = 'Caulfield' ALLOW FILTERING;

/*
 C2.4 ii
 add new columns
 */

ALTER TABLE suburbs ADD otherHomeGround BOOLEAN;
ALTER TABLE suburbs ADD team INT;

/*
 update columns
 */

UPDATE suburbs
SET otherHomeGround = true, team = 16
where suburb = 'Caulfield';

/*
 display related field
 */
SELECT *
FROM suburbs
WHERE suburb = 'Caulfield';

/*
 C2.4 iii
 add TTL
 */

UPDATE suburbs USING TTL 300000
SET otherHomeGround = true, team = 16
WHERE suburb = 'Caulfield' AND suburb_id = 'S272';

SELECT otherHomeGround, TTL(otherHomeGround), writetime(otherHomeGround), team, TTL(team), writetime(team)
FROM suburbs
WHERE suburb = 'Caulfield'
  AND suburb_id = 'S272';

/*
 C2.5
 */

CREATE INDEX ON properties ( type );

/*
 C2.6 i
 */

SELECT COUNT(*) FROM properties WHERE type = 'u';

/*
 C2.6 ii
 */
SELECT * FROM landmarks WHERE postcode > 3200 ALLOW FILTERING;