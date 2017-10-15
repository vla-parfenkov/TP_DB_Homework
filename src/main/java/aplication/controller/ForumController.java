package aplication.controller;

import aplication.dao.ForumDAO;
import aplication.dao.ThreadDAO;
import aplication.model.ErrorModels;
import aplication.model.Forum;

import aplication.model.Thread;
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
import java.sql.SQLException;
import java.sql.Timestamp;


@RestController
@RequestMapping(path = "/forum")
public class ForumController {

    private final ForumDAO dbForum;
    private final ThreadDAO dbThread;

    @Autowired
    ForumController(JdbcTemplate template){
        this.dbForum = new ForumDAO(template);
        this.dbThread = new ThreadDAO(template);
    }

    @RequestMapping(method = RequestMethod.POST, path = "/create")
    public ResponseEntity createForum(@RequestBody Forum forumData,
                                            @RequestHeader(value = "Accept", required = false) String accept) {
        try {
            Forum forum = dbForum.createForum(forumData.getSlug(), forumData.getTitle(), forumData.getUser());
            return ResponseEntity.status(HttpStatus.CREATED).body(forum);
        } catch (DuplicateKeyException ex) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(dbForum.getForumBySlug(forumData.getSlug()));
        } catch (DataIntegrityViolationException ex) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModels("Can't find user with nickname " + forumData.getUser()));
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
            //!
            Thread thread = dbThread.createThread(threadData.getTitle(),
                    threadData.getTitle(),
                    threadData.getAuthor(),
                    threadData.getCreated(),
                    forum.getId(),
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
        try {
            return ResponseEntity.status(HttpStatus.OK).body(dbForum.getForumBySlug(slug));
        } catch (EmptyResultDataAccessException ex) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new ErrorModels("Can't find forum with slug " + slug));
        }

    }


    @RequestMapping(method = RequestMethod.GET, path = "/{slug}/threads")
    public ResponseEntity forumGetThreads(@PathVariable(value = "slug") String slug,
                                          @DecimalMin("1") @DecimalMax("10000") @Valid @RequestParam(value = "limit", required = false, defaultValue="100") BigDecimal limit,
                                          @Valid @RequestParam(value = "since", required = false) Timestamp since,
                                          @Valid @RequestParam(value = "desc", required = false) Boolean desc,
                                          @RequestHeader(value = "Accept", required = false) String accept) {
      //
    }



}
