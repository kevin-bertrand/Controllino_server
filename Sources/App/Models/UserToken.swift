//
//  UserToken.swift
//
//
//  Created by Kevin Bertrand on 01/02/2021.
//

import Fluent
import Vapor

final class UserToken: Model, Content {
    static let schema: String = "user_tokens"
    
    // Token infos
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    @Parent(key: "user_id")
    var user: User
    
    // Inititalization functions
    init() { }
    
    init(id: UUID? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}
