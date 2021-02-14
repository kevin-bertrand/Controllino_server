//
//  AlarmsController.swift
//  
//
//  Created by Kevin Bertrand on 12/02/2021.
//

import Fluent
import FluentSQL
import Foundation
import Vapor

struct AlarmsController {
    /*
     Public functions for HTTP requests
     */
    func addAlarms(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let userAuth = try req.auth.require(User.self)
        let receivedData = try req.content.decode(Alarms.Create.self)
        let expression = split(expression: receivedData.expression)
        
        return Alarms.query(on: req.db)
            .filter(\.$expression == receivedData.expression)
            .first()
            .guard({ _ -> Bool in
                return userAuth.rights == .admin || userAuth.rights == .user || userAuth.rights == .superAdmin
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .guard({ _ -> Bool in
                return expression.count == 3
            }, else: Abort(HttpStatus().send(status: .expressionIsNotValid, with: receivedData.expression)))
            .guard({ _ -> Bool in
                return checkOperation(expression[1]) != nil
            }, else: Abort(HttpStatus().send(status: .expressionIsNotValid, with: receivedData.expression)))
            .guard({ _ -> Bool in
                return checkSeverity(receivedData.severity) != nil
            }, else: Abort(HttpStatus().send(status: .expressionIsNotValid, with: receivedData.expression)))
            .guard({ _ -> Bool in
                return checkTypeOfVerification(expression[2]) != nil
            }, else: Abort(HttpStatus().send(status: .expressionIsNotValid, with: receivedData.expression)))
            .flatMap { alarm -> EventLoopFuture<HTTPStatus> in
                let typeOfVerification = checkTypeOfVerification(expression[2])!
                let newAlarm = Alarms(controllinoId: receivedData.serialNumber,
                                      pinToVerify: expression[0],
                                      typeOfVerification: typeOfVerification,
                                      operation: checkOperation(expression[1])!,
                                      secondPin: typeOfVerification == .boolean ? nil : expression[2],
                                      pinState: typeOfVerification == .twoPin ? nil : Bool(expression[2].lowercased()),
                                      severity: checkSeverity(receivedData.severity)!,
                                      inhibitsAllAlarms: receivedData.inhibitsAllAlarms)
                return newAlarm.save(on: req.db).transform(to: HttpStatus().send(status: .ok))
            }
    }
    
    func getAllAlarms(req: Request) throws -> EventLoopFuture<[Alarms]> {
        let userAuth = try req.auth.require(User.self)

        return Alarms.query(on: req.db)
            .sort(\.$controllino.$id)
            .sort(\.$isInAlarm, .descending)
            .all()
            .guard({ _ -> Bool in
                return userAuth.rights != .none && userAuth.rights != .controller
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .map { alarms -> [Alarms] in
                return alarms
            }
    }
    
    func getAlarmsForOneController(req: Request) throws -> EventLoopFuture<[Alarms]> {
        let userAuth = try req.auth.require(User.self)
        let serialNumber = req.parameters.get("serialNumber")
        
        return Alarms.query(on: req.db)
            .filter(\.$controllino.$id == serialNumber ?? "")
            .all()
            .guard({ _ -> Bool in
                return userAuth.rights != .none && userAuth.rights != .controller
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .map { alarms -> [Alarms] in
                return alarms
            }
    }
    
    func getAlarm(req: Request) throws -> EventLoopFuture<Alarms> {
        let userAuth = try req.auth.require(User.self)
        let id = req.parameters.get("id")
        
        return Alarms.query(on: req.db)
            .filter(\.$id == UUID(uuidString: id ?? "") ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
            .first()
            .guard({ _ -> Bool in
                return userAuth.rights != .none && userAuth.rights != .controller
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .guard({ alarm -> Bool in
                return alarm != nil
            }, else: Abort(HttpStatus().send(status: .alarmDoesntExist, with: id ?? "")))
            .map { alarm -> Alarms in
                return alarm!
            }
    }
    
    func deleteAlarm(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let userAuth = try req.auth.require(User.self)
        let receivedData = try req.content.decode(Alarms.Delete.self)
        var query = "DELETE FROM \(Alarms.schema) WHERE "
        var firstId = true
        
        for id in receivedData.ids {
            if !firstId {
                query += " OR "
            }
            
            query += "id == \"\(id)\""
            firstId = false
        }
        
        return performSqlQueries(inside: req, with: query, by: userAuth)
    }
    
    func switchOffOnAlarm(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let userAuth = try req.auth.require(User.self)
        let receivedData = try req.content.decode(Alarms.UpdateActivation.self)
        
        return Alarms.query(on: req.db)
            .filter(\.$id == UUID(uuidString: receivedData.id) ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
            .first()
            .guard({ _ -> Bool in
                return userAuth.rights == .admin || userAuth.rights == .user || userAuth.rights == .superAdmin
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .guard({ alarm -> Bool in
                return alarm != nil
            }, else: Abort(HttpStatus().send(status: .alarmDoesntExist, with: receivedData.id)))
            .guard({ _ -> Bool in
                return checkSqlDB(of: req)
            }, else: Abort(HttpStatus().send(status: .unableToReachDb)))
            .flatMap { Alarms -> EventLoopFuture<HTTPStatus> in
                var date: Date?
                
                if receivedData.state {
                    date = Date.init()
                } else {
                    date = nil
                }
                
                return updateActivation(of: UUID(uuidString: receivedData.id)!, to: receivedData.state, inside: getSqlDB(of: req), at: date)
            }
    }
    
    /*
     Private functions
     */
    private func checkSqlDB(of req: Request) -> Bool {
        return req.db is SQLDatabase
    }
    
    private func getSqlDB(of req: Request) -> SQLDatabase {
        return req.db as! SQLDatabase
    }
    
    private func updateActivation(of alarm: UUID, to state: Bool, inside sql: SQLDatabase, at date: Date?) -> EventLoopFuture<HTTPStatus> {
        return sql.update(Alarms.schema)
            .set("isActive", to: state)
            .set("activationDate", to: date)
            .where("id", .equal, alarm)
            .run()
            .transform(to: .ok)
    }
    
    private func split(expression: String) -> [String] {
        return expression.components(separatedBy: " ")
    }
    
    private func checkTypeOfVerification(_ expression: String) -> TypeOfVerification? {
        if expression.lowercased() == "false" || expression.lowercased() == "true" {
            return .boolean
        }
        
        for pin in Controllino.pinsList {
            if pin.lowercased() == expression.lowercased() {
                return .twoPin
            }
        }
        
        return nil
    }
    
    private func checkOperation(_ operation: String) -> OperationVerification? {
        switch operation {
        case "==":
            return .equal
        case "!=":
            return .different
        default:
            return nil
        }
    }
    
    private func checkSeverity(_ severity: String) -> Severity? {
        switch severity {
        case "information":
            return .information
        case "warning":
            return .warning
        case "alert":
            return .alert
        case "critical":
            return .critical
        default:
            return nil
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

extension Alarms {
    struct Create: Content {
        let serialNumber: String
        let expression: String
        let severity: String
        let inhibitsAllAlarms: Bool
    }
    
    struct UpdateActivation: Content {
        let id: String
        let state: Bool
    }
    
    struct Delete: Content {
        let ids: [String]
    }
}
