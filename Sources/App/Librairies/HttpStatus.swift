//
//  HttpStatus.swift
//  
//
//  Created by Kevin Bertrand on 02/02/2021.
//

import Foundation
import Vapor

struct HttpStatus {
    func send(error: HttpErrorEnum, with data: String = "") -> HTTPResponseStatus {
        var errorToSend: HTTPResponseStatus
        
        switch error {
        case .ok:
            errorToSend = HTTPResponseStatus(statusCode: 200)
        case .created:
            errorToSend = HTTPResponseStatus(statusCode: 201)
        case .accepted:
            errorToSend = HTTPResponseStatus(statusCode: 202)
        case .badrequest:
            errorToSend = HTTPResponseStatus(statusCode: 400)
        case .unauthorize:
            errorToSend = HTTPResponseStatus(statusCode: 401)
        case .wrongSerialNumber:
            errorToSend = HTTPResponseStatus(statusCode: 460, reasonPhrase: "Controllino with SN \"\(data)\" doesn't exist!")
        case .wrongPin:
            errorToSend = HTTPResponseStatus(statusCode: 461, reasonPhrase: "The pin \"\(data)\" doesn't exist!")
        case .wrongPassword:
            errorToSend = HTTPResponseStatus(statusCode: 470, reasonPhrase: "Your password is not correct!")
        case .userDoesntExist:
            errorToSend = HTTPResponseStatus(statusCode: 471, reasonPhrase: "User with email \(data) doesn't exist!")
        case .alarmAlreadyExists:
            errorToSend = HTTPResponseStatus(statusCode: 480, reasonPhrase: "This alarm already exists!")
        case .alarmDoesntExist:
            errorToSend = HTTPResponseStatus(statusCode: 481, reasonPhrase: "Alarm with id \"(data)\" doesn't exists!")
        }
        
        return errorToSend
    }
}

enum HttpStatusEnum {
    case ok
    case created
    case accepted
    case badrequest
    case unauthorize
    case wrongSerialNumber
    case wrongPin
    case wrongPassword
    case userDoesntExist
    case alarmAlreadyExists
    case alarmDoesntExist
}
