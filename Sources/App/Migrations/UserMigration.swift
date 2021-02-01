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
            .case(Rights.superAdmin.rawValue)
            .case(Rights.admin.rawValue)
            .case(Rights.user.rawValue)
            .case(Rights.supervisor.rawValue)
            .case(Rights.controller.rawValue)
            .case(Rights.none.rawValue)
            .create()
            .flatMap { rights in
                return database.schema("users")
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
                        let user = try! User(email: "admin.controllino@desyntic.com",
                                             firstname: "Super Administrator",
                                             passwordHash: Bcrypt.hash("ueRe9eLP4d0LC60"),
                                             jobTitle: "Server administrator",
                                             rights: .superAdmin)
                        return user.save(on: database)
                    }
            }
    }
    
    // Delete DB
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}

