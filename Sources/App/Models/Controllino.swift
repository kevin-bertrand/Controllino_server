//
//  Controllino.swift
//  
//
//  Created by Kevin Bertrand on 01/02/2021.
//

import Fluent
import Vapor

final class Controllino: Model, Content {
    static let schema: String = "controllino"
    
    // Controllino infos
    @ID(custom: "serial_number", generatedBy: .user)
    var id: String?
    
    @Field(key: "creation_date")
    var creationDate: Date
    
    @Field(key: "last_modification_date")
    var lastModificationDate: Date
    
    @Field(key: "tyoe")
    var type: ControllinoType
    
    @Field(key: "latitude")
    var latitude: Double
    
    @Field(key: "longitude")
    var longitude: Double
    
    @OptionalField(key: "ip_address")
    var ipAddress: String?
    
    // Inputs
    @Field(key: "A0")
    var a0: Bool
    
    @Field(key: "A1")
    var a1: Bool
    
    @Field(key: "A2")
    var a2: Bool
    
    @Field(key: "A3")
    var a3: Bool
    
    @Field(key: "A4")
    var a4: Bool
    
    @Field(key: "A5")
    var a5: Bool
    
    @Field(key: "A6")
    var a6: Bool
    
    @Field(key: "A7")
    var a7: Bool
    
    @Field(key: "A8")
    var a8: Bool
    
    @Field(key: "A9")
    var a9: Bool
    
    @OptionalField(key: "A10")
    var a10: Bool?
    
    @OptionalField(key: "A11")
    var a11: Bool?
    
    @OptionalField(key: "A12")
    var a12: Bool?
    
    @OptionalField(key: "A13")
    var a13: Bool?
    
    @OptionalField(key: "A14")
    var a14: Bool?
    
    @OptionalField(key: "A15")
    var a15: Bool?
    
    @OptionalField(key: "I16")
    var i16: Bool?
    
    @OptionalField(key: "I17")
    var i17: Bool?
    
    @OptionalField(key: "I18")
    var i18: Bool?
    
    @Field(key: "INT0")
    var int0: Bool
    
    @Field(key: "INT1")
    var int1: Bool
    
    // Outputs
    @Field(key: "D0")
    var d0: Bool
    
    @Field(key: "D1")
    var d1: Bool
    
    @Field(key: "D2")
    var d2: Bool
    
    @Field(key: "D3")
    var d3: Bool
    
    @Field(key: "D4")
    var d4: Bool
    
    @Field(key: "D5")
    var d5: Bool
    
    @Field(key: "D6")
    var d6: Bool
    
    @Field(key: "D7")
    var d7: Bool
    
    @Field(key: "D8")
    var d8: Bool
    
    @Field(key: "D9")
    var d9: Bool
    
    @Field(key: "D10")
    var d10: Bool
    
    @Field(key: "D11")
    var d11: Bool
    
    @OptionalField(key: "D12")
    var d12: Bool?
    
    @OptionalField(key: "D13")
    var d13: Bool?
    
    @OptionalField(key: "D14")
    var d14: Bool?
    
    @OptionalField(key: "D15")
    var d15: Bool?

    @OptionalField(key: "D16")
    var d16: Bool?
    
    @OptionalField(key: "D17")
    var d17: Bool?
    
    @OptionalField(key: "D18")
    var d18: Bool?
    
    @OptionalField(key: "D19")
    var d19: Bool?
    
    @OptionalField(key: "D20")
    var d20: Bool?
    
    @OptionalField(key: "D21")
    var d21: Bool?
    
    @OptionalField(key: "D22")
    var d22: Bool?
    
    @OptionalField(key: "D23")
    var d23: Bool?
    
    // Relays
    @Field(key: "R0")
    var r0: Bool
    
    @Field(key: "R1")
    var r1: Bool
    
    @Field(key: "R2")
    var r2: Bool
    
