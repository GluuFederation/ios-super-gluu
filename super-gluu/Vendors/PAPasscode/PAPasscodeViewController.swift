//
//  PAPasscodeViewController.swift
//  Super Gluu
//
//  Created by Eric Webb on 11/5/18.
//  Copyright © 2018 Gluu. All rights reserved.
//

import UIKit
import QuartzCore


enum PasscodeAction : Int {
    case set
    case enter
    case change
}

protocol PAPasscodeViewControllerDelegate {
    func paPasscodeViewControllerDidCancel(_ controller: PAPasscodeViewController)
    
    func paPasscodeViewControllerDidChangePasscode(_ controller: PAPasscodeViewController)
    
    func paPasscodeViewControllerDidEnterAlternativePasscode(_ controller: PAPasscodeViewController)
    
    func paPasscodeViewControllerDidEnterPasscode(_ controller: PAPasscodeViewController)
    
    func paPasscodeViewControllerDidSetPasscode(_ controller: PAPasscodeViewController)
    
    func paPasscodeViewController(_ controller: PAPasscodeViewController, didFailToEnterPasscode attempts: Int)
}

class PAPasscodeViewController: UIViewController, UITextFieldDelegate {

    private var BulletCharacter = "\u{25CF}"
    private var DashCharacter = "\u{2010}"
    private var FailedBackgroundHeight: Int = 24
    private var AnimationDuration: TimeInterval = 0.3
    
    var backgroundView: UIView?
    private var action: PasscodeAction = PasscodeAction.enter
    
    var delegate: PAPasscodeViewControllerDelegate?
    
    var alternativePasscode = ""
    var passcode = ""
    var simple = false
    var failedAttempts: Int = 0
    var enterPrompt = ""
    var confirmPrompt = ""
    var changePrompt = ""
    var message = ""
    
    var installedConstraints = [NSLayoutConstraint]()
    
    var inputPanel: UIControl = UIControl()

    var keyboardHeightConstraint: NSLayoutConstraint?
    var contentView: UIView = UIView()
    
    var phase: Int = 0
    var promptLabel = UILabel()

    var messageLabel = UILabel()
    
    var failedAttemptsView = UIView()
    
    var failedAttemptsLabel = UILabel()
    
    var passcodeTextField = UITextField()
    
