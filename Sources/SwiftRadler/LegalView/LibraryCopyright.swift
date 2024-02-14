import Foundation

public struct LibraryCopyright: Hashable, Identifiable {
   public let id = UUID()
   public let index: Int
   public let name: String
   public let version: String
   public let license: License
   public let copyright: String
   public let shortName: String?
   public let url: String
   
   public init(index: Int, name: String, shortName: String?, version: String, license: License, copyright: String, url: String) {
      self.index = index
      self.name = name
      self.shortName = shortName ?? nil
      self.version = version
      self.license = license
      self.copyright = copyright
      self.url = url
   }
}
