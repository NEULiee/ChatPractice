//
//  RegistrationViewModel.swift
//  ChatApp
//
//  Created by neuli on 2022/06/01.
//

import Foundation

struct RegistrationViewModel: AuthenticationProtocol {
    
    var email: String?
    var password: String?
    var fullname: String?
    var username: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false &&
        password?.isEmpty == false &&
        fullname?.isEmpty == false &&
        username?.isEmpty == false
    }
}
