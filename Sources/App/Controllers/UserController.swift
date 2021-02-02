//
//  UserController.swift
//  
//
//  Created by Kevin Bertrand on 02/02/2021.
//

import Fluent
import FluentSQL
import Foundation
import Vapor

struct UserController {
    /*
     Public functions for HTTP requests
     */
    func login(req: Request) throws -> EventLoopFuture<User.UserInformations> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        let token = try userAuth.generateToken()
        let userInformations = User.UserInformations(firstname: userAuth.firstname, name: userAuth.name ?? "", email: userAuth.email, rights: userAuth.rights, tokenValue: token.value)
        
        return token.save(on: req.db).transform(to: userInformations)
    }
}

extension User {
    struct UserInformations: Content, Codable {
        let firstname: String
        let name: String
        let email: String
        let rights: UsersRights
        let tokenValue: String
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey = \User.$email
    static var passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        return try Bcrypt.verify(password, created: self.passwordHash)
    }
    
    func generateToken() throws -> UserToken{
        return try UserToken(value: [UInt8].random(count: 16).base64, userID: self.requireID())
    }
}

extension UserToken: ModelTokenAuthenticatable {
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$user

    var isValid: Bool {
        true
    }
}
