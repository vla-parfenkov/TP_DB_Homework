package aplication.dao;

import aplication.model.Thread;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import aplication.model.User;

import java.math.BigInteger;
import java.sql.PreparedStatement;
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

        return new User(res.getString("about"), res.getString("email"), res.getString("fullname"),
                res.getString("nickname"));
    };


    public List<User> getUser (String nickname){
        List<User> result = template.query("select * from user_account where lower(nickname)=lower(?)", ps -> ps.setString(1, nickname), USER_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result;
    }

    public List<User> getUserForEmail (String email){
        List<User> result = template.query("select * from user_account where lower(email)=lower(?)", ps -> ps.setString(1, email), USER_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result;
    }


    public List<User> getUserForEmailOrLogin (String email, String nickname){
        List<User> result = template.query("select * from user_account where lower(email) = lower(?) OR lower(nickname) = lower(?)", ps -> {
            ps.setString(1, email);
            ps.setString(2, nickname);}, USER_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result;
    }


    public List<User> getUserByForum (String forumSlug, BigInteger limit, String since, Boolean desc) {
        if (desc == null) {
            desc = false;
        }
       List<User> result = template.query("select * " +
                    " from user_account join" +
               " (select author from thread Where lower(forum) = lower(?) " +
               "UNION select author from post Where lower(forum) = lower(?)) as t_p " +
               "ON lower(t_p.author) = lower(user_account.nickname) " +
                     ((since != null && desc == true) ? "AND lower(user_account.nickname) < lower(?)  " : "") +
                    ((since != null && desc == false) ? "AND lower(user_account.nickname) > lower(?) " : "") +
                    "ORDER BY user_account.nickname " + ((desc == true) ? "desc " : "asc ") +
                    "LIMIT ?", ps -> {
                ps.setString(1, forumSlug);
                ps.setString(2,forumSlug);
                if (since != null) {
                    ps.setString(3, since);
                    ps.setLong(4, limit.longValue());
                } else {
                    ps.setLong(3, limit.longValue());
                }

        }, USER_MAPPER);

        return result;
    }

    public void updateUser(User userData, String nickname){
        template.update("UPDATE user_account SET about = ?, email = ?, fullname = ? WHERE lower(nickname) = lower(?)",
                ps -> {
            ps.setString(1, userData.getAbout());
            ps.setString(2, userData.getEmail());
            ps.setString(3, userData.getFullname());
            ps.setString(4, nickname);});
    }


}