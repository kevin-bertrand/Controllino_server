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
    // First login of one User with Basic Auth to get token
    func login(req: Request) throws -> EventLoopFuture<User.UserInformations> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        let token = try userAuth.generateToken()
        let userInformations = User.UserInformations(firstname: userAuth.firstname, name: userAuth.name ?? "", email: userAuth.email, rights: userAuth.rights, tokenValue: token.value)
        
        return token.save(on: req.db).transform(to: userInformations)
    }
    
    // Create a new controllino from a JSON request : {"firstname":"Test","name":"Serveur","email":"test@desyntic.fr","password":"159753","rights":"admin"}
    func addUser(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        let receivedData = try req.content.decode(User.Create.self)
        let rights = checkNewUserRights(receivedData.rights)
        let user = try User(email: receivedData.email,
                            firstname: receivedData.firstname,
                            name: receivedData.name,
                            passwordHash: Bcrypt.hash(receivedData.password),
                            jobTitle: receivedData.jobTitle,
                            rights: rights)
        
        return User.query(on: req.db)
            .first()
            .guard({ _ -> Bool in
                return userAuth.rights == .admin || userAuth.rights == .superAdmin
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .flatMap { _ -> EventLoopFuture<HTTPStatus> in
                user.save(on: req.db).transform(to: HttpStatus().send(status: .created))
            }
    }
    
    // Get all user in database
    func getUsers(req: Request) throws -> EventLoopFuture<[User.UserList]> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        
        return User.query(on: req.db)
            .all()
            .guard({ _ -> Bool in
                return userAuth.rights == .admin || userAuth.rights == .superAdmin
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .map { users -> [User.UserList] in
                var userList: [User.UserList] = []
                
                for user in users {
                    userList.append(User.UserList(email: user.email, firstname: user.firstname, name: user.name ?? "", rights: user.rights, jobTitle: user.jobTitle ?? ""))
                }
                
                return userList
            }
    }
    
    /*
     Private functions
     */
    // This function check rights from the create of a user and return the correct right from the enum 'Rights'
    private func checkNewUserRights(_ data: String) -> UsersRights {
        let rights: UsersRights
        
        if data == "admin" {
            rights = .admin
        } else if data == "user" {
            rights = .user
        } else if data == "controller" {
            rights = .controller
        } else if data == "supervisor" {
            rights = .supervisor
        } else {
            rights = .none
        }
        
        return rights
    }
}

extension User {
    struct Create: Content {
        let firstname: String
        let name: String?
        let email: String
        let password: String
        let rights: String
        let jobTitle: String?
    }
    
    struct UserInformations: Content, Codable {
        let firstname: String
        let name: String
        let email: String
        let rights: UsersRights
        let tokenValue: String
    }
    
    struct UserList: Content {
        let email: String
        let firstname: String
        let name: String
        let rights: UsersRights
        let jobTitle: String
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
