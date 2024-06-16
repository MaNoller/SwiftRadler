import SwiftUI
#if canImport(UIKit)
import UIKit

public struct MSALView: UIViewControllerRepresentable {
   public let controller = MSALViewController()
   
   public init() {}
   
   public func makeUIViewController(context: Context) -> MSALViewController {
      return controller
   }
   
   public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
   }
}

public class MSALViewController: UIViewController {
   init() {
      super.init(nibName: nil, bundle: .main)
   }
   
   required init?(coder: NSCoder) {
      fatalError()
   }
   
   override public func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
   }
}
#elseif canImport(Cocoa)
import Cocoa

public struct MSALView {
   public let controller = NSViewController()
   
   init() { /*NOT YET IMPLEMENTED */ }
}

#endif
