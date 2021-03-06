//
//  UserMigration.swift
//  
//
//  Created by Kevin Bertrand on 01/02/2021.
//

import Fluent
import Vapor

struct UserMigration: Migration {
    // Create DB
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.enum("rights")
            .case(UsersRights.superAdmin.rawValue)
            .case(UsersRights.admin.rawValue)
            .case(UsersRights.user.rawValue)
            .case(UsersRights.supervisor.rawValue)
            .case(UsersRights.controller.rawValue)
            .case(UsersRights.none.rawValue)
            .create()
            .flatMap { rights in
                return database.schema(User.schema)
                    .id()
                    .field("email", .string, .required)
                    .field("firstname", .string, .required)
                    .field("name", .string)
                    .field("password_hash", .string, .required)
                    .field("rights", rights, .required)
                    .field("job_title", .string)
                    .unique(on: "email")
                    .create()
                    // Add the default super administrator user
                    .flatMap { _ in
                        let user = try! User(email: User.defaultUser["email"] as! String,
                                             firstname: User.defaultUser["firstname"] as! String,
                                             passwordHash: Bcrypt.hash(User.defaultUser["password"] as! String),
                                             jobTitle: User.defaultUser["jobTitle"] as? String,
                                             rights: User.defaultUser["rights"] as! UsersRights)
                        return user.save(on: database)
                    }
            }
    }
    
    // Delete DB
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}

