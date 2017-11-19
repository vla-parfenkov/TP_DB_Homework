package aplication.controller;

import aplication.dao.ForumDAO;
import aplication.dao.ThreadDAO;
import aplication.dao.UserDAO;
import aplication.model.ErrorModels;
import aplication.model.Forum;

import aplication.model.Thread;
import aplication.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.dao.DataIntegrityViolationException;

import javax.validation.Valid;
import javax.validation.constraints.DecimalMax;
import javax.validation.constraints.DecimalMin;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;


@RestController
@RequestMapping(path = "/api/forum")
public class ForumController {

    private final ForumDAO dbForum;
    private final ThreadDAO dbThread;
    private final UserDAO dbUser;

    @Autowired
    ForumController(JdbcTemplate template){
        this.dbForum = new ForumDAO(template);
        this.dbThread = new ThreadDAO(template);
        this.dbUser = new UserDAO(template);
    }

    @RequestMapping(method = RequestMethod.POST, path = "/create")
    public ResponseEntity createForum(@RequestBody Forum forumData,
                                            @RequestHeader(value = "Accept", required = false) String accept) {
        List<User> users = dbUser.getUser(forumData.getUser());
        if (users == null){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModels("Can't find user with nickname " + forumData.getUser()));
        } else {
            forumData.setUser(users.get(0).getNickname());
        }
        try {
            Forum forum = dbForum.createForum(forumData.getSlug(), forumData.getTitle(), forumData.getUser());
            return ResponseEntity.status(HttpStatus.CREATED).body(forum);
        } catch (DuplicateKeyException ex) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(dbForum.getForumBySlug(forumData.getSlug()));
        }

    }


    @RequestMapping(method = RequestMethod.POST, path = "/{slug}/create")
    public ResponseEntity createThread(@RequestBody Thread threadData,  @PathVariable(value = "slug") String slug,
                                      @RequestHeader(value = "Accept", required = false) String accept) {
        Forum forum = null;
        try {
            forum = dbForum.getForumBySlug(slug);
        } catch (EmptyResultDataAccessException ex){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModels("Can't find forum with slug " + slug));
        }
        try {
            Thread thread = dbThread.createThread(threadData.getSlug(),
                    threadData.getTitle(),
                    threadData.getAuthor(),
                    threadData.getCreated(),
                    forum.getSlug(),
                    threadData.getMessage());
            return ResponseEntity.status(HttpStatus.CREATED).body(thread);
        } catch (DuplicateKeyException ex) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(dbThread.getThreadByTitle(threadData.getTitle()));
        } catch (DataIntegrityViolationException ex) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModels("Can't find user with nickname " + threadData.getAuthor()));
        }

    }


    @RequestMapping(method = RequestMethod.GET, path = "/{slug}/details")
    public ResponseEntity detailsForum(@PathVariable(value = "slug") String slug) {
        Forum forum = dbForum.getForumBySlug(slug);
        if (forum != null) {
            return ResponseEntity.status(HttpStatus.OK).body(forum);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModels("Can't find forum with slug " + slug));
        }

    }


    @RequestMapping(method = RequestMethod.GET, path = "/{slug}/threads")
    public ResponseEntity forumGetThreads(@PathVariable(value = "slug") String slug,
                                                        @DecimalMin("1") @DecimalMax("10000") @Valid @RequestParam(value = "limit", required = false, defaultValue="100") BigDecimal limit,
                                                        @Valid @RequestParam(value = "since", required = false) Timestamp since,
                                                        @Valid @RequestParam(value = "desc", required = false) Boolean desc,
                                                        @RequestHeader(value = "Accept", required = false) String accept) {
        List<Thread> threads = dbThread.getThreadByForum(slug, limit, since, desc);
        if (threads == null){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModels("Can't find forum with slug " + slug));
        } else {
            return ResponseEntity.status(HttpStatus.OK).body(threads);
        }

    }

    @RequestMapping(method = RequestMethod.GET, path = "/{slug}/users")
    public ResponseEntity forumGetUsers(@PathVariable(value = "slug") String slug,
                                          @DecimalMin("1") @DecimalMax("10000") @Valid @RequestParam(value = "limit", required = false, defaultValue="100") BigDecimal limit,
                                          @Valid @RequestParam(value = "since", required = false) String since,
                                          @Valid @RequestParam(value = "desc", required = false) Boolean desc,
                                          @RequestHeader(value = "Accept", required = false) String accept) {
        List<User> users = dbUser.getUserByForum(slug, limit, since, desc);
        if (users == null){
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new ErrorModels("Can't find forum with slug " + slug));
        } else {
            return ResponseEntity.status(HttpStatus.OK).body(users);
        }

    }





}
