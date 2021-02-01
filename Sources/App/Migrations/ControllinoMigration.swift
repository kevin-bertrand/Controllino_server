//
//  ControllinoMigration.swift
//  
//
//  Created by Kevin Bertrand on 01/02/2021.
//

import Foundation

import Fluent
import Vapor

struct ControllinoMigration: Migration {
    // Create DB
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("controllino")
            .field("serial_number", .string, .required)
            .field("type", .string, .required)
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .field("creationDate", .datetime, .required)
            .field("lastModificationDate", .datetime, .required)
            .field("ipAddress", .string)
            .field("a0", .bool)
            .field("a1", .bool)
            .field("a2", .bool)
            .field("a3", .bool)
            .field("a4", .bool)
            .field("a5", .bool)
            .field("a6", .bool)
            .field("a7", .bool)
            .field("a8", .bool)
            .field("a9", .bool)
            .field("a10", .bool)
            .field("a11", .bool)
            .field("a12", .bool)
            .field("a13", .bool)
            .field("a14", .bool)
            .field("a15", .bool)
            .field("i16", .bool)
            .field("i17", .bool)
            .field("i18", .bool)
            .field("int0", .bool)
            .field("int1", .bool)
            .field("d0", .bool)
            .field("d1", .bool)
            .field("d2", .bool)
            .field("d3", .bool)
            .field("d4", .bool)
            .field("d5", .bool)
            .field("d6", .bool)
            .field("d7", .bool)
            .field("d8", .bool)
            .field("d9", .bool)
            .field("d10", .bool)
            .field("d11", .bool)
            .field("d12", .bool)
            .field("d13", .bool)
            .field("d14", .bool)
            .field("d15", .bool)
            .field("d16", .bool)
            .field("d17", .bool)
            .field("d18", .bool)
            .field("d19", .bool)
            .field("d20", .bool)
            .field("d21", .bool)
            .field("d22", .bool)
            .field("d23", .bool)
            .field("r0", .bool)
            .field("r1", .bool)
            .field("r2", .bool)
            .field("r3", .bool)
            .field("r4", .bool)
            .field("r5", .bool)
            .field("r6", .bool)
            .field("r7", .bool)
            .field("r8", .bool)
            .field("r9", .bool)
            .field("r10", .bool)
            .field("r11", .bool)
            .field("r12", .bool)
            .field("r13", .bool)
            .field("r14", .bool)
            .field("r15", .bool)
            .unique(on: "serial_number")
            .create()
    }
    
    // Delete DB
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("controllino").delete()
    }
}
