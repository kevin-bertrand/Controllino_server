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
        let controllino = Controllino(id: receivedData.serialNumber,
                                      type: checkType(receivedData.type),
                                      latitude: receivedData.latitude,
                                      longitude: receivedData.longitude,
                                      ipAddress: receivedData.ipAddress)
        let labels = PinsLabels(controllinoId: controllino.id ?? "error")
        
        return Controllino.query(on: req.db)
            .first()
            .guard({ _ -> Bool in
                return userAuth.rights == .admin || userAuth.rights == .superAdmin || userAuth.rights == .user
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .flatMap { _ -> EventLoopFuture<HTTPStatus> in
                return controllino.save(on: req.db)
                    .transform(to: HttpStatus().send(status: .created))
            }.flatMap { _ -> EventLoopFuture<HTTPStatus> in
                return labels.save(on: req.db)
                    .transform(to: HttpStatus().send(status: .created))
            }
    }
    
    // Delete a list of users
    func deleteControllino(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        let receivedData = try req.content.decode(Controllino.Delete.self)
        var queryControllino = "DELETE FROM \(Controllino.schema) WHERE "
        var queryLabels = "DELETE FROM \(PinsLabels.schema) WHERE "
        var queryAlarms = "DELETE FROM \(Alarms.schema) WHERE "
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
            .guard({ status -> Bool in
                return status == .ok
            }, else: Abort(HttpStatus().send(status: .unableToReachDb)))
            .flatMap { _ in
                return performSqlQueries(inside: req, with: queryLabels, by: userAuth)
                    .guard({ status -> Bool in
                        return status == .ok
                    }, else: Abort(HttpStatus().send(status: .unableToReachDb)))
                    .flatMap { _ in
                        return performSqlQueries(inside: req, with: queryControllino, by: userAuth)
                            .guard({ status -> Bool in
                                return status == .ok
                            }, else: Abort(HttpStatus().send(status: .unableToReachDb)))
                            .transform(to: .ok)
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
                    controllinoList.append(Controllino.List(serialNumber: controllino.id!,
                                                            type: controllino.type,
                                                            latitude: controllino.latitude,
                                                            longitude: controllino.longitude,
                                                            ipAddress: controllino.ipAddress ?? "0.0.0.0"))
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
    
    // Update localisation, type
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
            .guard({ _ -> Bool in
                return checkSqlDB(of: req)
            }, else: Abort(HttpStatus().send(status: .unableToReachDb)))
            .flatMap { controllino -> EventLoopFuture<HTTPStatus> in
                if controllino!.type != type {
                    typeIsChanged = true
                }
                return updateControllinoInfos(controllino!, inside: req.db as! SQLDatabase, with: receivedData, and: type)
                    .flatMap { _ -> EventLoopFuture<HTTPStatus> in
                        if typeIsChanged {
                            return updateControllinoType(type, at: receivedData.serialNumber, inside: req, by: userAuth)
                                .guard({ status -> Bool in
                                    return status == .ok
                                }, else: Abort(HttpStatus().send(status: .unableToReachDb)))
                                .transform(to: .ok)
                        } else {
                            return EventLoopFutureReturn().errorHttpStatus(on: req, withError: .ok)
                        }
                    }
            }
    }
    
    // Update IP Address
    func updateIpAdress(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let userAuth = try req.auth.require(User.self)
        let receivedData = try req.content.decode(Controllino.UpdateIP.self)
        
        return Controllino.query(on: req.db)
            .filter(\.$id == receivedData.serialNumber)
            .first()
            .guard({ _ -> Bool in
                return userAuth.rights == .user || userAuth.rights == .admin || userAuth.rights == .superAdmin || userAuth.rights == .controller
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .guard({ _ -> Bool in
                return checkIpFormat(receivedData.ipAddress)
            }, else: Abort(HttpStatus().send(status: .wrongIp, with: receivedData.ipAddress)))
            .guard({ _ -> Bool in
                return checkSqlDB(of: req)
            }, else: Abort(HttpStatus().send(status: .unableToReachDb)))
            .flatMap { controllino -> EventLoopFuture<HTTPStatus> in
                return updateIpAddress(inside: req.db as! SQLDatabase, with: receivedData)
            }
    }
    
    // Update a pin of one controllino from a JSON request : {"serialNumber":"123456789","pin":"a0","value":true"}
    func updateOnePin(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        let pin = req.parameters.get("pin")
        let date = Date.init()
        let receivedData = try req.content.decode(Controllino.UpdateOnePin.self)
        
        return Controllino.find(receivedData.serialNumber, on: req.db)
            .guard({ _ -> Bool in
                return userAuth.rights == .controller
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .guard({ controllino -> Bool in
                return controllino != nil
            }, else: Abort(HttpStatus().send(status: .wrongSerialNumber, with: receivedData.serialNumber)))
            .guard({ _ -> Bool in
                return pin != nil
            }, else: Abort(HttpStatus().send(status: .wrongPin, with: "")))
            .guard({ _ -> Bool in
                return Controllino.pinsList.contains(pin!)
            }, else: Abort(HttpStatus().send(status: .wrongPin, with: pin!)))
            .guard({ _ -> Bool in
                return checkSqlDB(of: req)
            }, else: Abort(HttpStatus().send(status: .unableToReachDb)))
            .flatMap { _ -> EventLoopFuture<HTTPStatus> in
                updateOnePin(with: receivedData.serialNumber, inside: req.db as! SQLDatabase, at: pin!, value: receivedData.value, at: date)
            }
    }
    
    func updateAllPins(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get user after authentification
        let userAuth = try req.auth.require(User.self)
        let date = Date.init()
        var receivedData = try req.content.decode(Controllino.UpdateAllPins.self)
        
        return Controllino.find(receivedData.serialNumber, on: req.db)
            .guard({ _ -> Bool in
                return userAuth.rights == .controller
            }, else: Abort(HttpStatus().send(status: .unauthorize)))
            .guard({ controllino -> Bool in
                return controllino != nil
            }, else: Abort(HttpStatus().send(status: .wrongSerialNumber, with: receivedData.serialNumber)))
            .guard({ _ -> Bool in
                return checkSqlDB(of: req)
            }, else: Abort(HttpStatus().send(status: .unableToReachDb)))
            .flatMap { controllino -> EventLoopFuture<HTTPStatus> in
                if controllino!.type == .maxi {
                    receivedData.a10 = nil
                    receivedData.a11 = nil
                    receivedData.a12 = nil
                    receivedData.a13 = nil
                    receivedData.a14 = nil
                    receivedData.a15 = nil
                    receivedData.i16 = nil
                    receivedData.i17 = nil
                    receivedData.i18 = nil
                    receivedData.d12 = nil
                    receivedData.d13 = nil
                    receivedData.d14 = nil
                    receivedData.d15 = nil
                    receivedData.d16 = nil
                    receivedData.d17 = nil
                    receivedData.d18 = nil
                    receivedData.d19 = nil
                    receivedData.d20 = nil
                    receivedData.d21 = nil
                    receivedData.d22 = nil
                    receivedData.d23 = nil
                    receivedData.r10 = nil
                    receivedData.r11 = nil
                    receivedData.r12 = nil
                    receivedData.r13 = nil
                    receivedData.r14 = nil
                    receivedData.r15 = nil
                }
                return updateAllPin(inside: req.db as! SQLDatabase, with: receivedData, at: date)
            }
    }
    
    /*
     Private functions
     */
    // This function checks if the DB of the request is an SQL DB
    private func checkSqlDB(of req: Request) -> Bool {
        if let _ = req.db as? SQLDatabase {
            return true
        } else {
            return false
        }
    }
    
    // This function check the type of the controllino. If the type is not correctly set, it will be set into Controllino Maxi
    private func checkType(_ type: String) -> ControllinoType {
        if type.lowercased() == "mega" {
            return .mega;
        } else {
            return .maxi;
        }
    }
    
    private func checkIpFormat(_ ip: String) -> Bool {
        var result = true
        let ipArray = ip.components(separatedBy: ".")
        
        if ipArray.count == 4 {
            for byte in ipArray {
                if byte.count == 0 || byte.count > 3 || Int(byte) == nil {
                    result = false
                }
                if let intByte = Int(byte),
                   intByte < 0 || intByte > 255 {
                    result = false
                }
            }
        } else {
            result = false
        }
        
        return result
    }
    
    private func performSqlQueries(inside req: Request, with query: String, by user: User) -> EventLoopFuture<HTTPStatus> {
        if let sql = req.db as? SQLDatabase,
           user.rights == .superAdmin || user.rights == .admin || user.rights == .user {
            return sql.raw(SQLQueryString(query)).run().transform(to: .ok)
        } else {
            return EventLoopFutureReturn().errorHttpStatus(on: req, withError: HttpStatus().send(status: .unableToReachDb))
        }
    }
    
    private func updateIpAddress(inside sql: SQLDatabase, with data: Controllino.UpdateIP) -> EventLoopFuture<HTTPStatus> {
        return sql.update(Controllino.schema)
            .set("ip_address", to: data.ipAddress)
            .where("serial_number", .equal, data.serialNumber)
            .run()
            .transform(to: .ok)
    }
    
    private func updateControllinoInfos(_ controllino: Controllino, inside sql: SQLDatabase, with data: Controllino.Update, and type: ControllinoType) -> EventLoopFuture<HTTPStatus> {
        return sql.update(Controllino.schema)
            .set("latitude", to: data.latitude)
            .set("longitude", to: data.longitude)
            .set("serial_number", to: data.serialNumber)
            .set("type", to: type)
            .set("last_modification_date", to: Date.init())
            .where("serial_number", .equal, controllino.id)
            .run()
            .transform(to: .ok)
    }
    
    private func updateControllinoType(_ type: ControllinoType, at id: String, inside req: Request, by user: User) -> EventLoopFuture<HTTPStatus> {
        var query = "UPDATE \(Controllino.schema) "
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
    
    // This function check if the controllino exist. If yes, if the pin exist and if yes, update the pin inside the DB
    private func updateOnePin(with serialNumber: String, inside sql: SQLDatabase, at pin: String, value: Bool, at date: Date) -> EventLoopFuture<HTTPStatus> {
        return sql.update(Controllino.schema)
            .set(pin, to: value)
            .set("last_modification_date", to: date)
            .where("serial_number", .equal, serialNumber)
            .run()
            .transform(to: .ok)
    }
    
    // This function check if the controllino exist. If yes, update all the pins inside the DB
    private func updateAllPin(inside sql: SQLDatabase, with data: Controllino.UpdateAllPins, at date: Date) -> EventLoopFuture<HTTPStatus> {
        return sql.update(Controllino.schema)
            .set("A0", to: data.a0)
            .set("A1", to: data.a1)
            .set("A2", to: data.a2)
            .set("A3", to: data.a3)
            .set("A4", to: data.a4)
            .set("A5", to: data.a5)
            .set("A6", to: data.a6)
            .set("A7", to: data.a7)
            .set("A8", to: data.a8)
            .set("A9", to: data.a9)
            .set("A10", to: data.a10)
            .set("A11", to: data.a11)
            .set("A12", to: data.a12)
            .set("A13", to: data.a13)
            .set("A14", to: data.a14)
            .set("A15", to: data.a15)
            .set("I16", to: data.i16)
            .set("I17", to: data.i17)
            .set("I18", to: data.i18)
            .set("INT0", to: data.int0)
            .set("INT1", to: data.int1)
            .set("D0", to: data.d0)
            .set("D1", to: data.d1)
            .set("D2", to: data.d2)
            .set("D3", to: data.d3)
            .set("D4", to: data.d4)
            .set("D5", to: data.d5)
            .set("D6", to: data.d6)
            .set("D7", to: data.d7)
            .set("D8", to: data.d8)
            .set("D9", to: data.d9)
            .set("D10", to: data.d10)
            .set("D11", to: data.d11)
            .set("D12", to: data.d12)
            .set("D13", to: data.d13)
            .set("D14", to: data.d14)
            .set("D15", to: data.d15)
            .set("D16", to: data.d16)
            .set("D17", to: data.d17)
            .set("D18", to: data.d18)
            .set("D19", to: data.d19)
            .set("D20", to: data.d20)
            .set("D21", to: data.d21)
            .set("D22", to: data.d22)
            .set("D23", to: data.d23)
            .set("R0", to: data.r0)
            .set("R1", to: data.r1)
            .set("R2", to: data.r2)
            .set("R3", to: data.r3)
            .set("R4", to: data.r4)
            .set("R5", to: data.r5)
            .set("R6", to: data.r6)
            .set("R7", to: data.r7)
            .set("R8", to: data.r8)
            .set("R9", to: data.r9)
            .set("R10", to: data.r10)
            .set("R11", to: data.r11)
            .set("R12", to: data.r12)
            .set("R13", to: data.r13)
            .set("R14", to: data.r14)
            .set("R15", to: data.r15)
            .set("last_modification_date", to: date)
            .where("serial_number", .equal, data.serialNumber)
            .run()
            .transform(to: .ok)
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
    
    struct UpdateIP: Content {
        let serialNumber: String
        let ipAddress: String
    }
    
    struct UpdateOnePin: Content {
        let serialNumber: String
        let value: Bool
    }
    
    struct UpdateAllPins: Content {
        let serialNumber: String
        let a0: Bool
        let a1: Bool
        let a2: Bool
        let a3: Bool
        let a4: Bool
        let a5: Bool
        let a6: Bool
        let a7: Bool
        let a8: Bool
        let a9: Bool
        var a10: Bool?
        var a11: Bool?
        var a12: Bool?
        var a13: Bool?
        var a14: Bool?
        var a15: Bool?
        var i16: Bool?
        var i17: Bool?
        var i18: Bool?
        let int0: Bool
        let int1: Bool
        let d0: Bool
        let d1: Bool
        let d2: Bool
        let d3: Bool
        let d4: Bool
        let d5: Bool
        let d6: Bool
        let d7: Bool
        let d8: Bool
        let d9: Bool
        let d10: Bool
        let d11: Bool
        var d12: Bool?
        var d13: Bool?
        var d14: Bool?
        var d15: Bool?
        var d16: Bool?
        var d17: Bool?
        var d18: Bool?
        var d19: Bool?
        var d20: Bool?
        var d21: Bool?
        var d22: Bool?
        var d23: Bool?
        let r0: Bool
        let r1: Bool
        let r2: Bool
        let r3: Bool
        let r4: Bool
        let r5: Bool
        let r6: Bool
        let r7: Bool
        let r8: Bool
        let r9: Bool
        var r10: Bool?
        var r11: Bool?
        var r12: Bool?
        var r13: Bool?
        var r14: Bool?
        var r15: Bool?
    }
}
