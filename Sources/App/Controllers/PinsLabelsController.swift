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
    /*
     Public functions for HTTP requests
     */
    func getAllLabels(req: Request) throws -> EventLoopFuture<[PinsLabels]> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        
        return PinsLabels.query(on: req.db)
            .all()
            .guard({ _ -> Bool in
                userAuth.rights != .none && userAuth.rights != .controller
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
    }
    
    func getOneControllerLabels(req: Request) throws -> EventLoopFuture<PinsLabels> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        let serialNumber = req.parameters.get("serialNumber")
        
        return PinsLabels.query(on: req.db)
            .filter(\.$controllino.$id == serialNumber ?? "")
            .first()
            .guard({ _ -> Bool in
                return userAuth.rights != .none && userAuth.rights != .controller
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .guard({ labels -> Bool in
                return labels != nil
            }, else: Abort(HttpStatus().send(status: .wrongSerialNumber, with: serialNumber ?? "")))
            .map { labels -> PinsLabels in
                return labels!
            }
    }
    
    // Modify labels for one Controllino
    func modifyLabels(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        
        // Try to decode received data
        let receivedData = try req.content.decode(PinsLabels.Modify.self)
        
        return PinsLabels.query(on: req.db)
            .filter(\.$controllino.$id == receivedData.serialNumber)
            .first()
            .guard({ _ -> Bool in
                return userAuth.rights == .admin || userAuth.rights == .user || userAuth.rights == .superAdmin
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .guard({ pinsLabels -> Bool in
                return pinsLabels != nil
            }, else: Abort(HttpStatus().send(status: .wrongSerialNumber, with: receivedData.serialNumber)))
            .guard({ _ -> Bool in
                return checkSqlDB(of: req)
            }, else: Abort(HttpStatus().send(status: .unableToReachDb)))
            .flatMap { controllinoLabel -> EventLoopFuture<HTTPStatus> in
                return updateLabels(inside: getSqlDB(of: req), with: receivedData)
            }
    }
    
    /*
     Private functions
     */
    // This function checks if the DB of the request is an SQL DB
    private func checkSqlDB(of req: Request) -> Bool {
        return req.db is SQLDatabase
    }
    
    private func getSqlDB(of req: Request) -> SQLDatabase {
        return req.db as! SQLDatabase
    }
    
    private func updateLabels(inside sql: SQLDatabase, with data: PinsLabels.Modify) -> EventLoopFuture<HTTPStatus> {
        return sql.update(PinsLabels.schema)
            .set("LabelA0", to: data.labels.labelA0)
            .set("LabelA1", to: data.labels.labelA1)
            .set("LabelA2", to: data.labels.labelA2)
            .set("LabelA3", to: data.labels.labelA3)
            .set("LabelA4", to: data.labels.labelA4)
            .set("LabelA5", to: data.labels.labelA5)
            .set("LabelA6", to: data.labels.labelA6)
            .set("LabelA7", to: data.labels.labelA7)
            .set("LabelA8", to: data.labels.labelA8)
            .set("LabelA9", to: data.labels.labelA9)
            .set("LabelA10", to: data.labels.labelA10)
            .set("LabelA11", to: data.labels.labelA11)
            .set("LabelA12", to: data.labels.labelA12)
            .set("LabelA13", to: data.labels.labelA13)
            .set("LabelA14", to: data.labels.labelA14)
            .set("LabelA15", to: data.labels.labelA15)
            .set("LabelI16", to: data.labels.labelI16)
            .set("LabelI17", to: data.labels.labelI17)
            .set("LabelI18", to: data.labels.labelI18)
            .set("LabelInt0", to: data.labels.labelInt0)
            .set("LabelInt1", to: data.labels.labelInt1)
            .set("LabelD0", to: data.labels.labelD0)
            .set("LabelD1", to: data.labels.labelD1)
            .set("LabelD2", to: data.labels.labelD2)
            .set("LabelD3", to: data.labels.labelD3)
            .set("LabelD4", to: data.labels.labelD4)
            .set("LabelD5", to: data.labels.labelD5)
            .set("LabelD6", to: data.labels.labelD6)
            .set("LabelD7", to: data.labels.labelD7)
            .set("LabelD8", to: data.labels.labelD8)
            .set("LabelD9", to: data.labels.labelD9)
            .set("LabelD10", to: data.labels.labelD10)
            .set("LabelD11", to: data.labels.labelD11)
            .set("LabelD12", to: data.labels.labelD12)
            .set("LabelD13", to: data.labels.labelD13)
            .set("LabelD14", to: data.labels.labelD14)
            .set("LabelD15", to: data.labels.labelD15)
            .set("LabelD16", to: data.labels.labelD16)
            .set("LabelD17", to: data.labels.labelD17)
            .set("LabelD18", to: data.labels.labelD18)
            .set("LabelD19", to: data.labels.labelD19)
            .set("LabelD20", to: data.labels.labelD20)
            .set("LabelD21", to: data.labels.labelD21)
            .set("LabelD22", to: data.labels.labelD22)
            .set("LabelD23", to: data.labels.labelD23)
            .set("LabelR0", to: data.labels.labelR0)
            .set("LabelR1", to: data.labels.labelR1)
            .set("LabelR2", to: data.labels.labelR2)
            .set("LabelR3", to: data.labels.labelR3)
            .set("LabelR4", to: data.labels.labelR4)
            .set("LabelR5", to: data.labels.labelR5)
            .set("LabelR6", to: data.labels.labelR6)
            .set("LabelR7", to: data.labels.labelR7)
            .set("LabelR8", to: data.labels.labelR8)
            .set("LabelR9", to: data.labels.labelR9)
            .set("LabelR10", to: data.labels.labelR10)
            .set("LabelR11", to: data.labels.labelR11)
            .set("LabelR12", to: data.labels.labelR12)
            .set("LabelR13", to: data.labels.labelR13)
            .set("LabelR14", to: data.labels.labelR14)
            .set("LabelR15", to: data.labels.labelR15)
            .where("controllino_id", .equal, data.serialNumber)
            .run()
            .transform(to: .ok)
    }
}

extension PinsLabels {
    struct Modify: Content {
        let serialNumber: Controllino.IDValue
        var labels: PinsLabels.Labels
    }
    
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
        var labelA10: String?
        var labelA11: String?
        var labelA12: String?
        var labelA13: String?
        var labelA14: String?
        var labelA15: String?
        var labelI16: String?
        var labelI17: String?
        var labelI18: String?
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
        var labelD12: String?
        var labelD13: String?
        var labelD14: String?
        var labelD15: String?
        var labelD16: String?
        var labelD17: String?
        var labelD18: String?
        var labelD19: String?
        var labelD20: String?
        var labelD21: String?
        var labelD22: String?
        var labelD23: String?
        
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
        var labelR10: String?
        var labelR11: String?
        var labelR12: String?
        var labelR13: String?
        var labelR14: String?
        var labelR15: String?
    }
}
