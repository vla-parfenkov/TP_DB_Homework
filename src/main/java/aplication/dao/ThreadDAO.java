package aplication.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;

import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.util.List;

import aplication.model.Thread;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
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
                            + " values(?,?,?,?,?,?,0)" + " returning id ",
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
        thread.setId(keyHolder.getKey().intValue());
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
        thread.setId(res.getInt("id"));
        thread.setVotes(res.getInt("votes"));
        return thread;
    };


    public Thread getThreadById (Integer id){
        if(id == null) {
            return null;
        }
        List<Thread> result = template.query("select * from thread where id=?", ps -> ps.setInt(1, id), THREAD_MAPPER);
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


    public List<Thread> getThreadByForum (String forumSlug, Integer limit, Timestamp since, Boolean desc) {
        List<Thread> result = template.query("select thread.*" +
                    " from thread " +
                    "where lower(thread.forum)=lower(?) " + ((since != null && desc != null && desc == true) ? "AND thread.created <= ?" : "") +
                     ((since != null && (desc == null || desc == false)) ? "AND thread.created >= ?" : "") +
                    "ORDER BY thread.created " + ((desc != null && desc == true) ? "desc " : "asc ") +
                    "LIMIT ?", ps -> {
            ps.setString(1, forumSlug);
            if(since == null) {
                ps.setInt(2, limit);
            } else {
                ps.setTimestamp(2, since);
                ps.setLong(3, limit);
            }

        }, THREAD_MAPPER);
        return result;
    }


    public void updateThread(Thread threadData){
        template.update("UPDATE thread SET message = ?, title = ? WHERE id = ?",
                ps -> {
                    ps.setString(1, threadData.getMessage());
                    ps.setString(2, threadData.getTitle());
                    ps.setInt(3, threadData.getId());
        });
    }

    public Thread setVotes(Integer id, Integer voice) {
        List<Thread> result = template.query("UPDATE thread SET votes = votes + ? WHERE id = ? " +
                        "RETURNING *",
                ps -> {
                    ps.setInt(1, voice);
                    ps.setInt(2, id);
                }, THREAD_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result.get(0);

    }

    public Thread getThreadBySlugOrID (String slugOrId) {
        Integer threadId = null;
        try {
            threadId = Integer.valueOf(slugOrId);
        } catch (NumberFormatException ex){
            threadId = null;
        }
        final Integer id = threadId;
        List<Thread> result = template.query("SELECT * FROM thread WHERE " +
                        ((id == null) ? "lower(slug) = lower(?) " : " id = ? "),
                ps -> {
                    if (id == null) {
                        ps.setString(1, slugOrId);
                    } else {
                        ps.setInt(1, id);
                    }
                }, THREAD_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result.get(0);

    }

}
