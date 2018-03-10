CREATE USER trunk_player_user WITH PASSWORD '__DB_PASS__';
CREATE DATABASE trunk_player;
GRANT ALL PRIVILEGES ON DATABASE trunk_player TO trunk_player_user;
ALTER ROLE trunk_player_user SET client_encoding TO 'utf8';
ALTER ROLE trunk_player_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE trunk_player_user SET timezone TO 'UTC';
