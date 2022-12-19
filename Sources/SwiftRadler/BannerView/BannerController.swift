import Foundation
import Combine

public class BannerController: ObservableObject {
   
//   private let cancelBag = CancelBag()
   @Published private(set) var banner: BannerData? = nil
   
   private var queue = Queue<BannerData>()
   private var timer: Timer? = nil
   private var isRunning: Bool { return banner != nil }

   public init() {}
   
   public func show(banner: BannerData) {
      queue.push(banner)
      run()
   }
   
   public func hide() {
      timer?.invalidate()
      timer = nil
      banner = nil
      run()
   }
   
   private func run() {
      guard !isRunning else { return }
      
      banner = queue.pop()
      if banner != nil {
         timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) {_ in
            self.hide()
         }
      }
   }
}

