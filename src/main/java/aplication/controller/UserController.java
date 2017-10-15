package aplication.controller;

import aplication.model.User;


import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import aplication.dao.UserDAO;

import javax.validation.Valid;

@RestController
@RequestMapping(path = "/user")
public class UserController {

    private final UserDAO dbUser;

    UserController(UserDAO userDAO){
        this.dbUser = userDAO;
    }


    @RequestMapping(method = RequestMethod.POST, path = "/{nickname}/create")
    public ResponseEntity<User> createUser(@Valid @RequestBody User userData, @PathVariable(value = "nickname") String nickname,
                                           @RequestHeader(value = "Accept", required = false) String accept) {
            try {
                dbUser.createUser(nickname, userData.getEmail(), userData.getFullname(), userData.getAbout());
                return ResponseEntity.status(HttpStatus.OK).body(dbUser.getUser(nickname));
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
            }


    }


    @RequestMapping(method = RequestMethod.GET, path = "/{nickname}/profile")
    public ResponseEntity<User> infoUser(@PathVariable(value = "nickname") String nickname) {
            try {
                return ResponseEntity.status(HttpStatus.OK).body(dbUser.getUser(nickname));
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
            }

    }
}



