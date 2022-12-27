import Foundation
import SwiftUI
import Network

public enum LoginError {
   case noInternetConnection
   case authenticationFailure
}

public protocol LoginHandler {
   func login(with auth: MsalAuth, completion: @escaping ()->())
   func refresh(with auth: MsalAuth, completion: @escaping ()->())
   func logout(completion: @escaping ()->())
   func handleError(_ error: LoginError)
}

public class MsalController: ObservableObject {
   private let cancelBag = CancelBag()
   private let loginHandler: LoginHandler
   private let networkMonitor = NWPathMonitor()
   
   //NOTE: This view must be added to the root of your SwiftUI view stack
   public let msalView = MSALView()
   public let msal: MSAL
   
   var hasInternetConnection: Bool {
      networkMonitor.currentPath.status == .satisfied
   }
   
   @Published public private(set) var isLoading = false
   
   public init(loginHandler: LoginHandler, msal: MSAL) {
      self.loginHandler = loginHandler
      self.msal = msal
   }
   
   //Mark: - Login
   
   public func authenticate() {
      guard hasInternetConnection else
      { return loginHandler.handleError(.noInternetConnection) }
      
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
      guard hasInternetConnection else
      { return loginHandler.handleError(.noInternetConnection) }
      
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
