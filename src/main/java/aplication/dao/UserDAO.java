package aplication.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import aplication.model.User;

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

}