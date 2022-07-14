import SwiftUI

public struct ActivityOverlay: View {
   let message: String
   
   public init(message: String = "") {
      self.message = message
   }
   
   public var body: some View {
      ZStack {
         Rectangle()
            .foregroundColor(Color.black)
            .opacity(0.8)
            .edgesIgnoringSafeArea(.all)
         
         VStack {
            EvoActivityIndicator()
               .frame(width: 80, height: 80)
            
            Text(message)
               .foregroundColor(Color.white)
               .padding()
         }
      }
   }
}

struct ActivityOverlay_Previews: PreviewProvider {
   static var previews: some View {
      ActivityOverlay(message: "processing...")
      
   }
}
