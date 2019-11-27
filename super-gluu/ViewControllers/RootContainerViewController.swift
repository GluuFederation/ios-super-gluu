//
//  RootContainerViewController.swift
//  Super Gluu
//
//  Created by eric webb on 7/30/19.
//  Copyright © 2019 Gluu. All rights reserved.
//

import UIKit


enum RootState {
    case security
    case home
    case approveDeny
}

class RootContainerViewController: UIViewController {
// MARK: – Variables
    
    private lazy var securityController: UINavigationController = {
        let navigationController = UIStoryboard(name: "Landing", bundle: nil).instantiateInitialViewController() as! UINavigationController
        self.add(navigationController)
        return navigationController
    }()
    
    private lazy var homeNavigationController: BaseNavigationController = {
        let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! BaseNavigationController
        self.add(navigationController)
        return navigationController
    }()
    
    private lazy var approveDenyController: ApproveDenyViewController = {
        let vc = ApproveDenyViewController.fromStoryboard("Main")
        self.add(vc)
        return vc
    }()
    
    private var currentState: RootState?
    
    func updateDisplay(nextState: RootState) {

        if currentState == nextState { return }

        if currentState != nil {
            switch currentState! {
            case .approveDeny:
                approveDenyController.remove()
            case .home:
                homeNavigationController.remove()
            case .security:
                securityController.remove()
            }
        }

        switch nextState {
        case .approveDeny:
            add(approveDenyController)
        case .home:
            add(homeNavigationController)

            if let push = PushHelper.shared.lastPush,
                !push.isExpired,
                let homeVC = homeNavigationController.viewControllers.first as? HomeViewController {

                homeVC.handlePush()
            }

        case .security:
            let navigationController = UIStoryboard(name: "Landing", bundle: nil).instantiateInitialViewController() as! UINavigationController
            add(navigationController)
        }

    }
    
    func activeStatePushReceived() {
        guard currentState == RootState.home, let homeVC = homeNavigationController.viewControllers.first as? HomeViewController else { return }
        
        homeVC.handlePush()
        
    }
    
    // MARK: – View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateDisplay(nextState: .security)
    }


}



