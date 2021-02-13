//
//  HttpStatus.swift
//  
//
//  Created by Kevin Bertrand on 02/02/2021.
//

import Foundation
import Vapor

struct HttpStatus {
    func send(status: HttpStatusEnum, with data: String = "") -> HTTPResponseStatus {
        var statusToSend: HTTPResponseStatus
        
        switch status {
        case .ok:
            statusToSend = HTTPResponseStatus(statusCode: 200)
        case .created:
            statusToSend = HTTPResponseStatus(statusCode: 201)
        case .accepted:
            statusToSend = HTTPResponseStatus(statusCode: 202)
        case .deleted:
            statusToSend = HTTPResponseStatus(statusCode: 209, reasonPhrase: "Deleted")
        case .badrequest:
            statusToSend = HTTPResponseStatus(statusCode: 400)
        case .unauthorize:
            statusToSend = HTTPResponseStatus(statusCode: 401)
        case .wrongSerialNumber:
            statusToSend = HTTPResponseStatus(statusCode: 460, reasonPhrase: "Controllino with SN \"\(data)\" doesn't exist!")
        case .wrongPin:
            statusToSend = HTTPResponseStatus(statusCode: 461, reasonPhrase: "The pin \"\(data)\" doesn't exist!")
        case .wrongIp:
            statusToSend = HTTPResponseStatus(statusCode: 462, reasonPhrase: "The IP \"\(data)\" is not correct!")
        case .wrongPassword:
            statusToSend = HTTPResponseStatus(statusCode: 470, reasonPhrase: "Your password is not correct!")
        case .userDoesntExist:
            statusToSend = HTTPResponseStatus(statusCode: 471, reasonPhrase: "User with email \"\(data)\" doesn't exist!")
        case .alarmAlreadyExists:
            statusToSend = HTTPResponseStatus(statusCode: 480, reasonPhrase: "This alarm already exists!")
        case .alarmDoesntExist:
            statusToSend = HTTPResponseStatus(statusCode: 481, reasonPhrase: "Alarm with id \"\(data)\" doesn't exists!")
        case .expressionIsNotValid:
            statusToSend = HTTPResponseStatus(statusCode: 490, reasonPhrase: "Expression \"\(data)\" is not valid")
        case .severityIsNotValid:
            statusToSend = HTTPResponseStatus(statusCode: 491, reasonPhrase: "Severity \"\(data)\" is not valid")
        case .unableToReachDb:
            statusToSend = HTTPResponseStatus(statusCode: 520, reasonPhrase: "Unable to reach the database!")
        }
        
        return statusToSend
    }
}

enum HttpStatusEnum {
    case ok
    case created
    case accepted
    case deleted
    case badrequest
    case unauthorize
    case wrongSerialNumber
    case wrongPin
    case wrongIp
    case wrongPassword
    case userDoesntExist
    case alarmAlreadyExists
    case alarmDoesntExist
    case expressionIsNotValid
    case severityIsNotValid
    case unableToReachDb
}
