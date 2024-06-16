import Foundation
import Combine
import MSAL
#if canImport(UIKit)
import UIKit
#endif
#if canImport(Cocoa)
import Cocoa

public typealias UIViewController = NSViewController
#endif

public class MSAL {
   private let scopes: [String]
   private let clientId: String
   private let authority: String
   
   public var isLoggingEnabled = false
   
   private lazy var msalApplication: MSALPublicClientApplication = {
      MSAL.makeMsalApplication(clientId: clientId, authority: authority)
   }()
   
   public init(scopes: [String], clientId: String, authority: String) {
      self.scopes = scopes
      self.clientId = clientId
      self.authority = authority
   }
   
   //Mark: - Login
   
//   public func login(viewController: UIViewController) async throws -> MsalAuth {
//      return try await withCheckedThrowingContinuation { continuation -> Void in
//         login(viewController: viewController) { auth, error in
//            if let auth = auth {
//               continuation.resume(returning: auth)
//            } else {
//               let error = error ?? .unknownError
//               continuation.resume(throwing: error)
//            }
//         }
//      }
//   }
   
   public func login(viewController: UIViewController, completion: @escaping (MsalAuth?, MsalError?)->()) {
      let webviewParams = MSALWebviewParameters(authPresentationViewController: viewController)
      let parameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webviewParams)
      parameters.completionBlockQueue = DispatchQueue.main
      
      
      msalApplication.acquireToken(with: parameters, completionBlock: { (result, error) in
         guard let result = result, let identifier = result.account.identifier else {
            let msalError = error != nil ? self.mapError(error!) : MsalError.unknownError
            return completion(nil, msalError)
         }
         let auth = MsalAuth(token: result.accessToken, accountId: identifier)
         completion(auth, nil)
      })
   }
   
   public func onOpenUrl(url: URL) {
#if os(iOS)
      MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: nil)
#endif
   }
   
   //Mark: - Refresh
   
//   public func refresh(accountId: String) async throws -> MsalAuth {
//      return try await withCheckedThrowingContinuation { continuation -> Void in
//         refresh(accountId: accountId) { auth, error in
//            if let auth = auth {
//               continuation.resume(returning: auth)
//            } else {
//               let error = error ?? .unknownError
//               continuation.resume(throwing: error)
//            }
//         }
//      }
//   }
   
   public func refresh(accountId: String, completion: @escaping (MsalAuth?, MsalError?)->()) {
      guard let account = try? msalApplication.account(forIdentifier: accountId) else
      { return completion(nil, MsalError.interactionRequired) }
      
      let silentParameters = MSALSilentTokenParameters(scopes: scopes, account: account)
      silentParameters.completionBlockQueue = DispatchQueue.main
      //      silentParameters.forceRefresh = true
      
      msalApplication.acquireTokenSilent(with: silentParameters) { (result, error) in
         guard let result = result, let identifier = result.account.identifier else {
            let msalError = error != nil ? self.mapError(error!) : MsalError.unknownError
            return completion(nil, msalError)
         }
         let auth = MsalAuth(token: result.accessToken, accountId: identifier)
         completion(auth, nil)
      }
   }
   
   public func receiveToken(accountId: String) -> AnyPublisher<String, MsalError> {
      return Deferred {
         Future<String, MsalError> { promise in
            self.refresh(accountId: accountId) { result, error in
               if let auth = result {
                  promise(.success(auth.token))
               }
               else {
                  let msalError = error ?? .unknownError
                  promise(.failure(msalError))
               }
            }
         }
      }.eraseToAnyPublisher()
   }
   
   public func checkIfUserChanged(completion: @escaping (Bool)->()) {
      let msalParameters = MSALParameters()
      msalParameters.completionBlockQueue = DispatchQueue.main
      
      msalApplication.getCurrentAccount(with: msalParameters) { (currentAccount, previousAccount, error) in
         print("Current account: \(String(describing: currentAccount)), Previous account: \(String(describing: previousAccount))")
         completion(currentAccount != previousAccount)
      }
   }
   
   //Mark: - Logout
   
   public func logout(accountId: String, viewController: UIViewController, completion: @escaping (MsalError?)->()) {
      guard let account = try? msalApplication.account(forIdentifier: accountId) else
      { return assertionFailure() }
      
      let webviewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
      let signoutParameters = MSALSignoutParameters(webviewParameters: webviewParameters)
      signoutParameters.signoutFromBrowser = false
      
      msalApplication.signout(with: account, signoutParameters: signoutParameters) { (success, error) in
         if let error = error {
            completion(self.mapError(error))
         } else {
            completion(nil)
         }
      }
   }
   
   public func enableMsalLoggin() {
      MSALGlobalConfig.loggerConfig.setLogCallback { (logLevel, message, containsPII) in
         if let displayableMessage = message {
            if (!containsPII && self.isLoggingEnabled) {
               print(displayableMessage)
            }
         }
      }
   }
   
   //Mark: - Private
   
   private static func makeMsalApplication(clientId: String, authority: String) -> MSALPublicClientApplication {
      do {
         let msalAuthority = try MSALAuthority(url: URL(string: authority)!)
         let msalConfig = MSALPublicClientApplicationConfig(clientId: clientId, redirectUri: nil, authority: msalAuthority)
         return try MSALPublicClientApplication(configuration: msalConfig)
      } catch {
         fatalError()
      }
   }
   
   private func mapError(_ error: Error) -> MsalError {
      guard let error = error as NSError? else { return .unknownError }
      
      if error.domain == MSALErrorDomain, let errorCode = MSALError(rawValue: error.code) {
         switch errorCode
         {
         case .interactionRequired:
            return .interactionRequired
            
         case .serverDeclinedScopes:
            //            let grantedScopes = error.userInfo[MSALGrantedScopesKey]
            let declinedScopes = error.userInfo[MSALDeclinedScopesKey]
            print("MSAL: declined scopes: \(String(describing: declinedScopes))")
            return .unknownError
            
         case .serverProtectionPoliciesRequired:
            // Integrate the Intune SDK and call the
            // remediateComplianceForIdentity:silent: API.
            // Handle this error only if you integrated Intune SDK.
            // See more info here: https://aka.ms/intuneMAMSDK
            print("MSAL: .serverProtectionPoliciesRequired")
            return .unknownError
            
         case .userCanceled:
            return .userCanceled
            
         case .internal:
            print("MSAL: Failed with error \(error)");
            return .unknownError
            
         default:
            print("MSAL: Failed with unknown error: \(error.localizedDescription)")
            return .unknownError
         }
      }
      
      if error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet {
         return .noInternetConnection
      }
      return .unknownError
   }
}
