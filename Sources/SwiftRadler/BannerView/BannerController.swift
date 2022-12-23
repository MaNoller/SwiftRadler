import Foundation
import Combine

public class BannerController: ObservableObject {
   
   @Published private(set) var banner: BannerData? = nil
   @Published private(set) var isRunning = false
   
   private var queue = Queue<BannerData>()

   public init() {
   }
   
   public func show(banner: BannerData) {
      queue.push(banner)
      if (!isRunning) {
         run()
      }
   }
   
   public func hide() {
      banner = nil
      Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
         self?.run()
      }
   }
   
   private func run() {
      guard !isRunning else { return }
      
      banner = queue.pop()
      isRunning = banner != nil
      
      if banner != nil {
         Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            self?.hide()
         }
      }
   }
}

