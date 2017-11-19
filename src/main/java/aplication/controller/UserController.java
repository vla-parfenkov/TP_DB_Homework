package aplication.controller;

import aplication.model.ErrorModels;
import aplication.model.User;



import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import aplication.dao.UserDAO;

import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping(path = "/api/user")
public class UserController {

    private final UserDAO dbUser;

    UserController(UserDAO userDAO){
        this.dbUser = userDAO;
    }


    @RequestMapping(method = RequestMethod.POST, path = "/{nickname}/create")
    public ResponseEntity createUser(@Valid @RequestBody User userData, @PathVariable(value = "nickname") String nickname,
                                           @RequestHeader(value = "Accept", required = false) String accept) {
            try {
                dbUser.createUser(nickname, userData.getEmail(), userData.getFullname(), userData.getAbout());
                return ResponseEntity.status(HttpStatus.CREATED).body(dbUser.getUser(nickname).get(0));
            } catch (DuplicateKeyException ex) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body(dbUser.getUserForEmailOrLogin(userData.getEmail(), nickname));
            }

    }


    @RequestMapping(method = RequestMethod.GET, path = "/{nickname}/profile")
    public ResponseEntity infoUser(@PathVariable(value = "nickname") String nickname) {
        List<User> users = dbUser.getUser(nickname);
        if (users == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModels("Can't find user with nickname " + nickname));
        } else {
            return ResponseEntity.status(HttpStatus.OK).body(users.get(0));
        }

    }

    @RequestMapping(method = RequestMethod.POST, path = "/{nickname}/profile")
    public ResponseEntity updateUser(@Valid @RequestBody User userData,
                                           @PathVariable(value = "nickname") String nickname,
                                           @RequestHeader(value = "Accept", required = false) String accept ) {
        final List<User> users = dbUser.getUser(nickname);
        if(users == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorModels("Can't find user with nickname " + nickname));
        } else {
            if(userData.getEmail() == null) {
                userData.setEmail(users.get(0).getEmail());
            }
            if(userData.getAbout() == null) {
                userData.setAbout(users.get(0).getAbout());
            }
            if(userData.getFullname() == null) {
                userData.setFullname(users.get(0).getFullname());
            }
            try {
                dbUser.updateUser(userData, nickname);
                return ResponseEntity.status(HttpStatus.OK).body(dbUser.getUser(nickname).get(0));
            } catch (DuplicateKeyException ex) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body(new ErrorModels("This email is already registered by user: " + dbUser.getUserForEmail(userData.getEmail()).get(0).getNickname()));
            }
        }



    }

}



