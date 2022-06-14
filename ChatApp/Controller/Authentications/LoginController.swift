//
//  LoginController.swift
//  ChatApp
//
//  Created by neuli on 2022/06/01.
//

import UIKit
import Firebase
import JGProgressHUD

class LoginController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel = LoginViewModel()
    
    private let iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bubble.right")
        imageView.tintColor = .white
        return imageView
    }()
    
    private let emailTextField = UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    private lazy var emailContainerView = UIView().inputContainerView(image: UIImage(systemName: "envelope")!, textField: emailTextField)
    
    private let passwordTextField = UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    private lazy var passwordContainerView = UIView().inputContainerView(image: UIImage(systemName: "lock")!, textField: passwordTextField)
    
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.tintColor = .white
        button.backgroundColor = .systemPink
        button.setHeight(height: 50)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    lazy var doneHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ",
            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
                         NSAttributedString.Key.foregroundColor : UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Sign Up",
            attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),
                         NSAttributedString.Key.foregroundColor : UIColor.white]))
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc func handleShowSignUp() {
        let controller = RegistrationController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        
        checkFormStatus()
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Logging in"
        hud.show(in: view)
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("로그인 에러 \(error.localizedDescription)")
                hud.dismiss(animated: true)
                return
            }
            hud.dismiss(animated: true)
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - Helpers
    
    func checkFormStatus() {
        if viewModel.formIsValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = .blue
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = .systemPink
        }
    }
    
    func configureUI() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        configureGradientLayer()
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        iconImage.setDimensions(height: 120, width: 120)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   passwordContainerView,
                                                   loginButton])
        
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor,
                     left: view.leftAnchor,
                     right: view.rightAnchor,
                     paddingTop: 32,
                     paddingLeft: 32,
                     paddingRight: 32)
        
        view.addSubview(doneHaveAccountButton)
        doneHaveAccountButton.anchor(left: view.leftAnchor,
                                     bottom: view.bottomAnchor,
                                     right: view.rightAnchor,
                                     paddingLeft: 32,
                                     paddingBottom: 16,
                                     paddingRight: 32)
        
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}
