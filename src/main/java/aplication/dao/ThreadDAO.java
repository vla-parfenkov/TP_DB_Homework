package aplication.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;

import java.math.BigDecimal;
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
                    "insert into thread(slug, title, author, created, forum, message)" + " values(?,?,?,?,?,?)" + " returning id",
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
        thread.setId(keyHolder.getKey().longValue());
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
        thread.setId(res.getLong("id"));
        thread.setVotes(res.getInt("votes"));
        return thread;
    };


    public Thread getThreadById (long id){
        List<Thread> result = template.query("select * from thread where id=?", ps -> ps.setLong(1, id), THREAD_MAPPER);
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


    public List<Thread> getThreadByForum (String forumSlug, BigDecimal limit, Timestamp since, Boolean desc) {
        List<Thread> result = template.query("select thread.*" +
                    " from thread join forum on (thread.forum = forum.slug) " +
                    "where lower(forum.slug)=lower(?) " + ((since != null && desc != null && desc == true) ? "AND thread.created <= ?" : "") +
                     ((since != null && (desc == null || desc == false)) ? "AND thread.created >= ?" : "") +
                    "ORDER BY thread.created " + ((desc != null && desc == true) ? "desc " : "asc ") +
                    "LIMIT ?", ps -> {
            ps.setString(1, forumSlug);
            if(since == null) {
                ps.setBigDecimal(2, limit);
            } else {
                ps.setTimestamp(2, since);
                ps.setBigDecimal(3, limit);
            }

        }, THREAD_MAPPER);
        return result;
    }



}
