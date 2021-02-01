//
//  configure.swift
//
//
//  Created by Kevin Bertrand on 01/02/2021.
//

import Fluent
import FluentMySQLDriver
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // Check wich DB use
    if app.environment == .production {
        app.databases.use(.mysql(hostname: "127.0.0.1", port: 3306, username: "vapor_user", password: "7-32Fh_ero57-#", database: "vapor", tlsConfiguration: TLSConfiguration.forClient(certificateVerification: .none)), as: .mysql)
    } else {
        app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    }
    
    // Add migration support
    
    // register routes
    try routes(app)
}
