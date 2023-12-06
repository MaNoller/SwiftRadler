import Foundation

public struct LibraryCopyright: Hashable, Identifiable {
   public let id = UUID()
   public let name: String
   public let version: String
   public let license: License
   public let copyright: String
   public let shortName: String?
   
   public init(name: String, shortName: String?, version: String, license: License, copyright: String) {
      self.name = name
      self.shortName = shortName ?? nil
      self.version = version
      self.license = license
      self.copyright = copyright
   }
}
