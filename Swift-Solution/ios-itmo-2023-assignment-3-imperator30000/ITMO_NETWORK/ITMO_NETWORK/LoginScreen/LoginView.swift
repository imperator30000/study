import UIKit

class LoginView: BaseView {
    
    private let scrollView = UIScrollView()
    private let container = UIStackView()
    private let email = UITextField()
    private let password = UITextField()
    private let loginButton = UIButton()
    var onLoginFailed: ((String) -> Void)?
    var onLogin: ((String, String) -> Void)?
    var onSuccessfulLogin: (() -> Void)?

    required init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        setupScrollView()
        setupContainer()
        setupEmail()
        setupPassword()
        setupLoginButton()
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "lastOkPage")
        UserDefaults.standard.removeObject(forKey: "checkCollision")
        UserDefaults.standard.removeObject(forKey: "cachedRows")
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }

    private func setupContainer() {
        container.axis = .vertical
        container.alignment = .fill
        container.distribution = .fill
        container.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        container.isLayoutMarginsRelativeArrangement = true
        container.spacing = 20

        container.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            container.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            container.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }

    private func setupEmail() {
        email.placeholder = "Email"
        email.borderStyle = .roundedRect
        email.keyboardType = .emailAddress
        email.autocorrectionType = .no
        email.autocapitalizationType = .none
        email.translatesAutoresizingMaskIntoConstraints = false
        email.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        container.addArrangedSubview(email)
    }

    private func setupPassword() {
        password.placeholder = "Password"
        password.isSecureTextEntry = true
        password.borderStyle = .roundedRect
        password.autocorrectionType = .no
        password.autocapitalizationType = .none
        password.translatesAutoresizingMaskIntoConstraints = false
        password.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        container.addArrangedSubview(password)
    }

    private func setupLoginButton() {
        loginButton.setTitle("Login", for: .normal)
        loginButton.configuration = UIButton.Configuration.borderedProminent()
        loginButton.addTarget(self, action: #selector(self.onLoginTap), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        container.addArrangedSubview(loginButton)
    }

    @objc
    private func onLoginTap_() {
        onLogin?(email.text ?? "", password.text ?? "")
    }

    @objc
    private func onLoginTap() {
        guard let emailText = email.text, let passwordText = password.text else { return }
        NetworkManager.shared.login(email: emailText, password: passwordText) { [weak self] success, token in
            DispatchQueue.main.async {
                if success {
                    UserDefaults.standard.set(token, forKey: "authToken")
                    self?.onSuccessfulLogin?()
                } else {
                    self?.onLoginFailed?("Invalid email or password")
                }
            }
        }
    }
}
