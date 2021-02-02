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
    
    // Group creation
    let basicGroup = app.grouped(User.authenticator()).grouped(User.guardMiddleware())
    let tokenGroup = app.grouped(UserToken.authenticator()).grouped(UserToken.guardMiddleware())
    
    // User controller routes
    basicGroup.post("login", use: userController.login)
    tokenGroup.post("addUser", use: userController.addUser)
}
