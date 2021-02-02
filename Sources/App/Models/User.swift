//
//  User.swift
//  
//
//  Created by Kevin Bertrand on 01/02/2021.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let defaultUser:[String : Any] = ["email":"admin.controllino@desyntic.com", "firstname":"Super Administrator", "password":"ueRe9eLP4d0LC60", "rights":UsersRights.superAdmin, "jobTitle":"Server administrator"]
    static let schema: String = "users"
    
    //User infos
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "firstname")
    var firstname: String
    
    @OptionalField(key: "name")
    var name: String?
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @OptionalField(key: "job_title")
    var jobTitle: String?
    
    @Field(key: "rights")
    var rights: UsersRights
    
    //Initialization functions
    init() { }
    
    init(id: UUID? = nil, email: String, firstname: String, name: String? = nil, passwordHash: String, jobTitle: String? = nil, rights: UsersRights) {
        self.id = id
        self.email = email
        self.firstname = firstname
        self.name = name
        self.passwordHash = passwordHash
        self.jobTitle = jobTitle
        self.rights = rights
    }
}

enum UsersRights: String, Codable {
    case superAdmin
    case admin
    case user
    case supervisor
    case controller
    case none
}
