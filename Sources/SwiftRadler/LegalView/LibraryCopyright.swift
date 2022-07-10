import Foundation

public struct LibraryCopyright: Hashable, Identifiable {
   public let id = UUID()
   public let name: String
   public let version: String
   public let license: License
   public let copyright: String
   
   public init(name: String, version: String, license: License, copyright: String) {
      self.name = name
      self.version = version
      self.license = license
      self.copyright = copyright
   }
}
