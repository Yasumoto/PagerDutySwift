//
//  PagerDutyError.swift
//  PagerDutySwift
//
//  Created by Joe Smith on 5/7/19.
//

import NIOHTTP1

enum PagerDutyError: Error {
    // TODO(Yasumoto): Consider also including the ByteBuffer/Data of the Body if present
    case responseError(errorCode: HTTPResponseStatus)
}
