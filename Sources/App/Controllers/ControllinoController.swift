//
//  ControllinoController.swift
//  
//
//  Created by Kevin Bertrand on 02/02/2021.
//

import Fluent
import FluentSQL
import Foundation
import Vapor

struct ControllinoController {
    /*
     Public functions for HTTP requests
     */
    func addControllino(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        
        // Try to decode received data
        let receivedData = try req.content.decode(Controllino.Create.self)
        let controllino = Controllino(id: receivedData.serialNumber, type: checkType(receivedData.type), latitude: receivedData.latitude, longitude: receivedData.longitude, ipAddress: receivedData.ipAddress)
        let labels = PinsLabels(controllinoId: controllino.id ?? "error")
        
        return Controllino.query(on: req.db)
            .first()
            .guard({ _ -> Bool in
                return userAuth.rights == .admin || userAuth.rights == .superAdmin || userAuth.rights == .user
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .flatMap { _ -> EventLoopFuture<HTTPStatus> in
                return controllino.save(on: req.db).transform(to: HttpStatus().send(status: .created))
            }.flatMap { _ -> EventLoopFuture<HTTPStatus> in
                return labels.save(on: req.db).transform(to: HttpStatus().send(status: .created))
            }
    }
    
    // Delete a list of users
    func deleteControllino(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        let receivedData = try req.content.decode(Controllino.Delete.self)
        var queryControllino = "DELETE FROM controllino WHERE "
        var queryLabels = "DELETE FROM pins_labels WHERE "
        var queryAlarms = "DELETE FROM alarms WHERE "
        var firstSerialNumber = true
        
        for serialNumber in receivedData.serialNumbers {
            if !firstSerialNumber {
                queryControllino += " OR "
                queryLabels += " OR "
                queryAlarms += " OR "
            }
            
            queryControllino += "serial_number == \"\(serialNumber)\""
            queryLabels += "controllino_id == \"\(serialNumber)\""
            queryAlarms += "controllino_id == \"\(serialNumber)\""
            firstSerialNumber = false
        }
        
        return performSqlQueries(inside: req, with: queryAlarms, by: userAuth)
            .flatMap { _ in
                return performSqlQueries(inside: req, with: queryLabels, by: userAuth)
                    .flatMap { _ in
                        return performSqlQueries(inside: req, with: queryControllino, by: userAuth)
                    }
            }
    }
    
    // Get all Controllinos in database
    func getControllinos(req: Request) throws -> EventLoopFuture<[Controllino.List]> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        
        return Controllino.query(on: req.db)
            .all()
            .guard({ _ -> Bool in
                return userAuth.rights == .user || userAuth.rights == .admin || userAuth.rights == .superAdmin
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .map { controllinos -> [Controllino.List] in
                var controllinoList: [Controllino.List] = []
                
                for controllino in controllinos {
                    controllinoList.append(Controllino.List(serialNumber: controllino.id!, type: controllino.type, latitude: controllino.latitude, longitude: controllino.longitude, ipAddress: controllino.ipAddress ?? "0.0.0.0"))
                }
                
                return controllinoList
            }
    }
    
    // Get a unique Controllinos from database
    func getUniqueControllino(req: Request) throws -> EventLoopFuture<Controllino> {
        let serialNumber = req.parameters.get("serialNumber")
        
        return Controllino.query(on: req.db)
            .filter(\.$id == serialNumber ?? "")
            .first()
            .guard({ controllino -> Bool in
                return controllino != nil
            }, else: Abort(HttpStatus().send(status: .wrongSerialNumber, with: serialNumber ?? "")))
            .map { controllino -> Controllino in
                return controllino!
            }
    }
    
    // Update localisation, type and serial number
    func updateControllino(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        let receivedData = try req.content.decode(Controllino.Update.self)
        let type = checkType(receivedData.type)
        var typeIsChanged = false
        
        return Controllino.query(on: req.db)
            .filter(\.$id == receivedData.serialNumber)
            .first()
            .guard({ controllino -> Bool in
                return controllino != nil
            }, else: Abort(HttpStatus().send(status: .wrongSerialNumber, with: receivedData.serialNumber)))
            .guard({ _ -> Bool in
                return userAuth.rights == .user || userAuth.rights == .admin || userAuth.rights == .superAdmin
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .flatMap { controllino -> EventLoopFuture<HTTPStatus> in
                if controllino!.type != type {
                    typeIsChanged = true
                }
                return updateControllinoInfos(controllino!, inside: req, with: receivedData, and: type)
                    .flatMap { status -> EventLoopFuture<HTTPStatus> in
                        if status != .ok {
                            return EventLoopFutureReturn().errorHttpStatus(on: req, withError: HttpStatus().send(status: .unableToReachDb))
                        }
                        if typeIsChanged {
                            return updateControllinoType(type, at: receivedData.serialNumber, inside: req, by: userAuth)
                        } else {
                            return EventLoopFutureReturn().errorHttpStatus(on: req, withError: .ok)
                        }
                    }
            }
    }
    
    /*
     Private functions
     */
    // This function check the type of the controllino. If the type is not correctly set, it will be set into Controllino Maxi
    private func checkType(_ type: String) -> ControllinoType {
        if type.lowercased() == "mega" {
            return .mega;
        } else {
            return .maxi;
        }
    }
    
    private func performSqlQueries(inside req: Request, with query: String, by user: User) -> EventLoopFuture<HTTPStatus> {
        if let sql = req.db as? SQLDatabase,
           user.rights == .superAdmin || user.rights == .admin || user.rights == .user {
            return sql.raw(SQLQueryString(query)).run().transform(to: .ok)
        } else {
            return EventLoopFutureReturn().errorHttpStatus(on: req, withError: HttpStatus().send(status: .unableToReachDb))
        }
    }
    
    private func updateControllinoInfos(_ controllino: Controllino, inside req: Request, with data: Controllino.Update, and type: ControllinoType) -> EventLoopFuture<HTTPStatus> {
        if let sql = req.db as? SQLDatabase {
            return sql.update("controllino")
                .set("latitude", to: data.latitude)
                .set("longitude", to: data.longitude)
                .set("serial_number", to: data.serialNumber)
                .set("type", to: type)
                .set("last_modification_date", to: Date.init())
                .where("serial_number", .equal, controllino.id)
                .run()
                .transform(to: .ok)
        } else {
            return EventLoopFutureReturn().errorHttpStatus(on: req, withError: HttpStatus().send(status: .unableToReachDb))
        }
    }
    
    private func updateControllinoType(_ type: ControllinoType, at id: String, inside req: Request, by user: User) -> EventLoopFuture<HTTPStatus> {
        var query = "UPDATE controllino "
        switch type {
        case .maxi:
            query += "SET A10 = NULL, "
            query += "A11 = NULL, "
            query += "A12 = NULL, "
            query += "A13 = NULL, "
            query += "A14 = NULL, "
            query += "A15 = NULL, "
            query += "I16 = NULL, "
            query += "I17 = NULL, "
            query += "I18 = NULL, "
            query += "D12 = NULL, "
            query += "D13 = NULL, "
            query += "D14 = NULL, "
            query += "D15 = NULL, "
            query += "D16 = NULL, "
            query += "D17 = NULL, "
            query += "D18 = NULL, "
            query += "D19 = NULL, "
            query += "D20 = NULL, "
            query += "D21 = NULL, "
            query += "D22 = NULL, "
            query += "D23 = NULL, "
            query += "R10 = NULL, "
            query += "R11 = NULL, "
            query += "R12 = NULL, "
            query += "R13 = NULL, "
            query += "R14 = NULL, "
            query += "R15 = NULL "
        case .mega:
            query += "SET A10 = false, "
            query += "A11 = false, "
            query += "A12 = false, "
            query += "A13 = false, "
            query += "A14 = false, "
            query += "A15 = false, "
            query += "I16 = false, "
            query += "I17 = false, "
            query += "I18 = false, "
            query += "D12 = false, "
            query += "D13 = false, "
            query += "D14 = false, "
            query += "D15 = false, "
            query += "D16 = false, "
            query += "D17 = false, "
            query += "D18 = false, "
            query += "D19 = false, "
            query += "D20 = false, "
            query += "D21 = false, "
            query += "D22 = false, "
            query += "D23 = false, "
            query += "R10 = false, "
            query += "R11 = false, "
            query += "R12 = false, "
            query += "R13 = false, "
            query += "R14 = false, "
            query += "R15 = false "
        }
        
        query += "WHERE serial_number == \"\(id)\""
        return performSqlQueries(inside: req, with: query, by: user)
    }
}

extension Controllino {
    struct Create: Content {
        let serialNumber: String
        let type: String
        let latitude: Double?
        let longitude: Double?
        let ipAddress: String?
    }
    
    struct Delete: Content {
        let serialNumbers: [String]
    }
    
    struct List: Content {
        let serialNumber: String
        let type: ControllinoType
        let latitude: Double
        let longitude: Double
        let ipAddress: String
    }
    
    struct Update: Content {
        let serialNumber: String
        let latitude: Double
        let longitude: Double
        let type: String
    }
}
