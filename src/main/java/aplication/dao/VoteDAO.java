package aplication.dao;

import aplication.model.Vote;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigInteger;
import java.sql.PreparedStatement;

@Service
@Transactional
public class VoteDAO {

    private final JdbcTemplate template;

    @Autowired
    public VoteDAO(JdbcTemplate template) {
        this.template = template;
    }


    public Vote createVote(String nickname, Integer voice, BigInteger thread) {
        template.update("insert into thread_votes(nickname, thread, voice)" + " values(?,?,?)", ps ->{
            ps.setString(1, nickname);
            ps.setLong(2, thread.longValue());
            ps.setInt(3, voice);
        });
        return new Vote(nickname, voice, thread);
    }

    public void updateVote(String nickname, Integer voice, BigInteger thread) {
        template.update("UPDATE thread_votes SET voice = ? WHERE lower(nickname) = lower(?) AND thread = ?",
                ps -> {
                    ps.setInt(1, voice);
                    ps.setString(2, nickname);
                    ps.setLong(3, thread.longValue());
                });

    }
}
