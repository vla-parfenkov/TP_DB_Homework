package aplication.controller;

import aplication.dao.ForumDAO;
import aplication.model.Forum;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping(path = "/forum")
public class ForumController {

    private final ForumDAO dbForum;

    ForumController(ForumDAO forumDAO){
        this.dbForum = forumDAO;
    }

    @RequestMapping(method = RequestMethod.POST, path = "/create")
    public ResponseEntity<Forum> createForum(@RequestBody Forum forumData,
                                            @RequestHeader(value = "Accept", required = false) String accept) {
        try {
            Forum forum = dbForum.createForum(forumData.getSlug(), forumData.getTitle(), forumData.getUser());
            return ResponseEntity.status(HttpStatus.OK).body(forum);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
        }


    }




}
