package aplication.dao;

import aplication.model.*;
import aplication.model.Thread;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import java.math.BigInteger;
import java.sql.*;
import java.util.List;

@Service
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

        BigInteger thread = BigInteger.valueOf(res.getLong("thread"));
        if (res.wasNull()) {
            thread = null;
        }

        BigInteger parent = BigInteger.valueOf(res.getLong("parent"));
        if (res.wasNull()){
            parent = null;
        }

        String forum = res.getString("forum");
        if (res.wasNull()) {
            forum = null;
        }

        Post post = new Post(BigInteger.valueOf(res.getLong("id")),
                author,
                res.getTimestamp("created"),
                forum,
                res.getString("message"),
                parent,
                thread);
        post.setIsEdited(res.getBoolean("isedited"));
        return post;
    };

    private static final RowMapper<PostFullInfo> POST_FULL_INFO_MAPPER = (res, num) -> {

        PostFullInfo post = new PostFullInfo();
        post.setPost(new Post(BigInteger.valueOf(res.getLong("id")),
                res.getString("author"),
                res.getTimestamp("created"),
                res.getString("forum"),
                res.getString("message"),
                BigInteger.valueOf(res.getLong("parent")),
                BigInteger.valueOf(res.getLong("thread"))
        ));
        post.getPost().setIsEdited(res.getBoolean("isedited"));
        post.setAuthor(new User(res.getString("about"),
                res.getString("email"),
                res.getString("fullname"),
                res.getString("nickname")
        ));
        post.setThread(new Thread(res.getString("threadauthor"),
                res.getTimestamp("threadcreated"),
                res.getString("forum"),
                res.getString("threadmessage"),
                res.getString("threadslug"),
                res.getString("title")));
        post.getThread().setId(BigInteger.valueOf(res.getLong("thread")));
        post.getThread().setVotes(res.getInt("votes"));
        post.setForum(new Forum(BigInteger.valueOf(res.getLong("fid")),
                BigInteger.valueOf(res.getLong("posts")),
                BigInteger.valueOf(res.getLong("threads")),
                res.getString("forum"),
                res.getString("forumtitle"),
                res.getString("user_moderator")));
        return post;
    };

    private static final RowMapper<BigInteger> SETVAL_MAPPER = (res, num) -> {
        return BigInteger.valueOf(res.getLong("setval"));
    };



    public List<Post> createPost (List<Post> posts, BigInteger threadId ) {
        if(posts.isEmpty()) {
            return posts;
        }


        final BigInteger nextval = template.queryForObject("select nextval('post_id_seq'::regclass)",
                    BigInteger.class);

        template.query("select setval('post_id_seq'::regclass, ?) as setval",
                ps -> ps.setLong(1, nextval.longValue() + posts.size()), SETVAL_MAPPER);

        int inc = 0;
        for (Post post: posts) {
            post.setId(BigInteger.valueOf(nextval.longValue() + inc));
            inc++;
        }


        String sql = "insert into post(id, created, message, isedited, author, thread, parent, forum) " +
                "values(?,?,?,?,?,?,?,?)";
        template.batchUpdate(sql, new BatchPreparedStatementSetter() {

                @Override
                public void setValues(PreparedStatement ps, int i) throws SQLException {
                    ps.setLong(1, posts.get(i).getId().longValue());
                    ps.setTimestamp(2, posts.get(i).getCreated());
                    ps.setString(3, posts.get(i).getMessage());
                    ps.setBoolean(4, posts.get(i).getIsEdited());
                    ps.setString(5, posts.get(i).getAuthor());
                    ps.setLong(6, posts.get(i).getThread().longValue() );
                    ps.setLong(7,  posts.get(i).getParent().longValue());
                    ps.setString(8, posts.get(i).getForum());
                }

                @Override
                public int getBatchSize() {
                    return posts.size();
                }
            });



        return posts;
    }


   public List<Post> getPostByThread (BigInteger threadId, BigInteger limit, BigInteger since, String sort, Boolean desc) {
        String sql = "select *" +
                " from ";

        if (desc == null)  {
            desc = false;
        }

       switch(sort) {
           case "flat":
               sql = sql + " post where thread=? " +
                       ((since != null && desc == true) ? "AND id < ? " : "") +
                       ((since != null && desc == false) ? "AND id > ?  " : "");
               if (desc) {
                   sql = sql + "ORDER BY created desc, id desc ";
               } else {
                   sql = sql + "ORDER BY created, id ";
               }
               sql = sql + "LIMIT ?";
               break;
           case "tree":
               sql = sql +
                       "post where thread=? "+
                       ((since != null && desc == true) ? "AND path < (SELECT path from post where id =?) " : "") +
                       ((since != null && desc == false) ? "AND path > (SELECT path from post where id =?) " : "");
               if (desc) {
                   sql = sql + "ORDER BY string_to_array(ltree2text(path),'.')::integer[] desc ";
               } else {
                   sql = sql + "ORDER BY string_to_array(ltree2text(path),'.')::integer[] ";
               }
               sql = sql + "LIMIT ?";
               break;
           case "parent_tree":
               sql = sql + "(" +
                       "select post.*, dense_rank() OVER (ORDER BY subpath(path,0,1) ";

               if (desc) {
                   sql = sql + "desc) as parent_limit " +
                           "from post " +
                           "WHERE thread = ? " +
                           ((since != null) ? "AND path < (SELECT path from post where id =?) " : "") +
                           ") as r " +
                           "WHERE (r.parent_limit <= ?)  " +
                           "ORDER BY path desc ";
               } else {
                   sql = sql + " ) as parent_limit " +
                           "from post " +
                           "WHERE thread = ? " +
                           ((since != null) ? "AND path > (SELECT path from post where id =?) " : "") +
                           ") as r " +
                           "WHERE (r.parent_limit <= ?)  " +
                           "ORDER BY path ";
               }
               break;
           default:

               break;
       }



        List<Post> result = template.query( sql, ps -> {
            ps.setLong(1, threadId.longValue());
            if(since == null) {
                ps.setLong(2, limit.longValue());
            } else {
                ps.setLong(2, since.longValue());
                ps.setLong(3, limit.longValue());
            }

        }, POST_MAPPER);
        return result;
    }

    public Post getPostById (BigInteger id) {
        List<Post> result = template.query("select * from post where id=?", ps -> ps.setLong(1, id.longValue()), POST_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result.get(0);

    }

    public PostFullInfo getPostByIdWithFullInfo (BigInteger id, List<String> related) {
        List<PostFullInfo> results = template.query("SELECT *, thread.slug as threadslug, " +
                        "thread.author as threadauthor, thread.created as threadcreated," +
                        " thread.message as threadmessage, forum.title as forumtitle, " +
                        "forum.id as fid \n" +
                "FROM POST JOIN user_account \n" +
                "ON (lower(post.author) = lower(user_account.nickname))\n" +
                "JOIN thread ON (post.thread = thread.id)\n" +
                "JOIN forum ON (lower(post.forum) = lower(forum.slug))\n" +
                "WHERE post.id = ? ", ps -> ps.setLong(1, id.longValue()),
                POST_FULL_INFO_MAPPER);
        if (results.isEmpty()) {
            return null;
        }
        PostFullInfo result = new PostFullInfo();
        result.setPost(results.get(0).getPost());
        if(related != null) {
            for (String relatedType: related) {
                if(relatedType.equals("user")) {
                    result.setAuthor(results.get(0).getAuthor());
                }
                if(relatedType.equals("forum")) {
                    result.setForum(results.get(0).getForum());
                }
                if(relatedType.equals("thread")) {
                    result.setThread(results.get(0).getThread());
                }
            }
        }
        return result;

    }

    public void updatePost(String message, BigInteger id){
        template.update("UPDATE post SET message = ?, isedited = true WHERE id = ?",
                ps -> {
                    ps.setString(1, message);
                    ps.setLong(2, id.longValue());
                });
    }



}
