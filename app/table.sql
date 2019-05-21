CREATE TABLE account(
 user_id serial PRIMARY KEY,
 username VARCHAR (50) UNIQUE NOT NULL,
 password VARCHAR (50) NOT NULL,
 email VARCHAR (355) UNIQUE NOT NULL,
 created_on TIMESTAMP NOT NULL,
 last_login TIMESTAMP
); 

ALTER TABLE account OWNER TO docker;

INSERT INTO account
VALUES (1, 'Marco', 'pass', 'mail','12-03-2014','21-05-2019');

INSERT INTO account
VALUES (2, 'Alessia', 'pass', 'mail','12-03-2014','21-05-2019');