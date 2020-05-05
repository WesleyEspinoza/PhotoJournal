//
//  ViewController.swift
//  PhotoJournal
//
//  Created by Erick Wesley Espinoza on 4/22/20.
//  Copyright © 2020 HazeStudio. All rights reserved.
//

import UIKit
import FirebaseAuth
// keep track of what we want to animate
enum LoginVCTransitionAnims {
    case LoginToRegister
    case RegisterToLogin
}

class LoginSignUpViewController: UIViewController {
    let loginView = LoginView()
    let registerView = RegisterView()
    let screen = UIScreen.main
    var leadingAnchor: NSLayoutConstraint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }
    
    func setupView(){
        self.view.addSubview(loginView)
        loginView.delegate = self
        //call extension to make sure the keyboard gets dismissed when tapped elsewhere
        hideKeyboardTapped()
        self.view.addSubview(registerView)
        registerView.delegate = self
        
        leadingAnchor = loginView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        leadingAnchor!.isActive = true
        
        
        NSLayoutConstraint.activate([
            loginView.topAnchor.constraint(equalTo: self.view.topAnchor),
            loginView.widthAnchor.constraint(equalToConstant: screen.bounds.width),
            loginView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            registerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            
            registerView.leadingAnchor.constraint(equalTo: self.loginView.trailingAnchor),
            registerView.widthAnchor.constraint(equalToConstant: screen.bounds.width),
            registerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        
    }
    
    func animateViewFrame(animation: LoginVCTransitionAnims){
        // animate constraints
        switch animation {
        case .LoginToRegister:
            UIView.animate(withDuration: 0.25) {
                self.leadingAnchor?.isActive = false
                self.leadingAnchor = self.loginView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -1 * self.screen.bounds.width)
                self.leadingAnchor?.isActive = true
                self.view.layoutIfNeeded()
            }
            break
        case .RegisterToLogin:
            UIView.animate(withDuration: 0.25) {
                self.leadingAnchor?.isActive = false
                self.leadingAnchor = self.loginView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
                self.leadingAnchor?.isActive = true
                self.view.layoutIfNeeded()
            }
            break
        }
    }
    
    func login(){
        guard let email = loginView.emailTextField.text else {
            showErrorAlert(title: "Email", message: "The email field cannot be empty")
            return
        }
        
        guard let password = loginView.passwordTextField.text else {
            showErrorAlert(title: "Password", message: "The password field cannot be empty")
            return
        }
        // login logic
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            
            if error == nil {
                print(authResult.debugDescription)
                UserDefaults.standard.set(authResult?.user.uid, forKey: "UserId")
                let vc = PhotoJournalViewController()
                vc.modalPresentationStyle = .currentContext
                strongSelf.navigationController?.setNavigationBarHidden(false, animated: true)
                strongSelf.navigationController?.pushViewController(vc, animated: true)
                strongSelf.navigationController?.viewControllers = [vc]
            } else {
                strongSelf.showErrorAlert(title: "Registration", message: error!.localizedDescription)
            }
        }
    }
    
    func register(){
        guard let email = registerView.emailTextField.text else {
            showErrorAlert(title: "Email", message: "The email field cannot be empty")
            return
        }
        
        guard let password = registerView.passwordTextField.text else {
            showErrorAlert(title: "Password", message: "The password field cannot be empty")
            return
        }
        
        // Register logic
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error == nil {
                print(authResult.debugDescription)
                let vc = PhotoJournalViewController()
                vc.modalPresentationStyle = .currentContext
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showErrorAlert(title: "Registration", message: error!.localizedDescription)
            }
            
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

