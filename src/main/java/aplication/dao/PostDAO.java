package aplication.dao;

import aplication.model.Post;
import aplication.model.Thread;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

@Service
@Transactional
public class PostDAO {
    private final JdbcTemplate template;

    @Autowired
    public PostDAO(JdbcTemplate template) {
        this.template = template;
    }

    private static final RowMapper<Post> POST_MAPPER = (res, num) -> {

        String author = res.getString("author");
        if (res.wasNull()) {
            author = null;
        }

        BigDecimal thread = res.getBigDecimal("thread");
        if (res.wasNull()) {
            thread = null;
        }

        BigDecimal parent = res.getBigDecimal("parent");
        if (res.wasNull()){
            parent = null;
        }

        String forum = res.getString("forum");
        if (res.wasNull()) {
            forum = null;
        }

        Post post = new Post(res.getBigDecimal("id"),
                author,
                res.getTimestamp("created"),
                forum,
                res.getString("message"),
                parent,
                thread);
        return post;
    };



    public List<Post> createPost (List<Post> posts, BigDecimal threadId ) {
        if(posts.isEmpty()) {
            return posts;
        }

        BigDecimal nextval = template.queryForObject("select nextval('post_id_seq'::regclass)", BigDecimal.class);
        String sql = "insert into post(created, message, isedited, author, thread, parent, forum, path) values(?,?,?,?,?,?,?, (SELECT path FROM post WHERE id = ? AND thread = ?) || (select currval('post_id_seq'::regclass)))";
        template.batchUpdate(sql, new BatchPreparedStatementSetter() {

                @Override
                public void setValues(PreparedStatement ps, int i) throws SQLException {
                    ps.setTimestamp(1, posts.get(i).getCreated());
                    ps.setString(2, posts.get(i).getMessage());
                    ps.setBoolean(3, posts.get(i).getEdited());
                    ps.setString(4, posts.get(i).getAuthor());
                    ps.setBigDecimal(5, posts.get(i).getThread() );
                    ps.setBigDecimal(6,  posts.get(i).getParent());
                    ps.setString(7, posts.get(i).getForum());
                    ps.setBigDecimal(8, posts.get(i).getParent());
                    ps.setBigDecimal(9, threadId);
                }

                @Override
                public int getBatchSize() {
                    return posts.size();
                }
            });

            Long incId = nextval.longValue();
            for (Post post: posts) {
                post.setId(new BigDecimal(incId));
                incId += 1;
            }

        return posts;
    }

}
