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

        Long thread = res.getLong("thread");
        if (res.wasNull()) {
            thread = null;
        }

        Long parent = res.getLong("parent");
        if (res.wasNull()){
            parent = null;
        }

        String forum = res.getString("forum");
        if (res.wasNull()) {
            forum = null;
        }

        Post post = new Post(res.getLong("id"),
                author,
                res.getTimestamp("created"),
                forum,
                res.getString("message"),
                parent,
                thread);
        return post;
    };



    public List<Post> createPost (List<Post> posts) {
        if(posts.isEmpty()) {
            return posts;
        }
        List<Long> nextval = template.query("select nextval('post_id_seq'::regclass)", ResultSet::getLong);
        String sql = "insert into post(created, message, isedited, author, thread, parent, forum) values(?,?,?,?,?,?, ?)";
        template.batchUpdate(sql, new BatchPreparedStatementSetter() {

                @Override
                public void setValues(PreparedStatement ps, int i) throws SQLException {
                    ps.setTimestamp(1, posts.get(i).getCreated());
                    ps.setString(2, posts.get(i).getMessage());
                    ps.setBoolean(3, posts.get(i).getEdited());
                    ps.setString(4, posts.get(i).getAuthor());
                    ps.setLong(5, posts.get(i).getThread() );
                    ps.setLong(6,  posts.get(i).getParent());
                    ps.setString(7, posts.get(i).getForum());
                }

                @Override
                public int getBatchSize() {
                    return posts.size();
                }
            });

            Long incId = nextval.get(0);
            for (Post post: posts) {
                post.setId(incId);
                incId += 1;
            }

        return posts;
    }

}
