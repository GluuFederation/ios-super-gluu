//
//  RootContainerViewController.swift
//  Super Gluu
//
//  Created by eric webb on 7/30/19.
//  Copyright © 2019 Gluu. All rights reserved.
//

import UIKit

//private func updateView() {
//    if segmentedControl.selectedSegmentIndex == 0 {
//        remove(asChildViewController: sessionsViewController)
//        add(asChildViewController: summaryViewController)
//    } else {
//        remove(asChildViewController: summaryViewController)
//        add(asChildViewController: sessionsViewController)
//    }
//}

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
        case .security:
            let navigationController = UIStoryboard(name: "Landing", bundle: nil).instantiateInitialViewController() as! UINavigationController
            add(navigationController)
//            securityController.popToRootViewController(animated: false)
//            add(securityController)
        }
 
 
        
//        switch nextState {
//        case .approveDeny:
//            performSegue(withIdentifier: "RootToApproveDeny", sender: nil)
//        case .home:
//            performSegue(withIdentifier: "RootToHome", sender: nil)
//        case .security:
//            performSegue(withIdentifier: "RootToSecurity", sender: nil)
//        }
//        currentState = nextState
 
    }
    

    // MARK: – View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateDisplay(nextState: .security)
    }

    /*
    private func setRootChildViewController() {
        
        guard let navigationController = UIStoryboard(name: "Landing", bundle: nil).instantiateInitialViewController() as? UINavigationController else {
            return
        }
        
        landingNavigationController = navigationController
        
        add(landingNavigationController!)
        
    }

    // MARK: – Child View Controller Helpers

    
    func transitionToLandingNavigationViewController() {
        
        guard homeNavigationController != nil else {
            return
        }
        
        if let presentedVC = homeNavigationController?.presentedViewController {
            presentedVC.dismiss(animated: false, completion: nil)
        }
        
        guard let navigationController = UIStoryboard(name: "Landing", bundle: nil).instantiateInitialViewController() as? UINavigationController else {
            return
        }
        
        landingNavigationController = navigationController
        add(landingNavigationController!)
        homeNavigationController?.remove()
        
    }

    func transitionToHomeViewController() {
        
        landingNavigationController?.willMove(toParentViewController: nil)
        
        guard let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? BaseNavigationController else {
            return
        }
        
        homeNavigationController = navigationController
        add(homeNavigationController!)
        landingNavigationController?.remove()

    }
 */

}



