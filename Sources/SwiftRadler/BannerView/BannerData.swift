import Foundation

public enum BannerType: Int, Codable {
   case info, success, error
}

public struct BannerData: Codable, Equatable {
   let id: UUID
   let title: String
   let message: String
   let type: BannerType
   
   public init(title: String, message: String, type: BannerType) {
      self.id = UUID()
      self.title = title
      self.message = message
      self.type = type
   }
}
