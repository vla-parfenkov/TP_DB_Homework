package aplication.dao;

import aplication.model.Thread;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import aplication.model.User;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.util.List;

@Service
@Transactional
public class UserDAO {

    private final JdbcTemplate template;

    @Autowired
    public UserDAO(JdbcTemplate template) {
        this.template = template;
    }


    public User createUser(String nickname, String email, String fullname, String about) {
        GeneratedKeyHolder keyHolder = new GeneratedKeyHolder();
        template.update(con -> {
            PreparedStatement pst = con.prepareStatement(
                    "insert into user_account(nickname, email, fullname, about)" + " values(?,?,?,?)" + " returning id",
                    PreparedStatement.RETURN_GENERATED_KEYS);
            pst.setString(1, nickname);
            pst.setString(2, email);
            pst.setString(3, fullname);
            pst.setObject(4, about);
            return pst;
        }, keyHolder);
        return new User(nickname, email, fullname, about);
    }

    private static final RowMapper<User> USER_MAPPER = (res, num) -> {

        return new User(res.getString("nickname"), res.getString("email"), res.getString("fullname"),
                res.getString("about"));
    };


    public User getUser (String nickname){
        List<User> result = template.query("select * from user_account where nickname=?", ps -> ps.setString(1, nickname), USER_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result.get(0);
    }


    public List<User> getUserByForum (String forumSlug, BigDecimal limit, String since, Boolean desc) {
        List<User> result = template.query("select DISTINCT user_account.*" +
                " from thread join forum on (thread.forum = forum.id) " +
                "left join post on (post.thread = thread.id)" +
                "join user_account on (post.author = user_account.nickname or thread.author = user_account.nickname)" +
                "where forum.slug=? " + ((since != null) ? "AND user_account.nicname > " + since : "") +
                "ORDER BY user_account.nickname " + ((desc != null && desc == true) ? "desc " : "asc ") +
                "LIMIT ?", ps -> {
            ps.setString(1, forumSlug);
            ps.setBigDecimal(2, limit);

        }, USER_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result;
    }

}