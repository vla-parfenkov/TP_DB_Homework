package aplication.controller;

import aplication.dao.ServiceDAO;
import aplication.model.ServiceModel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = "/api/service")
public class ServiceController {

    private final ServiceDAO dbService;


    @Autowired
    ServiceController(ServiceDAO serviceDAO){
        this.dbService = serviceDAO;
    }


    @RequestMapping(method = RequestMethod.GET, path = "/status")
    public ResponseEntity<ServiceModel> infoService() {
        return ResponseEntity.status(HttpStatus.OK).body(dbService.serviceInfo());

    }

    @RequestMapping(method = RequestMethod.POST, path = "/clear")
    public ResponseEntity clearService() {
        dbService.serviceClear();
        return ResponseEntity.status(HttpStatus.OK).body("Db is clear");
    }



}
