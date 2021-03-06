//
//  AlarmsMigration.swift
//  
//
//  Created by Kevin Bertrand on 01/02/2021.
//

import Fluent
import Vapor

struct AlarmsMigration: Migration {
    // Create DB
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        return database.enum("type_of_verification")
            .case(TypeOfVerification.boolean.rawValue)
            .case(TypeOfVerification.twoPin.rawValue)
            .create()
            .flatMap { typeOfVerification in
                return database.enum("severity")
                    .case(Severity.information.rawValue)
                    .case(Severity.warning.rawValue)
                    .case(Severity.alert.rawValue)
                    .case(Severity.critical.rawValue)
                    .create()
                    .flatMap { severity in
                        return database.enum("operation_verification")
                            .case(OperationVerification.different.rawValue)
                            .case(OperationVerification.equal.rawValue)
                            .create()
                            .flatMap { operationVerification in
                                return database.enum("state")
                                    .case(AlarmState.activate.rawValue)
                                    .case(AlarmState.disactivate.rawValue)
                                    .case(AlarmState.inAlarm.rawValue)
                                    .case(AlarmState.acquitted.rawValue)
                                    .create()
                                    .flatMap { state in
                                        return database.schema(Alarms.schema)
                                            .id()
                                            .field("controllino_id", .string, .required, .references(Controllino.schema, "serial_number"))
                                            .field("pin_to_verify", .string, .required)
                                            .field("type_of_verification", typeOfVerification, .required)
                                            .field("operation", operationVerification, .required)
                                            .field("pin_state", .bool)
                                            .field("second_pin", .string)
                                            .field("expression", .string, .required)
                                            .field("severity", severity, .required)
                                            .field("inhibits_all_alarms", .bool, .required)
                                            .field("state", state, .required)
                                            .field("activationDate", .datetime)
                                            .field("isInAlarmDate", .datetime)
                                            .field("is_acquitted_date", .datetime)
                                            .field("lastVerification", .datetime)
                                            .field("detectionDate", .datetime)
                                            .field("time_between_two_verifications", .int, .required)
                                            .field("time_between_detection_and_notification", .int, .required)
                                            .unique(on: "expression")
                                            .create()
                                    }
                            }
                    }
            }
    }
    
    // Delete DB
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Alarms.schema).delete()
    }
}

