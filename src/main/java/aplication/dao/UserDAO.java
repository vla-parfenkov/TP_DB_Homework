package aplication.dao;

import aplication.model.Forum;
import aplication.model.Thread;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import aplication.model.User;

import java.math.BigInteger;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

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
                    "insert into user_account(nickname, email, fullname, about, forums)" + " values(?,?,?,?,ARRAY[0])" + " returning id",
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


    public List<User> getUserByForum (Integer forumId, BigInteger limit, String since, Boolean desc) {
        if (desc == null) {
            desc = false;
        }
       List<User> result = template.query("Select * From user_account WHERE forums @> ARRAY[?] " +
                     ((since != null && desc == true) ? "AND lower(user_account.nickname) < lower(?)  " : "") +
                    ((since != null && desc == false) ? "AND lower(user_account.nickname) > lower(?) " : "") +
                    "ORDER BY user_account.nickname " + ((desc == true) ? "desc " : "asc ") +
                    "LIMIT ?", ps -> {
                ps.setInt(1, forumId);
                if (since != null) {
                    ps.setString(2, since);
                    ps.setLong(3, limit.longValue());
                } else {
                    ps.setLong(2, limit.longValue());
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

    public void setForumToUsers(String nickname, Integer forum){
        template.update("UPDATE user_account SET forums = forums || ? WHERE lower(nickname) = lower(?) " +
                        "AND NOT forums @> ARRAY[?]  ",
                ps -> {
                    ps.setInt(1, forum);
                    ps.setString(2, nickname);
                    ps.setInt(3, forum);});
    }

    public void setForumToAuthorPost(Set<String> nicknames, Integer forum){
        if(nicknames.isEmpty()) {
            return;
        }


        List<String> author = new ArrayList<>(nicknames);

        String sql = "UPDATE user_account SET forums = forums || ? WHERE lower(nickname) = lower(?) " +
                "AND NOT forums @> ARRAY[?] ";
        template.batchUpdate(sql, new BatchPreparedStatementSetter() {

            @Override
            public void setValues(PreparedStatement ps, int i) throws SQLException {
                ps.setInt(1, forum);
                ps.setString(2, author.get(i));
                ps.setInt(3, forum);
            }

            @Override
            public int getBatchSize() {
                return author.size();
            }
        });
    }


}