package aplication.dao;


import aplication.model.Vote;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
@Transactional
public class VoteDAO {

    private final JdbcTemplate template;

    @Autowired
    public VoteDAO(JdbcTemplate template) {
        this.template = template;
    }

    private static final RowMapper<Vote> VOTE_MAPPER = (res, num) -> {

        Vote voice = new Vote(null,res.getInt("voice"),
                res.getInt("thread"));
        voice.setUserId(res.getInt("user_id"));
        return voice;
    };

    public void createVote(String nickname, Integer voice, Integer thread) {

        template.update("insert into thread_votes(user_id, thread, voice)"
                + " values((SELECT id FROM user_account " +
                "WHERE lower(nickname) = lower(?)),?,?) ", ps ->{
            ps.setString(1, nickname);
            ps.setInt(2, thread);
            ps.setInt(3, voice);
        });
    }

    public void updateVote(Integer userId, Integer voice, Integer thread) {
        template.update("UPDATE thread_votes SET voice = ? WHERE user_id = ? AND thread = ?",
                ps -> {
                    ps.setInt(1, voice);
                    ps.setInt(2, userId);
                    ps.setInt(3, thread);
                });

    }

    public Vote getVote(Integer user, Integer thread) {

        List<Vote> result = template.query("SELECT * FROM thread_votes " +
                "WHERE user_id = ? AND thread = ?", ps ->{
            ps.setInt(1, user);
            ps.setInt(2, thread);
        }, VOTE_MAPPER);
        if (result.isEmpty()) {
            return null;
        }
        return result.get(0);
    }
}
