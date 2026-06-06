-- 1. Create the new database
CREATE DATABASE iron_book;

-- 2. Create the new user with a secure password
CREATE USER iron_book WITH PASSWORD 'your_secure_password_here';

-- 3. Revoke default public modifications on the database (Good security practice)
REVOKE ALL PRIVILEGES ON DATABASE iron_book FROM PUBLIC;

-- 4. Grant all privileges on this specific database to the new user
GRANT ALL PRIVILEGES ON DATABASE iron_book TO iron_book;

-- Connect to the newly created database
\c iron_book

-- Make the user the absolute owner of the schema
ALTER SCHEMA public OWNER TO iron_book;

-- Connect back to postgres user
\c postgres

-- Make the user the absolute owner of the database
ALTER DATABASE iron_book OWNER TO iron_book;
