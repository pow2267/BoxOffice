//
//  UserInfo.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/24.
//

import Foundation

class UserInfo {
    static let shared: UserInfo = UserInfo()
    
    private init() {}
    
    var nickname: String?
}
