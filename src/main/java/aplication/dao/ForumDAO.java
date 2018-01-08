package aplication.dao;


import aplication.model.Forum;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;


import java.math.BigInteger;
import java.sql.PreparedStatement;
import java.util.List;

@Service
@Transactional
public class ForumDAO {
    private final JdbcTemplate template;

    @Autowired
    public ForumDAO(JdbcTemplate template) {
        this.template = template;
    }

    public Forum createForum (String slug, String title, String user) {
        GeneratedKeyHolder keyHolder = new GeneratedKeyHolder();
        template.update(con -> {
            PreparedStatement pst = con.prepareStatement(
                    "insert into forum(slug, title, user_moderator)" + " values(?,?,?)" + " returning id",
                    PreparedStatement.RETURN_GENERATED_KEYS);
            pst.setString(1, slug);
            pst.setString(2, title);
            pst.setString(3, user);
            return pst;
        }, keyHolder);
        return new Forum(BigInteger.valueOf(keyHolder.getKey().longValue()),BigInteger.valueOf(0), BigInteger.valueOf(0), slug, title, user);
    }

    private static final RowMapper<Forum> FORUM_MAPPER = (res, num) -> {

        String user = res.getString("user_moderator");
        if (res.wasNull()) {
            user = null;
        }

        return new Forum(BigInteger.valueOf(res.getLong("id")),
                BigInteger.valueOf(res.getLong("posts")),
                BigInteger.valueOf(res.getLong("threads")),
                res.getString("slug"),
                res.getString("title"),
                user);
    };


    public Forum getForumbyId (BigInteger id){
        List<Forum> result = template.query("select * from forum where id=?", ps -> ps.setLong(1, id.longValue()), FORUM_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result.get(0);
    }

    public Forum getForumBySlug (String slug){
        List<Forum> result = template.query("select * from forum where lower(slug)=lower(?)", ps -> ps.setString(1, slug), FORUM_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result.get(0);

    }

    public void setPosts(String slug, Integer postsCount) {
        template.update("UPDATE forum SET posts = posts + ? WHERE lower(slug) = lower(?)",
                ps -> {
                    ps.setInt(1, postsCount);
                    ps.setString(2, slug);
                });

    }



}
