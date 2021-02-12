//
//  PinsLabelsController.swift
//  
//
//  Created by Kevin Bertrand on 12/02/2021.
//

import Fluent
import FluentSQL
import Foundation
import Vapor

struct PinsLabelsController {
    func getAllLabels(req: Request) throws -> EventLoopFuture<[PinsLabels]> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        
        return PinsLabels.query(on: req.db)
            .all()
            .guard({ _ -> Bool in
                userAuth.rights != .none && userAuth.rights != .controller
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
    }
}

extension PinsLabels {
    struct Labels: Content {
        let labelA0: String?
        let labelA1: String?
        let labelA2: String?
        let labelA3: String?
        let labelA4: String?
        let labelA5: String?
        let labelA6: String?
        let labelA7: String?
        let labelA8: String?
        let labelA9: String?
        let labelA10: String?
        let labelA11: String?
        let labelA12: String?
        let labelA13: String?
        let labelA14: String?
        let labelA15: String?
        let labelI16: String?
        let labelI17: String?
        let labelI18: String?
        let labelInt0: String?
        let labelInt1: String?
        
        let labelD0: String?
        let labelD1: String?
        let labelD2: String?
        let labelD3: String?
        let labelD4: String?
        let labelD5: String?
        let labelD6: String?
        let labelD7: String?
        let labelD8: String?
        let labelD9: String?
        let labelD10: String?
        let labelD11: String?
        let labelD12: String?
        let labelD13: String?
        let labelD14: String?
        let labelD15: String?
        let labelD16: String?
        let labelD17: String?
        let labelD18: String?
        let labelD19: String?
        let labelD20: String?
        let labelD21: String?
        let labelD22: String?
        let labelD23: String?
        
        let labelR0: String?
        let labelR1: String?
        let labelR2: String?
        let labelR3: String?
        let labelR4: String?
        let labelR5: String?
        let labelR6: String?
        let labelR7: String?
        let labelR8: String?
        let labelR9: String?
        let labelR10: String?
        let labelR11: String?
        let labelR12: String?
        let labelR13: String?
        let labelR14: String?
        let labelR15: String?
    }
}
