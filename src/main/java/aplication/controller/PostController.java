package aplication.controller;

import aplication.dao.*;
import aplication.model.ErrorModel;
import aplication.model.Post;
import aplication.model.PostFullInfo;
import aplication.model.Thread;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import javax.websocket.server.PathParam;
import java.math.BigInteger;
import java.util.List;

@RestController
@RequestMapping(path = "/api/post")
public class PostController {
    private final ForumDAO dbForum;
    private final ThreadDAO dbThread;
    private final UserDAO dbUser;
    private final PostDAO dbPost;
    private final VoteDAO dbVote;

    @Autowired
    PostController(JdbcTemplate template){
        this.dbForum = new ForumDAO(template);
        this.dbThread = new ThreadDAO(template);
        this.dbUser = new UserDAO(template);
        this.dbPost = new PostDAO(template);
        this.dbVote = new VoteDAO(template);
    }

    @RequestMapping(method = RequestMethod.GET, path = "/{id}/details")
    public ResponseEntity detailsPost(@PathVariable(value = "id") BigInteger id,
                                      @Valid @RequestParam(value = "related", required = false) List<String> related) {

        PostFullInfo post = new PostFullInfo();
        if(id == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModel("Can't find post without id "));
        }
        if (related == null) {
            Post returnedPost = dbPost.getPostById(id);
            if (returnedPost == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModel("Can't find post with id "
                        + id.toString()));
            } else {
                post.setPost(returnedPost);
                return ResponseEntity.status(HttpStatus.OK).body(post);
            }
        } else {
            post = dbPost.getPostByIdWithFullInfo(id, related);
            if (post == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModel("Can't find post with id "
                        + id.toString()));
            } else {
                return ResponseEntity.status(HttpStatus.OK).body(post);
            }
        }
    }

    @RequestMapping(method = RequestMethod.POST, path = "/{id}/details")
    public ResponseEntity updatePost(@RequestBody Post postData, @PathVariable(value = "id") BigInteger id) {
        Post post = dbPost.getPostById(id);
        if(post == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModel("Can't find post with id "
                    + id.toString()));
        }
        if (post.getMessage().equals(postData.getMessage()) || (postData.getMessage() == null)) {
            return ResponseEntity.status(HttpStatus.OK).body(post);
        } else {
            dbPost.updatePost(postData.getMessage(), id);
            post.setMessage(postData.getMessage());
            post.setIsEdited(true);
            return ResponseEntity.status(HttpStatus.OK).body(post);
        }

    }


}
