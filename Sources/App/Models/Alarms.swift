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
    
    @Field(key: "state")
    var state: AlarmState
    
    @Field(key: "time_between_two_verifications")
    var timeBetweenTwoVerifications: Int
    
    @Field(key: "time_between_detection_and_notification")
    var timeBetweenDetectionAndNotification: Int
    
    @OptionalField(key: "activationDate")
    var isActivateDate: Date?
    
    @OptionalField(key: "isInAlarmDate")
    var isInAlarmDate: Date?
        
    @OptionalField(key: "is_acquitted_date")
    var isAcquittedDate: Date?
    
    @OptionalField(key: "lastVerification")
    var lastVerification: Date?
    
    @OptionalField(key: "detectionDate")
    var detectionDate: Date?
    
    // Inititalization functions
    init() { }
    
    init(id: UUID? = nil, controllinoId: Controllino.IDValue, pinToVerify: String, typeOfVerification: TypeOfVerification, operation: OperationVerification, secondPin: String? = nil, pinState: Bool? = nil, severity: Severity, inhibitsAllAlarms: Bool, timeBetweenTwoVerifications: Int, timeBetweenDetectionAndNotification: Int) {
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
        self.state = .activate
        self.timeBetweenTwoVerifications = timeBetweenTwoVerifications
        self.timeBetweenDetectionAndNotification = timeBetweenDetectionAndNotification
        self.isActivateDate = Date.init()
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

enum AlarmState: String, Codable {
    case activate
    case disactivate
    case inAlarm
    case acquitted
}
