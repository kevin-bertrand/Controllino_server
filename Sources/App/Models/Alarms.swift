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
    
    @OptionalField(key: "pin_state")
    var pinState: Bool?
    
    @OptionalField(key: "second_pin")
    var secondPin: String?
        
    @Field(key: "severity")
    var severity: String
    
    @Field(key: "isActive")
    var isActive: Bool
    
    @Field(key: "isInAlarm")
    var isInAlarm: Bool
    
    @Field(key: "isAccepted")
    var isAccepted: Bool
    
    @Field(key: "isInAlarmDate")
    var isInAlarmDate: Date?
        
    @Field(key: "isAcceptedDate")
    var isAcceptedDate: Date?
    
    @Field(key: "lastVerification")
    var lastVerification: Date?
    
    @Field(key: "detectionDate")
    var detectionDate: Date?
    
    // Inititalization functions
    init() { }
    
    init(id: UUID? = nil, controllinoId: Controllino.IDValue, pinToVerify: String, typeOfVerification: TypeOfVerification, secondPin: String? = nil, pinState: Bool? = nil) {
        self.id = id
        self.$controllino.id = controllinoId
        self.pinToVerify = pinToVerify
        self.typeOfVerification = typeOfVerification
        
        switch self.typeOfVerification {
        case .boolean:
            self.pinState = pinState
            self.secondPin = nil
        case .twoPin:
            self.secondPin = secondPin
            self.pinState = nil
        }
        
        self.isActive = true
        self.isInAlarm = false
        self.isAccepted = false
        self.isInAlarmDate = nil
        self.isAcceptedDate = nil
        self.lastVerification = nil
        self.detectionDate = nil
    }
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
