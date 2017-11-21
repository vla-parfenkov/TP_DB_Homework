package aplication.controller;

import aplication.dao.ForumDAO;
import aplication.dao.PostDAO;
import aplication.dao.ThreadDAO;
import aplication.dao.UserDAO;
import aplication.model.*;
import aplication.model.Thread;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.sql.Timestamp;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.List;

@RestController
@RequestMapping(path = "/api/thread")
public class ThreadController {

    private final ForumDAO dbForum;
    private final ThreadDAO dbThread;
    private final UserDAO dbUser;
    private final PostDAO dbPost;

    @Autowired
    ThreadController(JdbcTemplate template){
        this.dbForum = new ForumDAO(template);
        this.dbThread = new ThreadDAO(template);
        this.dbUser = new UserDAO(template);
        this.dbPost = new PostDAO(template);
    }

    @RequestMapping(method = RequestMethod.POST, path = "/{slug_or_id}/create")
    public ResponseEntity createPost(@RequestBody List<Post> postData, @PathVariable(value = "slug_or_id") String slugOrId,
                                     @RequestHeader(value = "Accept", required = false) String accept) {
        Thread thread = null;
        Long threadId = null;
        try {
            threadId = Long.valueOf(slugOrId).longValue();
        } catch (NumberFormatException ex){
            try {
                thread = dbThread.getThreadBySlug(slugOrId);
            } catch (EmptyResultDataAccessException emptyEx){
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModels("Can't find thread with slug " + slugOrId));
            }
        }
        if(thread == null) {
            try {
                thread = dbThread.getThreadById(threadId);
            } catch (EmptyResultDataAccessException emptyEx) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModels("Can't find thread with id " + slugOrId));
            }
        }
        final OffsetDateTime offsetDateTime = OffsetDateTime.now();
        for (Post post:postData) {
            post.setCreated(Timestamp.valueOf(offsetDateTime.atZoneSameInstant(ZoneId.systemDefault()).toLocalDateTime()));
            post.setThread(thread.getId());
            post.setEdited(false);
            post.setForum(thread.getForum());
        }
        try {
            List<Post> posts = dbPost.createPost(postData);
            return ResponseEntity.status(HttpStatus.CREATED).body(posts);
        } catch (DataIntegrityViolationException ex) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(new ErrorModels("Can't find parent post "));
        }

    }

}
