//
//  Group.swift
//  Spend Tracking App
//	
//  Created by Yunus Gedik on 8.12.2021.
//

import Foundation

struct Group{
    let code: String
    let admin: String
    let name: String
    let description: String
    let period: Int
    let users: [String]
    let autherizedUsers: [String]
    let date: NSNumber
}
