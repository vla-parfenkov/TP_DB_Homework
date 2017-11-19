ALTER TABLE thread DROP CONSTRAINT thread_forum_fkey RESTRICT;
ALTER TABLE thread ALTER COLUMN forum TYPE citext;
ALTER TABLE thread ADD CONSTRAINT thread_forum_fkey FOREIGN KEY (forum) REFERENCES forum(slug) MATCH FULL;
