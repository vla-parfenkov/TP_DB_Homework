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
        template.update(con -> {
            PreparedStatement pst = con.prepareStatement(
                    "insert into thread_votes(nickname, thread, voice)" + " values(?,?,?)");
            pst.setString(1, nickname);
            pst.setLong(2, thread.longValue());
            pst.setInt(3, voice);
            return pst;
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
