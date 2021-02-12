//
//  PinsLabelsMigration.swift
//  
//
//  Created by Kevin Bertrand on 02/02/2021.
//

import Fluent
import Vapor

struct PinsLabelsMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PinsLabels.schema)
            .id()
            .field("controllino_id", .string, .required, .references(Controllino.schema, "serial_number"))
            .field("LabelA0", .string)
            .field("LabelA1", .string)
            .field("LabelA2", .string)
            .field("LabelA3", .string)
            .field("LabelA4", .string)
            .field("LabelA5", .string)
            .field("LabelA6", .string)
            .field("LabelA7", .string)
            .field("LabelA8", .string)
            .field("LabelA9", .string)
            .field("LabelA10", .string)
            .field("LabelA11", .string)
            .field("LabelA12", .string)
            .field("LabelA13", .string)
            .field("LabelA14", .string)
            .field("LabelA15", .string)
            .field("LabelI16", .string)
            .field("LabelI17", .string)
            .field("LabelI18", .string)
            .field("LabelInt0", .string)
            .field("LabelInt1", .string)
            .field("LabelD0", .string)
            .field("LabelD1", .string)
            .field("LabelD2", .string)
            .field("LabelD3", .string)
            .field("LabelD4", .string)
            .field("LabelD5", .string)
            .field("LabelD6", .string)
            .field("LabelD7", .string)
            .field("LabelD8", .string)
            .field("LabelD9", .string)
            .field("LabelD10", .string)
            .field("LabelD11", .string)
            .field("LabelD12", .string)
            .field("LabelD13", .string)
            .field("LabelD14", .string)
            .field("LabelD15", .string)
            .field("LabelD16", .string)
            .field("LabelD17", .string)
            .field("LabelD18", .string)
            .field("LabelD19", .string)
            .field("LabelD20", .string)
            .field("LabelD21", .string)
            .field("LabelD22", .string)
            .field("LabelD23", .string)
            .field("LabelR0", .string)
            .field("LabelR1", .string)
            .field("LabelR2", .string)
            .field("LabelR3", .string)
            .field("LabelR4", .string)
            .field("LabelR5", .string)
            .field("LabelR6", .string)
            .field("LabelR7", .string)
            .field("LabelR8", .string)
            .field("LabelR9", .string)
            .field("LabelR10", .string)
            .field("LabelR11", .string)
            .field("LabelR12", .string)
            .field("LabelR13", .string)
            .field("LabelR14", .string)
            .field("LabelR15", .string)
            .unique(on: "controllino_id")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PinsLabels.schema).delete()
    }
}