    var digitLabels = [UILabel]()
    var snapshotImageView: UIImageView?

    
    init(for action: PasscodeAction) {
        super.init(nibName: nil, bundle: nil)
        
        self.action = action
        switch action {
        case .set:
            title = LocalString.Passcode_Set.localized
            enterPrompt = LocalString.Passcode_Enter_A_Passcode.localized
            confirmPrompt = LocalString.Passcode_Reenter.localized
        case .enter:
            title = LocalString.Passcode_Enter_A_Passcode.localized
            enterPrompt = LocalString.Passcode_Enter_Your_Passcode.localized
        case .change:
            title = LocalString.Passcode_Change.localized
            changePrompt = LocalString.Passcode_Enter_Old.localized
            enterPrompt = LocalString.Passcode_Enter_New.localized
            confirmPrompt = LocalString.Passcode_Reenter_New.localized
        }
        
        modalPresentationStyle = .formSheet
        simple = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if simple {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PAPasscodeViewController.cancel(_:)))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PAPasscodeViewController.cancel(_:)))
        }
        
        if failedAttempts > 0 {
            showFailedAttempts()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(PAPasscodeViewController.keyboardWillShow(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PAPasscodeViewController.keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
//        switch action {
//        case .set:
//            title = LocalString.Passcode_Set.localized
//            enterPrompt = LocalString.Passcode_Enter_A_Passcode.localized
//            confirmPrompt = LocalString.Passcode_Reenter.localized
//        case .enter:
//            title = LocalString.Passcode_Enter_A_Passcode.localized
//            enterPrompt = LocalString.Passcode_Enter_Your_Passcode.localized
//        case .change:
//            title = LocalString.Passcode_Change.localized
//            changePrompt = LocalString.Passcode_Enter_Old.localized
//            enterPrompt = LocalString.Passcode_Enter_New.localized
//            confirmPrompt = LocalString.Passcode_Reenter_New.localized
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showScreen(forPhase: 0, animated: false)
        passcodeTextField.becomeFirstResponder()
        view.layoutIfNeeded()
    }
    
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        // contentView is set to the visible area (below nav bar, above keyboard)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.clear
        
        inputPanel.translatesAutoresizingMaskIntoConstraints = false
        inputPanel.addTarget(self, action: #selector(PAPasscodeViewController.showKeyboard), for: .touchUpInside)
        
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        promptLabel.font = UIFont.systemFont(ofSize: 15)
        promptLabel.textAlignment = .center
        promptLabel.numberOfLines = 0
        
        failedAttemptsView.translatesAutoresizingMaskIntoConstraints = false
        failedAttemptsView.backgroundColor = UIColor(red: 0.75, green: 0.16, blue: 0.16, alpha: 1)
        failedAttemptsView.layer.cornerRadius = CGFloat(FailedBackgroundHeight / 2)
        failedAttemptsView.isHidden = true
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        
        failedAttemptsLabel.translatesAutoresizingMaskIntoConstraints = false
        failedAttemptsLabel.textColor = UIColor.white
        failedAttemptsLabel.font = UIFont.systemFont(ofSize: 14)
        failedAttemptsLabel.textAlignment = .center
        
        passcodeTextField.translatesAutoresizingMaskIntoConstraints = false
        passcodeTextField.isSecureTextEntry = true
        passcodeTextField.delegate = self
        
        passcodeTextField.addTarget(self, action: #selector(passcodeChanged(_:)), for: .editingChanged)
        
        view.addSubview(contentView)
        contentView.addSubview(inputPanel)
        inputPanel.addSubview(passcodeTextField)
        
        if simple {
            let font = UIFont(name: "Courier", size: 32)
            for i in 0..<4 {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.font = font
                label.text = DashCharacter
                inputPanel.addSubview(label)
                digitLabels.append(label)
            }
            passcodeTextField.isHidden = true
            passcodeTextField.keyboardType = .numberPad
        } else {
            inputPanel.backgroundColor = UIColor.white
        }
        
        contentView.addSubview(promptLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(failedAttemptsView)
        
        failedAttemptsView.addSubview(failedAttemptsLabel)
        
        self.view = view
        self.view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if installedConstraints.isEmpty == false {
            view.removeConstraints(installedConstraints)
        }
        
        var constraints: [NSLayoutConstraint] = []
        let views = ["contentView": contentView, "inputPanel": inputPanel, "failedAttemptsLabel": failedAttemptsLabel, "failedAttemptsView": failedAttemptsView, "messageLabel": messageLabel, "passcodeTextField": passcodeTextField, "promptLabel": promptLabel]
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: views))
        constraints.append(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        keyboardHeightConstraint = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0)
        constraints.append(keyboardHeightConstraint!)
        constraints.append(NSLayoutConstraint(item: inputPanel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        
        if simple {
            constraints.append(NSLayoutConstraint(item: inputPanel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
            let digits = ["d0": digitLabels[0], "d1": digitLabels[1], "d2": digitLabels[2], "d3": digitLabels[3]]
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[d0]-(w)-[d1]-(w)-[d2]-(w)-[d3]|", options: [], metrics: ["w": 16], views: digits))
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[d0]|", options: [], metrics: nil, views: digits))
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[d1]|", options: [], metrics: nil, views: digits))
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[d2]|", options: [], metrics: nil, views: digits))
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[d3]|", options: [], metrics: nil, views: digits))
        } else {
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[inputPanel]|", options: [], metrics: nil, views: views))
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[passcodeTextField]-|", options: [], metrics: nil, views: views))
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-[passcodeTextField]-|", options: [], metrics: nil, views: views))
        }
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[failedAttemptsLabel]-|", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[failedAttemptsLabel]|", options: [], metrics: nil, views: views))
        
        constraints.append(NSLayoutConstraint(item: failedAttemptsView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: promptLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[promptLabel]-[inputPanel]-[messageLabel]-[failedAttemptsView(h)]", options: [], metrics: ["h": FailedBackgroundHeight], views: views))
        
        installedConstraints = constraints
        view.addConstraints(installedConstraints)
    }
    
    @objc private func cancel(_ sender: Any?) {
        delegate?.paPasscodeViewControllerDidCancel(self)
    }
    
    private func handleFailedAttempt() {
        failedAttempts += 1
        showFailedAttempts()
        delegate?.paPasscodeViewController(self, didFailToEnterPasscode: failedAttempts)
    }
    
    @objc
    private func handleCompleteField() {
        guard let text = passcodeTextField.text else { return }
        
        switch action {
        case .set:
            if phase == 0 {
                passcode = text
                messageLabel.text = ""
                showScreen(forPhase: 1, animated: true)
            } else {
                if (text == passcode) {
                    delegate?.paPasscodeViewControllerDidSetPasscode(self)
                } else {
                    showScreen(forPhase: 0, animated: true)
                    messageLabel.text = LocalString.Passcode_Try_Again.localized
                }
            }
            
        case .enter:
            if (text == passcode) {
                resetFailedAttempts()
                delegate?.paPasscodeViewControllerDidEnterPasscode(self)
                
            } else {
                if text == alternativePasscode {
                    resetFailedAttempts()
                    delegate?.paPasscodeViewControllerDidEnterAlternativePasscode(self)
                } else {
                    handleFailedAttempt()
                    showScreen(forPhase: 0, animated: false)
                }
            }
        case .change:
            if phase == 0 {
                if (text == passcode) {
                    resetFailedAttempts()
                    showScreen(forPhase: 1, animated: true)
                } else {
                    handleFailedAttempt()
                    showScreen(forPhase: 0, animated: false)
                }
            } else if phase == 1 {
                passcode = text
                messageLabel.text = nil
                showScreen(forPhase: 2, animated: true)
            } else {
                if text == passcode {
                    delegate?.paPasscodeViewControllerDidChangePasscode(self)
                } else {
                    showScreen(forPhase: 1, animated: true)
                    messageLabel.text = LocalString.Passcode_Try_Again.localized
                }
            }
        }
    }
    
    @objc
    private func passcodeChanged(_ sender: UITextField) {
        guard var text = passcodeTextField.text else { return }
        
        if simple {
            if text.count > 4 {
                text = (text as? NSString)?.substring(to: 4) ?? ""
            }
            for i in 0..<4 {
                digitLabels[i].text = (i >= text.count) ? DashCharacter : BulletCharacter
            }
            if text.count == 4 {
                handleCompleteField()
            }
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = text.count > 0
        }
    }
    
    private func resetFailedAttempts() {
        messageLabel.isHidden = false
        failedAttemptsView.isHidden = true
        failedAttempts = 0
    }
    
    private func showFailedAttempts() {
        messageLabel.isHidden = true
        failedAttemptsView.isHidden = false

        if failedAttempts < 3 {
            failedAttemptsView.backgroundColor = UIColor(red: 0, green: 161 / 255, blue: 97 / 255, alpha: 1.0)
        } else {
            failedAttemptsView.backgroundColor = UIColor.red
        }

        let remainingAttempts = GluuConstants.MAX_PASSCODE_ATTEMPTS_COUNT - failedAttempts
        failedAttemptsLabel.text = "\(remainingAttempts)" + LocalString.Passcode_Attempts_Left.localized
    }
    
    private func showScreen(forPhase newPhase: Int, animated: Bool) {
        
        let dir: CGFloat = (newPhase > phase) ? 1 : -1
        
        if animated {
            UIGraphicsBeginImageContext(view.bounds.size)
            if let aContext = UIGraphicsGetCurrentContext() {
                contentView.layer.render(in: aContext)
            }
            let snapshot: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let snapshotImageView = UIImageView(image: snapshot)
            snapshotImageView.frame = snapshotImageView.frame.offsetBy(dx: -contentView.frame.size.width * dir, dy: 0)
            contentView.addSubview(snapshotImageView)
            
            self.snapshotImageView = snapshotImageView
        }
        
        phase = newPhase
        passcodeTextField.text = ""
        var isFinalScreen = false
        
        if !simple {
            switch action {
            case .set: isFinalScreen = phase == 1
            case .enter: isFinalScreen = phase == 0
            case .change: isFinalScreen = phase == 2
            }
            
//            var isFinalScreen = action == .set && phase == 1
//            isFinalScreen |= action == PasscodeActionEnter && phase == 0
//            isFinalScreen |= action == PasscodeActionChange && phase == 2
            
            if isFinalScreen {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PAPasscodeViewController.handleCompleteField))
            } else {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalString.Passcode_Next.localized, style: .plain, target: self, action: #selector(PAPasscodeViewController.handleCompleteField))
            }
            
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        switch action {
        case .set:
            if phase == 0 {
                promptLabel.text = enterPrompt
            } else {
                promptLabel.text = confirmPrompt
            }
        
        case .enter:
            promptLabel.text = enterPrompt
        
        case .change:
            if phase == 0 {
                promptLabel.text = changePrompt
            } else if phase == 1 {
                promptLabel.text = enterPrompt
            } else {
                promptLabel.text = confirmPrompt
            }
        }
        
        for i in 0..<4 {
            digitLabels[i].text = DashCharacter
        }
        
        if animated {
            contentView.frame = contentView.frame.offsetBy(dx: contentView.frame.size.width * dir, dy: 0)
            UIView.animate(withDuration: AnimationDuration, animations: {
                self.contentView.frame = self.contentView.frame.offsetBy(dx: -self.contentView.frame.size.width * dir, dy: 0)
            }) { finished in
                self.snapshotImageView?.removeFromSuperview()
                self.snapshotImageView = nil
            }
        }
    }
    
    @objc func showKeyboard() {
        showScreen(forPhase: 0, animated: false)
        passcodeTextField.becomeFirstResponder()
        view.layoutIfNeeded()
    }
    
    func hideKeyboard() {
        passcodeTextField.resignFirstResponder()
    }
    
    // MARK: - implementation helpers
    @objc func keyboardWillShow(_ notification: Notification?) {
        let info = notification?.userInfo
        let kbFrame = info?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        let animationDuration = info?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.0
        let keyboardFrame: CGRect? = kbFrame?.cgRectValue
        
        keyboardHeightConstraint?.constant = -(keyboardFrame?.size.height ?? 0.0)
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification?) {
        let info = notification?.userInfo
        let animationDuration = info?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.0
        
        keyboardHeightConstraint?.constant = 0
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

