package aplication.dao;

import aplication.model.ServiceModel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigInteger;
import java.util.List;

@Service
@Transactional
public class ServiceDAO {
    private final JdbcTemplate template;

    @Autowired
    public ServiceDAO(JdbcTemplate template) {
        this.template = template;
    }

    private static final RowMapper<ServiceModel> SERVICE_MAPPER = (res, num) -> {

        return new ServiceModel(BigInteger.valueOf(res.getLong("forum")),
                BigInteger.valueOf(res.getLong("post")),
                BigInteger.valueOf(res.getLong("thread")),
                BigInteger.valueOf(res.getLong("user")));
    };


    public ServiceModel serviceInfo(){
        List<ServiceModel> serviceModels = template.query("SELECT * FROM (Select count(*) as forum, " +
                "sum(posts) as post, sum(threads) as thread\n" +
                "FROM forum ) as f CROSS JOIN\n" +
                " (Select count(*) as user\n" +
                "FROM user_account) as u", SERVICE_MAPPER);
        if(serviceModels.isEmpty()) {
            return null;
        }
        return serviceModels.get(0);
    }

    public void serviceClear () {
        template.update("TRUNCATE TABLE user_account CASCADE ");
    }

}
