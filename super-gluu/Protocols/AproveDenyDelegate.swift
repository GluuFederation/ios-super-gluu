//
//  AproveDenyDelegate.swift
//  Super Gluu
//
//  Created by Eric Webb on 9/26/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import Foundation

protocol ApproveDenyDelegate {
    
    func approveRequest()
    func denyRequest()
    func openRequest()
    
//    - (void)approveRequest:(void (^)(BOOL success, NSString *errorMessage))handler;
    
    
//    -(void)approveRequest;
//    -(void)denyRequest;
//    -(void)openRequest;
}

