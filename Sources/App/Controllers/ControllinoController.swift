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
        print("ok")
        
        return performSqlQueries(inside: req, with: queryAlarms, by: userAuth)
            .flatMap { _ in
                return performSqlQueries(inside: req, with: queryLabels, by: userAuth)
                    .flatMap { _ in
                        return performSqlQueries(inside: req, with: queryControllino, by: userAuth)
                    }
            }
    }
    
    // Get all user in database
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
}
