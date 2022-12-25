import Foundation
import SwiftUI

public enum LoginError {
   case noInternetConnection
   case authenticationFailure
}

public protocol LoginHandler {
   var scopes: [String] { get }
   var clientId: String { get }
   var authority: String { get }
   
   func login(with auth: MsalAuth, completion: @escaping ()->())
   func refresh(with auth: MsalAuth, completion: @escaping ()->())
   func logout(completion: @escaping ()->())
   func handleError(_ error: LoginError)
}

public class MsalController: ObservableObject {
   private let cancelBag = CancelBag()
   private let msal: MSAL
   private let loginHandler: LoginHandler
   
   //NOTE: This view must be added to the root of your SwiftUI view stack
   public let msalView = MSALView()
   
   @Published private(set) var isLoading = false
   
   public init(loginHandler: LoginHandler, msal: MSAL) {
      self.loginHandler = loginHandler
      self.msal = msal
   }
   
   //Mark: - Login
   
   public func authenticate() {
      //TODO: check internet connection
      //noInternetConnectionError()
      
      isLoading = true
      msal.login(viewController: msalView.controller) { auth, error in
         if let auth = auth {
            self.didAuthenticate(msalAuth: auth)
         } else {
            self.handleError(error ?? MsalError.unknownError)
         }
      }
   }

   private func didAuthenticate(msalAuth: MsalAuth) {
      loginHandler.login(with: msalAuth) {
         self.isLoading = false
      }
   }
   
   public func refresh(accountId: String) {
      //TODO: check internet connection
      //noInternetConnectionError()
      
      isLoading = true
      msal.refresh(accountId: accountId) { auth, error in
         if let auth = auth   {
            self.didRefresh(msalAuth: auth)
         } else {
            self.handleError(error ?? MsalError.unknownError)
         }
      }
   }
   
   private func didRefresh(msalAuth: MsalAuth) {
      loginHandler.refresh(with: msalAuth) {
         self.isLoading = false
      }
   }
   
   public func logout(accountId: String) {
      isLoading = true
      msal.logout(accountId: accountId, viewController: msalView.controller) {_ in
         self.loginHandler.logout() {
            self.isLoading = false
         }
      }
   }
   
   private func handleError(_ error: MsalError) {
      isLoading = false
      
      switch error {
      case .unknownError:           loginHandler.handleError(.authenticationFailure)
      case .noInternetConnection:   loginHandler.handleError(.noInternetConnection)
      case .userCanceled:           break
      case .interactionRequired:    authenticate()
      }
   }

   
   public func checkIfUserChanged(completion: @escaping (Bool)->()) {
      msal.checkIfUserChanged() {
         completion($0)
      }
   }
}
