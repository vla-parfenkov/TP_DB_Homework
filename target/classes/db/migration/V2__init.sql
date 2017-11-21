ALTER TABLE post ADD COLUMN forum citext;
ALTER TABLE post
  ADD CONSTRAINT post_forum_fkey FOREIGN KEY (forum) REFERENCES forum(slug);