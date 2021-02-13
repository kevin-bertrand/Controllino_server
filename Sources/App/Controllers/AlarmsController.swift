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
    
    /*
     Private functions
     */
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
}

extension Alarms {
    struct Create: Content {
        let serialNumber: String
        let expression: String
        let severity: String
        let inhibitsAllAlarms: Bool
    }
    
    struct UpdateActivation: Content {
        let id: UUID
        let state: Bool
    }
}
