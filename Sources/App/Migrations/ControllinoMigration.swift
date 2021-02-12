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
        return database.enum("controllino_type")
            .case(ControllinoType.mega.rawValue)
            .case(ControllinoType.maxi.rawValue)
            .create()
            .flatMap { controllinoType in
                return database.schema(Controllino.schema)
                    .field("serial_number", .string, .required)
                    .field("type", controllinoType, .required)
                    .field("latitude", .double, .required)
                    .field("longitude", .double, .required)
                    .field("creation_date", .datetime, .required)
                    .field("last_modification_date", .datetime, .required)
                    .field("ip_address", .string)
                    .field("A0", .bool)
                    .field("A1", .bool)
                    .field("A2", .bool)
                    .field("A3", .bool)
                    .field("A4", .bool)
                    .field("A5", .bool)
                    .field("A6", .bool)
                    .field("A7", .bool)
                    .field("A8", .bool)
                    .field("A9", .bool)
                    .field("A10", .bool)
                    .field("A11", .bool)
                    .field("A12", .bool)
                    .field("A13", .bool)
                    .field("A14", .bool)
                    .field("A15", .bool)
                    .field("I16", .bool)
                    .field("I17", .bool)
                    .field("I18", .bool)
                    .field("INT0", .bool)
                    .field("INT1", .bool)
                    .field("D0", .bool)
                    .field("D1", .bool)
                    .field("D2", .bool)
                    .field("D3", .bool)
                    .field("D4", .bool)
                    .field("D5", .bool)
                    .field("D6", .bool)
                    .field("D7", .bool)
                    .field("D8", .bool)
                    .field("D9", .bool)
                    .field("D10", .bool)
                    .field("D11", .bool)
                    .field("D12", .bool)
                    .field("D13", .bool)
                    .field("D14", .bool)
                    .field("D15", .bool)
                    .field("D16", .bool)
                    .field("D17", .bool)
                    .field("D18", .bool)
                    .field("D19", .bool)
                    .field("D20", .bool)
                    .field("D21", .bool)
                    .field("D22", .bool)
                    .field("D23", .bool)
                    .field("R0", .bool)
                    .field("R1", .bool)
                    .field("R2", .bool)
                    .field("R3", .bool)
                    .field("R4", .bool)
                    .field("R5", .bool)
                    .field("R6", .bool)
                    .field("R7", .bool)
                    .field("R8", .bool)
                    .field("R9", .bool)
                    .field("R10", .bool)
                    .field("R11", .bool)
                    .field("R12", .bool)
                    .field("R13", .bool)
                    .field("R14", .bool)
                    .field("R15", .bool)
                    .unique(on: "serial_number")
                    .create()
            }
    }
    
    // Delete DB
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Controllino.schema).delete()
    }
}
