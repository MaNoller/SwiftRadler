import Foundation
import Combine

public class BannerController: ObservableObject {
   
   public var autoHideTime: TimeInterval = 5
   
   @Published private(set) var banner: BannerData? = nil
   @Published private(set) var lastUsedType = BannerType.info
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
      Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] _ in
         self?.run()
      }
   }
   
   private func run() {
      banner = queue.pop()
      isRunning = banner != nil

      if let banner {
         lastUsedType = banner.type
         Timer.scheduledTimer(withTimeInterval: autoHideTime, repeats: false) { [weak self] _ in
            self?.hide()
         }
      }
   }
}

