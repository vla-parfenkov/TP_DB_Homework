package aplication.dao;

import aplication.model.*;
import aplication.model.Thread;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;



import java.sql.*;
import java.time.OffsetDateTime;
import java.time.ZoneId;
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

        Integer thread = res.getInt("thread");
        if (res.wasNull()) {
            thread = null;
        }

        Integer parent = res.getInt("parent");
        if (res.wasNull()){
            parent = null;
        }

        String forum = res.getString("forum");
        if (res.wasNull()) {
            forum = null;
        }

        Post post = new Post(res.getInt("id"),
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
        post.setPost(new Post(res.getInt("id"),
                res.getString("author"),
                res.getTimestamp("created"),
                res.getString("forum"),
                res.getString("message"),
                res.getInt("parent"),
                res.getInt("thread")
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
        post.getThread().setId(res.getInt("thread"));
        post.getThread().setVotes(res.getInt("votes"));
        post.setForum(new Forum(res.getInt("fid"),
                res.getInt("posts"),
                res.getInt("threads"),
                res.getString("forum"),
                res.getString("forumtitle"),
                res.getString("user_moderator")));
        return post;
    };
    



    public List<Post> createPost (List<Post> posts, Thread thread ) {
        if(posts.isEmpty()) {
            return posts;
        }



        final OffsetDateTime offsetDateTime = OffsetDateTime.now();
        for (Post post:posts) {
            post.setId(template.queryForObject("select nextval('post_id_seq'::regclass)", Integer.class));
            post.setCreated(Timestamp.valueOf(offsetDateTime.atZoneSameInstant(ZoneId.systemDefault()).toLocalDateTime()));
            post.setThread(thread.getId());
            post.setIsEdited(false);
            post.setForum(thread.getForum());
        }


        String sql = "insert into post(id, created, message, isedited, author, thread, parent, forum) " +
                "values(?,?,?,?,?,?,?,?)";
        template.batchUpdate(sql, new BatchPreparedStatementSetter() {

                @Override
                public void setValues(PreparedStatement ps, int i) throws SQLException {
                    ps.setInt(1, posts.get(i).getId());
                    ps.setTimestamp(2, posts.get(i).getCreated());
                    ps.setString(3, posts.get(i).getMessage());
                    ps.setBoolean(4, posts.get(i).getIsEdited());
                    ps.setString(5, posts.get(i).getAuthor());
                    ps.setInt(6, posts.get(i).getThread() );
                    ps.setInt(7,  posts.get(i).getParent());
                    ps.setString(8, posts.get(i).getForum());
                }

                @Override
                public int getBatchSize() {
                    return posts.size();
                }
            });



        return posts;
    }


   public List<Post> getPostByThread (Integer threadId, Integer limit, Integer since, String sort, Boolean desc) {
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
                   sql = sql + "ORDER BY path desc ";
               } else {
                   sql = sql + "ORDER BY path ";
               }
               sql = sql + "LIMIT ?";
               break;
           case "parent_tree":
               sql = sql + "(" +
                       "select post.*, dense_rank() OVER (ORDER BY subarray(path,0,1) ";

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
            ps.setInt(1, threadId);
            if(since == null) {
                ps.setInt(2, limit);
            } else {
                ps.setInt(2, since);
                ps.setInt(3, limit);
            }

        }, POST_MAPPER);
        return result;
    }

    public Post getPostById (Integer id) {
        List<Post> result = template.query("select * from post where id=?", ps -> ps.setInt(1, id), POST_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result.get(0);

    }

    public PostFullInfo getPostByIdWithFullInfo (Integer id, List<String> related) {
        List<PostFullInfo> results = template.query("SELECT *, thread.slug as threadslug, " +
                        "thread.author as threadauthor, thread.created as threadcreated," +
                        " thread.message as threadmessage, forum.title as forumtitle, " +
                        "forum.id as fid \n" +
                "FROM POST JOIN user_account \n" +
                "ON (lower(post.author) = lower(user_account.nickname))\n" +
                "JOIN thread ON (post.thread = thread.id)\n" +
                "JOIN forum ON (lower(thread.forum) = lower(forum.slug))\n" +
                "WHERE post.id = ? ", ps -> ps.setInt(1, id),
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

    public void updatePost(String message, Integer id){
        template.update("UPDATE post SET message = ?, isedited = true WHERE id = ?",
                ps -> {
                    ps.setString(1, message);
                    ps.setInt(2, id);
                });
    }




}
