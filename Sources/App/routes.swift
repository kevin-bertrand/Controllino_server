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
    
    // Group creation
    let basicGroup = app.grouped(User.authenticator()).grouped(User.guardMiddleware())
    let tokenGroup = app.grouped(UserToken.authenticator()).grouped(UserToken.guardMiddleware())
    
    // User controller routes
    basicGroup.post("login", use: userController.login)
    tokenGroup.post("addUser", use: userController.addUser)
    tokenGroup.post("deleteUsers", use: userController.deleteUser)
    tokenGroup.post("changePassword", use: userController.changePassword)
    tokenGroup.post("updateUser", use: userController.updateUser)
    tokenGroup.get("users", use: userController.getUsers)
    
    // Controllino controller routes
    tokenGroup.post("addControllino", use: controllinoController.addControllino)
    tokenGroup.post("deleteControllinos", use: controllinoController.deleteControllino)
}
