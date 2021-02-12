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
}
