//
//  routes.swift
//
//
//  Created by Kevin Bertrand on 01/02/2021.
//

import Fluent
import Vapor

func routes(_ app: Application) throws {
    // Controllers
    let userController = UserController()
    let controllinoController = ControllinoController()
    let pinsLabelsController = PinsLabelsController()
    let alarmsController = AlarmsController()
    
    // Group creation
    let basicGroup = app.grouped(User.authenticator()).grouped(User.guardMiddleware())
    let tokenGroup = app.grouped(UserToken.authenticator()).grouped(UserToken.guardMiddleware())
    
    // User controller routes
    basicGroup.post("login", use: userController.login)
    tokenGroup.post("addUser", use: userController.addUser)
    tokenGroup.post("deleteUsers", use: userController.deleteUser)
    tokenGroup.post("changePassword", use: userController.changePassword)
    tokenGroup.post("updateUser", use: userController.updateUser)
    tokenGroup.get("getUsers", use: userController.getUsers)
    tokenGroup.get("getOneUser", ":email", use: userController.getOneUser)
    
    // Controllino controller routes
    app.get("getUniqueControllino", ":serialNumber", use: controllinoController.getUniqueControllino)
    app.get("getControllinos", use: controllinoController.getControllinos)
    tokenGroup.post("addControllino", use: controllinoController.addControllino)
    tokenGroup.post("deleteControllinos", use: controllinoController.deleteControllino)
    tokenGroup.post("updateControllino", use: controllinoController.updateControllino)
    tokenGroup.post("updateControllinoIp", use: controllinoController.updateIpAdress)
    tokenGroup.post("updateOnePin", ":pin", use: controllinoController.updateOnePin)
    tokenGroup.post("updateAllPins", use: controllinoController.updateAllPins)
    
    // Labels controller routes
    tokenGroup.get("getAllLabels", use: pinsLabelsController.getAllLabels)
    tokenGroup.get("getOneControllerLabels", ":serialNumber", use: pinsLabelsController.getOneControllerLabels)
    tokenGroup.post("modifyLabels", use: pinsLabelsController.modifyLabels)
    
    // Alarms controller routes
    tokenGroup.post("addAlarm", use: alarmsController.addAlarms)
    tokenGroup.post("deleteAlarms", use: alarmsController.deleteAlarm)
    tokenGroup.post("toggleAlarmActivation", use: alarmsController.switchOffOnAlarm)
    tokenGroup.get("getAllAlarms", use: alarmsController.getAllAlarms)
    tokenGroup.get("getAlarms", ":serialNumber", use: alarmsController.getAlarmsForOneController)
    tokenGroup.get("getAlarm", ":id", use: alarmsController.getAlarm)
}
