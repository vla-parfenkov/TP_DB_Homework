package main;

import model.User;


import org.flywaydb.core.internal.dbsupport.JdbcTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import rest.UserDAO;

import javax.validation.Valid;

@RestController
@RequestMapping(path = "")
public class Controller {

    private final UserDAO dbUser;


    @RequestMapping(method = RequestMethod.POST, path = "/user/{nickname}/create")
    public ResponseEntity<User> createUser(@Valid @RequestBody User userData, @PathVariable(value = "nickname") String nickname,
                                           @RequestHeader(value = "Accept", required = false) String accept) {
        //if (accept != null && accept.contains("application/json")) {
            try {
                dbUser.createUser(nickname, userData.getEmail(), userData.getFullname(), userData.getAbout());
                return new ResponseEntity<User>(HttpStatus.OK);
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
            }//}


    }


    @RequestMapping(method = RequestMethod.GET, path = "/user/{nickname}/profile")
    public ResponseEntity<User> infoUser(@PathVariable(value = "nickname") String nickname) {
            try {
                return ResponseEntity.status(HttpStatus.OK).body(dbUser.getUser(nickname));
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
            }

    }
}



