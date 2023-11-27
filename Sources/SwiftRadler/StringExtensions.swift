import Foundation

public extension String {
   
   func base64Decoded() -> Data? {
      if let decodedData = Data(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0)) {
         return decodedData
      }
      return nil
   }
}
