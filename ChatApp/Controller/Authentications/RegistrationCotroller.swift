//
//  RegistrationCotroller.swift
//  ChatApp
//
//  Created by neuli on 2022/06/01.
//

import UIKit
import Firebase

protocol AuthenticationControllerProtocol {
    func checkFormStatus()
}

class RegistrationController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel = RegistrationViewModel()
    private var profileImage: UIImage?
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "lock")!, textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var fullNameContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "lock")!, textField: fullNameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var usernameContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "lock")!, textField: usernameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "lock")!, textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    private let fullNameTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Fullname", isSecureTextEntry: false)
    }()
    
    private let usernameTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Username", isSecureTextEntry: false)
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider", "Driver"])
        sc.backgroundColor = .backgroundColor
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor(white: 1.0, alpha: 0.87)], for: .normal)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.backgroundColor], for: .selected)
        sc.selectedSegmentTintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ",
            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
                         NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Log in",
            attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),
                         NSAttributedString.Key.foregroundColor : UIColor.mainBlueTint]))
        button.addTarget(self, action: #selector(handleShowLogIn), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.tintColor = .white
        button.backgroundColor = .systemPink
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
    }
    
    // MARK: - Selectors
    
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullNameTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        guard let profileImage = profileImage else { return }

        guard let imageData = profileImage.jpegData(compressionQuality: 0.3) else { return }
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/progile_images/\(filename)")
        
        ref.putData(imageData) { meta, error in
            if let _ = error {
                print("이미지 저장 실패")
                return
            }
            ref.downloadURL { url, error in
                guard let profileImageUrl = url?.absoluteString else { return }
                
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("유저 생성 실패 \(error.localizedDescription)")
                        return
                    }
                    
                    guard let uid = result?.user.uid else { return }
                    
                    let data = ["email": email,
                                "fullname": fullname,
                                "profileImageUrl": profileImageUrl,
                                "uid": uid,
                                "username": username] as [String : Any]
                    
                    Firestore.firestore().collection("users").document(uid).setData(data) { error in
                        if let _ = error {
                            print("유저 저장 실패")
                            return
                        }
                        print("유저 저장")
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    @objc func handleShowLogIn() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else if sender == passwordTextField {
            viewModel.password = sender.text
        } else if sender == fullNameTextField {
            viewModel.fullname = sender.text
        } else {
            viewModel.username = sender.text
        }
        
        checkFormStatus()
    }
    
    // MARK: - Helper Functions
    
    func configureUI() {
        
        configureGradientLayer()
        
        view.addSubview(plusButton)
        plusButton.centerX(inView: view)
        plusButton.anchor(top: view.topAnchor, paddingTop: 50)
        plusButton.setDimensions(height: 200, width: 200)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   fullNameContainerView,
                                                   usernameContainerView,
                                                   passwordContainerView,
                                                   signUpButton])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: plusButton.bottomAnchor,
                     left: view.leftAnchor,
                     right: view.rightAnchor,
                     paddingTop: 32,
                     paddingLeft: 32,
                     paddingRight: 32)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        profileImage = image
        plusButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        plusButton.layer.borderColor = UIColor(white: 1, alpha: 0.7).cgColor
        plusButton.layer.borderWidth = 3.0
        plusButton.layer.cornerRadius = 200 / 2
        
        dismiss(animated: true, completion: nil)
    }
}

extension RegistrationController: AuthenticationControllerProtocol {
    func checkFormStatus() {
        if viewModel.formIsValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = .blue
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = .systemPink
        }
    }
}
