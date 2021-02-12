//
//  UserTokenMigration.swift
//
//
//  Created by Kevin Bertrand on 01/02/2021.
//

import Fluent
import Vapor

struct UserTokenMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UserToken.schema)
            .id()
            .field("value", .string, .required)
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .unique(on: "value")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UserToken.schema).delete()
    }
}
