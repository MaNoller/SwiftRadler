import Foundation
import Network

public class NetworkMonitor {
   private let queue = DispatchQueue(label: "NetworkMonitor")
   private let monitor = NWPathMonitor()
   private var path: NWPath?
   
   public var isConnected: Bool {
      if let path = path {
         return path.status == .satisfied
      }
      return true
   }
   
   public var isExpensive: Bool {
      path?.isExpensive ?? false
   }
   
   public init() {
      monitor.pathUpdateHandler = { path in
         self.path = path
      }
      monitor.start(queue: queue)
   }
}
