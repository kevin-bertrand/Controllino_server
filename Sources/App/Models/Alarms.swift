//
//  Alarms.swift
//  
//
//  Created by Kevin Bertrand on 01/02/2021.
//

import Fluent
import Vapor

final class Alarms: Model, Content {
    static let schema: String = "alarms"
    
    // General infos
    @ID(key: .id)
    var id: UUID?
    
    // Controllino infos
    @Parent(key: "controllino_id")
    var controllino: Controllino
    
    @Field(key: "pin_to_verify")
    var pinToVerify: String
    
    @Field(key: "type_of_verification")
    var typeOfVerification: TypeOfVerification
    
    @Field(key: "operation")
    var operation: OperationVerification
    
    @OptionalField(key: "pin_state")
    var pinState: Bool?
    
    @OptionalField(key: "second_pin")
    var secondPin: String?
    
    @Field(key: "expression")
    var expression: String
        
    @Field(key: "severity")
    var severity: Severity
    
    @Field(key: "inhibits_all_alarms")
    var inhibitsAllAlarms: Bool
    
    @Field(key: "isActive")
    var isActive: Bool
    
    @Field(key: "isInAlarm")
    var isInAlarm: Bool
    
    @Field(key: "isAccepted")
    var isAccepted: Bool
    
    @OptionalField(key: "isInAlarmDate")
    var isInAlarmDate: Date?
        
    @OptionalField(key: "isAcceptedDate")
    var isAcceptedDate: Date?
    
    @OptionalField(key: "lastVerification")
    var lastVerification: Date?
    
    @OptionalField(key: "detectionDate")
    var detectionDate: Date?
    
    // Inititalization functions
    init() { }
    
    init(id: UUID? = nil, controllinoId: Controllino.IDValue, pinToVerify: String, typeOfVerification: TypeOfVerification, operation: OperationVerification, secondPin: String? = nil, pinState: Bool? = nil, severity: Severity, inhibitsAllAlarms: Bool) {
        self.id = id
        self.$controllino.id = controllinoId
        self.pinToVerify = pinToVerify
        self.typeOfVerification = typeOfVerification
        self.operation = operation
        self.expression = self.pinToVerify
        
        switch operation {
        case .different:
            self.expression += " != "
        case .equal:
            self.expression += " == "
        }
        
        switch self.typeOfVerification {
        case .boolean:
            self.pinState = pinState
            self.expression += String(self.pinState!)
        case .twoPin:
            self.secondPin = secondPin
            self.expression += self.secondPin!
        }
        
        self.severity = severity
        self.inhibitsAllAlarms = inhibitsAllAlarms
        self.isActive = true
        self.isInAlarm = false
        self.isAccepted = false
    }
}

enum OperationVerification: String, Codable {
    case equal
    case different
}

enum TypeOfVerification: String, Codable {
    case twoPin
    case boolean
}

enum Severity: String, Codable {
    case information
    case warning
    case alert
    case critical
}
