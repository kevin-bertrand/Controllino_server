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
    func login(req: Request) throws -> EventLoopFuture<User.Informations> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        let token = try userAuth.generateToken()
        let userInformations = User.Informations(firstname: userAuth.firstname, name: userAuth.name ?? "", email: userAuth.email, rights: userAuth.rights, tokenValue: token.value)
        
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
    func getUsers(req: Request) throws -> EventLoopFuture<[User.List]> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        
        return User.query(on: req.db)
            .all()
            .guard({ _ -> Bool in
                return userAuth.rights == .admin || userAuth.rights == .superAdmin
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .map { users -> [User.List] in
                var userList: [User.List] = []
                
                for user in users {
                    userList.append(User.List(email: user.email, firstname: user.firstname, name: user.name ?? "", rights: user.rights, jobTitle: user.jobTitle ?? ""))
                }
                
                return userList
            }
    }
    
    // Delete a list of users
    func deleteUser(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        let receivedData = try req.content.decode(User.Delete.self)
        var query = "DELETE FROM users WHERE "
        var firstEmail = true
        
        for email in receivedData.emails {
            if email != User.defaultUser["email"] as! String {
                if !firstEmail {
                    query += " OR "
                }
                
                query += "email == \"\(email)\""
                firstEmail = false
            }
        }
        
        return performSqlQueries(inside: req, with: query, by: userAuth)
    }
    
    // Change password of the current user
    func changePassword(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        var receivedData = try req.content.decode(User.ChangePassword.self)
        receivedData.newPassword = try Bcrypt.hash(receivedData.newPassword)
        
        return User.find(userAuth.id, on: req.db)
            .guard({ _ -> Bool in
                do {
                    return try userAuth.verify(password: receivedData.oldPassword)
                } catch {
                    return false
                }
            }, else: Abort(HttpStatus().send(status: .wrongPassword)))
            .flatMap { user -> EventLoopFuture<HTTPStatus> in
                updatePassword(user, inside: req, with: receivedData)
            }
    }
    
    // Update one user info
    func updateUser(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        let receivedData = try req.content.decode(User.Update.self)
        
        return User.query(on: req.db)
            .filter(\.$email == receivedData.email)
            .first()
            .guard({ _ -> Bool in
                return userAuth.rights == .admin || userAuth.rights == .superAdmin || userAuth.email == receivedData.email
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .flatMap { user -> EventLoopFuture<HTTPStatus> in
                updateUser(user, inside: req, with: receivedData, by: userAuth)
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
    
    private func updatePassword(_ user: User?, inside req: Request, with data: User.ChangePassword) -> EventLoopFuture<HTTPStatus> {
        if let user = user,
           let sql = req.db as? SQLDatabase {
            return sql.update("users")
                .set("password_hash", to: data.newPassword)
                .where("email", .equal, user.email)
                .run()
                .transform(to: .ok)
        } else {
            return EventLoopFutureReturn().errorHttpStatus(on: req, withError: HttpStatus().send(status: .unableToReachDb))
        }
    }
    
    private func updateUser(_ user: User?, inside req: Request, with data: User.Update, by ask: User) -> EventLoopFuture<HTTPStatus> {
        if let user = user,
           let sql = req.db as? SQLDatabase {
            if user.email == ask.email && ask.rights != .admin && ask.rights != .superAdmin {
                return sql.update("users")
                    .set("name", to: data.name)
                    .set("firstname", to: data.firstname)
                    .set("job_title", to: data.jobTitle)
                    .where("email", .equal, data.email)
                    .run()
                    .transform(to: .ok)
            } else {
                return sql.update("users")
                    .set("rights", to: data.rights)
                    .set("name", to: data.name)
                    .set("firstname", to: data.firstname)
                    .set("job_title", to: data.jobTitle)
                    .where("email", .equal, data.email)
                    .run()
                    .transform(to: .ok)
            }
        } else {
            return EventLoopFutureReturn().errorHttpStatus(on: req, withError: HttpStatus().send(status: .unableToReachDb))
        }
    }
    
    private func performSqlQueries(inside req: Request, with query: String, by user: User) -> EventLoopFuture<HTTPStatus> {
        if let sql = req.db as? SQLDatabase,
           user.rights == .superAdmin || user.rights == .admin {
            return sql.raw(SQLQueryString(query)).run().transform(to: .ok)
        } else {
            return EventLoopFutureReturn().errorHttpStatus(on: req, withError: HttpStatus().send(status: .unableToReachDb))
        }
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
    
    struct Informations: Content, Codable {
        let firstname: String
        let name: String
        let email: String
        let rights: UsersRights
        let tokenValue: String
    }
    
    struct List: Content {
        let email: String
        let firstname: String
        let name: String
        let rights: UsersRights
        let jobTitle: String
    }
    
    struct Delete: Content {
        let emails: [String]
    }
    
    struct ChangePassword: Content {
        let oldPassword: String
        var newPassword: String
    }
    
    struct Update: Content {
        let email: String
        let firstname: String
        let name: String
        let rights: String
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
