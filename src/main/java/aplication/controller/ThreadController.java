package aplication.controller;

import aplication.dao.*;
import aplication.model.*;
import aplication.model.Thread;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import javax.validation.constraints.DecimalMax;
import javax.validation.constraints.DecimalMin;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

@RestController
@RequestMapping(path = "/api/thread")
public class ThreadController {

    private final ForumDAO dbForum;
    private final ThreadDAO dbThread;
    private final UserDAO dbUser;
    private final PostDAO dbPost;
    private final VoteDAO dbVote;

    @Autowired
    ThreadController(JdbcTemplate template){
        this.dbForum = new ForumDAO(template);
        this.dbThread = new ThreadDAO(template);
        this.dbUser = new UserDAO(template);
        this.dbPost = new PostDAO(template);
        this.dbVote = new VoteDAO(template);
    }

    @RequestMapping(method = RequestMethod.POST, path = "/{slug_or_id}/create")
    public ResponseEntity createPost(@RequestBody List<Post> postData, @PathVariable(value = "slug_or_id") String slugOrId,
                                     @RequestHeader(value = "Accept", required = false) String accept) {
        Thread thread = dbThread.getThreadBySlugOrID(slugOrId);
        if(thread == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModel("Can't find thread with id " + slugOrId));
        }

        try {
            List<Post> posts = dbPost.createPost(postData, thread);
            Set<String> author = new TreeSet<>();
            for (Post post: posts) {
                author.add(post.getAuthor());
            }
           dbUser.setForumToAuthorPost(author, dbForum.setPosts(thread.getForum(), posts.size()).getId());
            return ResponseEntity.status(HttpStatus.CREATED).body(posts);
        } catch (DataIntegrityViolationException ex) {
          return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModel(ex.getMessage()));
        } catch (RuntimeException ex) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(new ErrorModel(ex.getMessage()));
        }

    }

   @RequestMapping(method = RequestMethod.POST, path = "/{slug_or_id}/vote")
    public ResponseEntity vote(@RequestBody Vote vote, @PathVariable(value = "slug_or_id") String slugOrId,
                                @RequestHeader(value = "Accept", required = false) String accept) {
       Thread thread = dbThread.getThreadBySlugOrID(slugOrId);
       if (thread == null) {
           return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModel("Can't find thread"));
       }


       try {
           Integer voice = dbVote.vote(vote.getNickname(),thread.getId(),vote.getVoice());
           thread.setVotes(thread.getVotes() + voice);
           return ResponseEntity.status(HttpStatus.OK).body(thread);
       } catch (DataIntegrityViolationException ex) {
           return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModel(ex.getMessage()));
       }


    }

    @RequestMapping(method = RequestMethod.GET, path = "/{slug_or_id}/details")
    public ResponseEntity detailsThread(@PathVariable(value = "slug_or_id") String slugOrId) {
        Thread thread = null;
        Integer threadId = null;
        try {
            threadId = Integer.valueOf(slugOrId);
        } catch (NumberFormatException ex){
            threadId = null;

        }
        if(threadId == null) {
            thread = dbThread.getThreadBySlug(slugOrId);
        } else {
            thread = dbThread.getThreadById(threadId);
        }
        if(thread == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModel("Can't find thread with "));
        } else {
            return ResponseEntity.status(HttpStatus.OK).body(thread);
        }

    }


    @RequestMapping(method = RequestMethod.GET, path = "/{slug_or_id}/posts")
    public ResponseEntity threadGetPosts(@PathVariable(value = "slug_or_id") String slugOrId,
                                          @DecimalMin("1")
                                          @DecimalMax("10000")
                                          @Valid @RequestParam(value = "limit", required = false, defaultValue="100") Integer limit,
                                          @Valid @RequestParam(value = "since", required = false) Integer since,
                                         @Valid @RequestParam(value = "sort", required = false, defaultValue = "flat") String sort,
                                          @Valid @RequestParam(value = "desc", required = false, defaultValue = "false") Boolean desc,
                                          @RequestHeader(value = "Accept", required = false) String accept) {
        Integer threadId;
        try {
            threadId = Integer.valueOf(slugOrId);
            if(dbThread.getThreadById(threadId) == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModel("Can't find thread with slug_or_id " + slugOrId));
            }
        } catch (NumberFormatException ex){
            Thread thread = dbThread.getThreadBySlug(slugOrId);
            if (thread == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModel("Can't find thread with slug_or_id " + slugOrId));
            } else {
                threadId = thread.getId();
            }

        }

        try {
            List<Post> posts = dbPost.getPostByThread(threadId, limit, since, sort, desc);
            return ResponseEntity.status(HttpStatus.OK).body(posts);
        } catch (DataIntegrityViolationException ex) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new ErrorModel(ex.toString()));
        }

    }

    @RequestMapping(method = RequestMethod.POST, path = "/{slug_or_id}/details")
    public ResponseEntity updateThread(@RequestBody Thread threadData,@PathVariable(value = "slug_or_id") String slugOrId) {
        Thread thread = null;
        Integer threadId = null;
        try {
            threadId = Integer.valueOf(slugOrId);
        } catch (NumberFormatException ex){
            threadId = null;

        }
        if(threadId == null) {
            thread = dbThread.getThreadBySlug(slugOrId);
        } else {
            thread = dbThread.getThreadById(threadId);
        }

        if(thread == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModel("Can't find thread with " + slugOrId));

        } else {
            if (threadData == null) {
                return ResponseEntity.status(HttpStatus.OK).body(thread);
            }
            if (threadData.getMessage() != null) {
                thread.setMessage(threadData.getMessage());
            }
            if (threadData.getTitle() != null) {
                thread.setTitle(threadData.getTitle());
            }
            dbThread.updateThread(thread);
            return ResponseEntity.status(HttpStatus.OK).body(thread);
        }

    }

}
