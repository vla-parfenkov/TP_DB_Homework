package aplication.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;

import java.math.BigInteger;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.time.OffsetDateTime;
import java.util.List;

import aplication.model.Thread;

public class ThreadDAO {
    private final JdbcTemplate template;

    @Autowired
    public ThreadDAO(JdbcTemplate template) {
        this.template = template;
    }

    public Thread createThread (String slug,
                                String title,
                                String author,
                                Timestamp created,
                                String forum,
                                String message) {
        GeneratedKeyHolder keyHolder = new GeneratedKeyHolder();
        template.update(con -> {
            PreparedStatement pst = con.prepareStatement(
                    "insert into thread(slug, title, author, created, forum, message, votes)"
                            + " values(?,?,?,?,?,?,0)" + " returning id",
                    PreparedStatement.RETURN_GENERATED_KEYS);
            pst.setString(1, slug);
            pst.setString(2, title);
            pst.setString(3, author);
            pst.setTimestamp(4, created);
            pst.setString(5, forum);
            pst.setString(6, message);
            return pst;
        }, keyHolder);
        Thread thread = new Thread(author, created, forum, message, slug, title);
        thread.setId(BigInteger.valueOf(keyHolder.getKey().longValue()));
        return thread;
    }


    private static final RowMapper<Thread> THREAD_MAPPER = (res, num) -> {

        String author = res.getString("author");
        if (res.wasNull()) {
            author = null;
        }

        String forum = res.getString("forum");
        if (res.wasNull()) {
            forum = null;
        }

        Thread thread = new Thread(author,
                res.getTimestamp("created"),
                forum,
                res.getString("message"),
                res.getString("slug"),
                res.getString("title"));
        thread.setId(BigInteger.valueOf(res.getLong("id")));
        thread.setVotes(res.getInt("votes"));
        return thread;
    };


    public Thread getThreadById (BigInteger id){
        if(id == null) {
            return null;
        }
        List<Thread> result = template.query("select * from thread where id=?", ps -> ps.setLong(1, id.longValue()), THREAD_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result.get(0);


    }

    public Thread getThreadBySlug (String slug){
        List<Thread> result = template.query("select * from thread where lower(slug)=lower(?)", ps -> ps.setString(1, slug), THREAD_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result.get(0);

    }


    public Thread getThreadByTitle (String title){
        List<Thread> result = template.query("select * from thread where title=?", ps -> ps.setString(1, title), THREAD_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result.get(0);

    }


    public List<Thread> getThreadByForum (String forumSlug, BigInteger limit, Timestamp since, Boolean desc) {
        List<Thread> result = template.query("select thread.*" +
                    " from thread " +
                    "where lower(thread.forum)=lower(?) " + ((since != null && desc != null && desc == true) ? "AND thread.created <= ?" : "") +
                     ((since != null && (desc == null || desc == false)) ? "AND thread.created >= ?" : "") +
                    "ORDER BY thread.created " + ((desc != null && desc == true) ? "desc " : "asc ") +
                    "LIMIT ?", ps -> {
            ps.setString(1, forumSlug);
            if(since == null) {
                ps.setLong(2, limit.longValue());
            } else {
                ps.setTimestamp(2, since);
                ps.setLong(3, limit.longValue());
            }

        }, THREAD_MAPPER);
        return result;
    }


    public void updateThread(Thread threadData){
        template.update("UPDATE thread SET message = ?, title = ? WHERE id = ?",
                ps -> {
                    ps.setString(1, threadData.getMessage());
                    ps.setString(2, threadData.getTitle());
                    ps.setLong(3, threadData.getId().longValue());
        });
    }




}
