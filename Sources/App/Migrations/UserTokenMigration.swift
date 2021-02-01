//
//  UserTokenMigration.swift
//
//
//  Created by Kevin Bertrand on 01/02/2021.
//

import Fluent
import Vapor

struct CreateUserToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_tokens")
            .id()
            .field("value", .string, .required)
            .field("user_id", .uuid, .required, .references("users", "id"))
            .unique(on: "value")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_tokens").delete()
    }
}
