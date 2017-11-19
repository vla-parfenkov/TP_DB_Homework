CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;
ALTER TABLE forum ALTER COLUMN user_moderator TYPE citext;
ALTER TABLE post ALTER COLUMN author TYPE citext;
ALTER TABLE thread ALTER COLUMN author TYPE citext;
ALTER TABLE user_account ALTER COLUMN nickname TYPE citext;

ALTER TABLE user_account ALTER COLUMN email TYPE citext;
ALTER TABLE forum ALTER COLUMN slug TYPE citext;

