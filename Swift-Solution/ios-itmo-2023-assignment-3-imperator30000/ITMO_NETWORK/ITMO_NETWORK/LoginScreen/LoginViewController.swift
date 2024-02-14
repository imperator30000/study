import UIKit

class LoginViewController: BaseViewController<LoginView> {

    override func viewDidLoad() {
        super.viewDidLoad()

        customView.onLogin = { [weak self] email, password in
            self?.performLogin(email: email, password: password)
        }
        
        customView.onSuccessfulLogin = { [weak self] in
            print("Login successful, transitioning to the next screen")
            self?.transitionToNextScreen()
        }
        
        customView.onLoginFailed = { [weak self] errorMessage in
            self?.showLoginErrorAlert(message: errorMessage)
        }
    }
    
    private func showLoginErrorAlert(message: String) {
        let alert = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func transitionToNextScreen() {
        let nextViewController = RowsViewController()
        present(nextViewController, animated: true, completion: nil)
    }
    
    private func isUserAlreadyLoggedIn() -> Bool {
        return UserDefaults.standard.string(forKey: "authToken") != nil
    }

    func performLogin(email: String, password: String) {
        // Выполните сетевой запрос для входа и обработайте ответ.
        // В случае успеха сохраните токен и перейдите к RowsViewController.
        // В случае ошибки отобразите сообщение об ошибке.
    }
    
//    func isValidEmail(_ email: String) -> Bool {
//        // Реализуйте логику проверки валидности email.
//    }
//
//    func isValidPassword(_ password: String) -> Bool {
//        // Реализуйте логику проверки валидности пароля.
//    }
}
