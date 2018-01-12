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
    private static final RowMapper<Integer> VOICE_MAPPER = (res, num) -> res.getInt("voice");


    public void createVote(Integer userId, Integer voice, Integer thread) {

        template.update("insert into thread_votes(user_id, thread, voice)"
                + " values(?,?,?) ", ps ->{
            ps.setInt(1, userId);
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

    public Integer vote(String nickname, Integer thread, Integer voice) {
        return template.query("select procces_vote(?, ?, ?) as voice ", ps ->{
            ps.setString(1, nickname);
            ps.setInt(2, voice);
            ps.setInt(3, thread);
        }, VOICE_MAPPER ).get(0);
    }
}
