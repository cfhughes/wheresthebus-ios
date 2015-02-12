//
//  DBManager.swift
//  ABQWTB
//
//  Created by Chris Hughes on 11/24/14.
//  Copyright (c) 2014 Chris Hughes. All rights reserved.
//

import Foundation

let db = DBManager()

class DBManager {
    var handle: COpaquePointer = nil
    
    class func open(file: NSString){
        let error = sqlite3_open(file.cStringUsingEncoding(NSUTF8StringEncoding), &db.handle)
    }
    
    func query(sql: String) -> COpaquePointer{
        var stmt: COpaquePointer = nil
        sqlite3_prepare_v2(handle, sql, -1, &stmt, nil)
        
        return stmt
    }
    
}
