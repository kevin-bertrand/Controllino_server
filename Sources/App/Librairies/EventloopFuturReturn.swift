//
//  EventloopFuturReturn.swift
//  
//
//  Created by Kevin Bertrand on 02/02/2021.
//

import Fluent
import Vapor

struct EventLoopFutureReturn {
    func errorHttpStatus(on req: Request, withError error: HTTPStatus) -> EventLoopFuture<HTTPStatus> {
        return User.query(on: req.db).first().transform(to: error)
    }
}
