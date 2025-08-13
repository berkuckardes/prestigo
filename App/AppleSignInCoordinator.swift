import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth

final class AppleSignInCoordinator: NSObject {
    private var currentNonce: String?
    var completion: ((Result<AuthDataResult, Error>) -> Void)?

    /// Starts the Sign in with Apple flow
    func start(completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        self.completion = completion

        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    // MARK: - Nonce helpers
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length

        while remaining > 0 {
            var random: UInt8 = 0
            let status = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if status != errSecSuccess { fatalError("Unable to generate nonce") }
            if random < charset.count {
                result.append(charset[Int(random)])
                remaining -= 1
            }
        }
        return result
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = appleIDCredential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8)
        else {
            completion?(.failure(NSError(domain: "AppleSignIn", code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Missing identity token"])))
            return
        }

        let cred = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: currentNonce ?? "",
            fullName: appleIDCredential.fullName
        )

        Auth.auth().signIn(with: cred) { result, error in
            if let error = error {
                self.completion?(.failure(error))
                return
            }
            if let result = result {
                self.completion?(.success(result))
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        completion?(.failure(error))
    }
}

// MARK: - Presentation
extension AppleSignInCoordinator: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }

        return scene?.keyWindow ?? UIWindow()
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? { windows.first { $0.isKeyWindow } }
}
