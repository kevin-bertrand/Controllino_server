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
}

extension Controllino {
    struct Create: Content {
        var serialNumber: String
        var type: String
        var latitude: Double?
        var longitude: Double?
        var ipAddress: String?
    }
}
