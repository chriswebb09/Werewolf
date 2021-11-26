//
//  Logger.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import Foundation
import os.log

struct Logger {

    static func log(_ info: String, file: String = #file, function: String = #function, line: Int = #line) {
        os_log("%@:%d %@: %@", type: .default, (file as NSString).lastPathComponent, line, function, info)
    }
}