    @Field(key: "R3")
    var r3: Bool
    
    @Field(key: "R4")
    var r4: Bool
    
    @Field(key: "R5")
    var r5: Bool
    
    @Field(key: "R6")
    var r6: Bool
    
    @Field(key: "R7")
    var r7: Bool
    
    @Field(key: "R8")
    var r8: Bool
    
    @Field(key: "R9")
    var r9: Bool
    
    @OptionalField(key: "R10")
    var r10: Bool?
    
    @OptionalField(key: "R11")
    var r11: Bool?
    
    @OptionalField(key: "R12")
    var r12: Bool?
    
    @OptionalField(key: "R13")
    var r13: Bool?
    
    @OptionalField(key: "R14")
    var r14: Bool?
    
    @OptionalField(key: "R15")
    var r15: Bool?
    
    // Initialization functions
    init() {}
    
    init(id: String, type: ControllinoType, latitude: Double? = 0.0, longitude: Double? = 0.0, ipAddress: String? = nil) {
        self.id = id
        self.type = type
        self.latitude = latitude!
        self.longitude = longitude!
        self.ipAddress = ipAddress
        self.creationDate = Date.init()
        self.lastModificationDate = self.creationDate
        
        // Input fields initialization
        a0 = false
        a1 = false
        a2 = false
        a3 = false
        a4 = false
        a5 = false
        a6 = false
        a7 = false
        a8 = false
        a9 = false
        
        a10 = (self.type == .mega) ? false : nil
        a11 = (self.type == .mega) ? false : nil
        a12 = (self.type == .mega) ? false : nil
        a13 = (self.type == .mega) ? false : nil
        a14 = (self.type == .mega) ? false : nil
        a15 = (self.type == .mega) ? false : nil
        i16 = (self.type == .mega) ? false : nil
        i17 = (self.type == .mega) ? false : nil
        i18 = (self.type == .mega) ? false : nil
        
        int0 = false
        int1 = false
        
        // Output fields initialization
        d0 = false
        d1 = false
        d2 = false
        d3 = false
        d4 = false
        d5 = false
        d6 = false
        d7 = false
        d8 = false
        d9 = false
        d10 = false
        d11 = false
        
        d12 = (self.type == .mega) ? false : nil
        d13 = (self.type == .mega) ? false : nil
        d14 = (self.type == .mega) ? false : nil
        d15 = (self.type == .mega) ? false : nil
        d16 = (self.type == .mega) ? false : nil
        d17 = (self.type == .mega) ? false : nil
        d18 = (self.type == .mega) ? false : nil
        d19 = (self.type == .mega) ? false : nil
        d20 = (self.type == .mega) ? false : nil
        d21 = (self.type == .mega) ? false : nil
        d22 = (self.type == .mega) ? false : nil
        d23 = (self.type == .mega) ? false : nil
        
        // Relay fields initialization
        r0 = false
        r1 = false
        r2 = false
        r3 = false
        r4 = false
        r5 = false
        r6 = false
        r7 = false
        r8 = false
        r9 = false
        
        r10 = (self.type == .mega) ? false : nil
        r11 = (self.type == .mega) ? false : nil
        r12 = (self.type == .mega) ? false : nil
        r13 = (self.type == .mega) ? false : nil
        r14 = (self.type == .mega) ? false : nil
        r15 = (self.type == .mega) ? false : nil
    }
}

enum ControllinoType: String, Codable {
    case maxi
    case mega
}

extension Controllino {
    static let inputs = ["a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "a10", "a11", "a12", "a13", "a14", "a15", "i16", "i17", "i18", "int0", "int1"]
    static let outputs = ["d0", "d1", "d2", "d3", "d4", "d5", "d6", "d7", "d8", "d9", "d10", "d11", "d12", "d13", "d14", "d15", "d16", "d17", "d18", "d19", "d20", "d21", "d22", "d23"]
    static let relays = ["r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7", "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15"]
}
