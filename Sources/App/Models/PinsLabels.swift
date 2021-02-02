//
//  PinsLabels.swift
//  
//
//  Created by Kevin Bertrand on 02/02/2021.
//

import Fluent
import Vapor

final class PinsLabels: Model, Content {
    static let schema: String = "pins_labels"
    
    // General infos
    @ID(key: .id)
    var id: UUID?
    
    // Controllino infos
    @Parent(key: "controllino_id")
    var controllino: Controllino
    
    // Inputs labels
    @OptionalField(key: "LabelA0")
    var labelA0: String?
    
    @OptionalField(key: "LabelA1")
    var labelA1: String?
    
    @OptionalField(key: "LabelA2")
    var labelA2: String?
    
    @OptionalField(key: "LabelA3")
    var labelA3: String?
    
    @OptionalField(key: "LabelA4")
    var labelA4: String?

    @OptionalField(key: "LabelA5")
    var labelA5: String?
    
    @OptionalField(key: "LabelA6")
    var labelA6: String?
    
    @OptionalField(key: "LabelA7")
    var labelA7: String?
    
    @OptionalField(key: "LabelA8")
    var labelA8: String?
    
    @OptionalField(key: "LabelA9")
    var labelA9: String?
    
    @OptionalField(key: "LabelA10")
    var labelA10: String?
    
    @OptionalField(key: "LabelA11")
    var labelA11: String?
    
    @OptionalField(key: "LabelA12")
    var labelA12: String?
    
    @OptionalField(key: "LabelA13")
    var labelA13: String?
    
    @OptionalField(key: "LabelA14")
    var labelA14: String?
    
    @OptionalField(key: "LabelA15")
    var labelA15: String?
    
    @OptionalField(key: "LabelI16")
    var labelI16: String?
    
    @OptionalField(key: "LabelI17")
    var labelI17: String?
    
    @OptionalField(key: "LabelI18")
    var labelI18: String?
    
    @OptionalField(key: "LabelInt0")
    var labelInt0: String?
    
    @OptionalField(key: "LabelInt1")
    var labelInt1: String?
    
    // Digital output labels
    @OptionalField(key: "LabelD0")
    var labelD0: String?
    
    @OptionalField(key: "LabelD1")
    var labelD1: String?
    
    @OptionalField(key: "LabelD2")
    var labelD2: String?
    
    @OptionalField(key: "LabelD3")
    var labelD3: String?
    
    @OptionalField(key: "LabelD4")
    var labelD4: String?
    
    @OptionalField(key: "LabelD5")
    var labelD5: String?
    
    @OptionalField(key: "LabelD6")
    var labelD6: String?
    
    @OptionalField(key: "LabelD7")
    var labelD7: String?
    
    @OptionalField(key: "LabelD8")
    var labelD8: String?
    
    @OptionalField(key: "LabelD9")
    var labelD9: String?
    
    @OptionalField(key: "LabelD10")
    var labelD10: String?
    
    @OptionalField(key: "LabelD11")
    var labelD11: String?

    @OptionalField(key: "LabelD12")
    var labelD12: String?
    
    @OptionalField(key: "LabelD13")
    var labelD13: String?
    
    @OptionalField(key: "LabelD14")
    var labelD14: String?
    
    @OptionalField(key: "LabelD15")
    var labelD15: String?
    
    @OptionalField(key: "LabelD16")
    var labelD16: String?
    
    @OptionalField(key: "LabelD17")
    var labelD17: String?
    
    @OptionalField(key: "LabelD18")
    var labelD18: String?
    
    @OptionalField(key: "LabelD19")
    var labelD19: String?
    
    @OptionalField(key: "LabelD20")
    var labelD20: String?
    
    @OptionalField(key: "LabelD21")
    var labelD21: String?
    
    @OptionalField(key: "LabelD22")
    var labelD22: String?
    
    @OptionalField(key: "LabelD23")
    var labelD23: String?
    
    // Relay labels
    @OptionalField(key: "LabelR0")
    var labelR0: String?
    
    @OptionalField(key: "LabelR1")
    var labelR1: String?
    
    @OptionalField(key: "LabelR2")
    var labelR2: String?
    
    @OptionalField(key: "LabelR3")
    var labelR3: String?
    
    @OptionalField(key: "LabelR4")
    var labelR4: String?
    
    @OptionalField(key: "LabelR5")
    var labelR5: String?
    
    @OptionalField(key: "LabelR6")
    var labelR6: String?
    
    @OptionalField(key: "LabelR7")
    var labelR7: String?
    
    @OptionalField(key: "LabelR8")
    var labelR8: String?
    
    @OptionalField(key: "LabelR9")
    var labelR9: String?
    
    @OptionalField(key: "LabelR10")
    var labelR10: String?
    
    @OptionalField(key: "LabelR11")
    var labelR11: String?
    
    @OptionalField(key: "LabelR12")
    var labelR12: String?
    
    @OptionalField(key: "LabelR13")
    var labelR13: String?
    
    @OptionalField(key: "LabelR14")
    var labelR14: String?
    
    @OptionalField(key: "LabelR15")
    var labelR15: String?
    
    // Inititalization functions
    init() { }
    
    init(id: UUID? = nil, controllinoId: Controllino.IDValue) {
        self.id = id
        self.$controllino.id = controllinoId
    }
}

