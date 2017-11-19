package aplication.dao;


import aplication.model.Forum;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;



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
        return new Forum(keyHolder.getKey().longValue(),0,0, slug, title, user);
    }

    private static final RowMapper<Forum> FORUM_MAPPER = (res, num) -> {

        String user = res.getString("user_moderator");
        if (res.wasNull()) {
            user = null;
        }

        return new Forum(res.getLong("id"),
                res.getLong("posts"),
                res.getLong("threads"),
                res.getString("slug"),
                res.getString("title"),
                user);
    };


    public Forum getForumbyId (long id){
        List<Forum> result = template.query("select * from forum where id=?", ps -> ps.setLong(1, id), FORUM_MAPPER);
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



}
