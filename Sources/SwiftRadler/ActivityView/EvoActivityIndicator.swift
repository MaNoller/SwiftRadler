import SwiftUI

public struct EvoActivityIndicator: View {
   
   @State private var isAnimating: Bool = true
   @State private var index: Int = 2
   
   public init() {}
   
   private func start() {
      _ = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
         withAnimation(.easeIn(duration: 0.7)) {
            index = index == 5 ? 0 : index + 1
         }
      }
   }
   
   func opacity(for nocke: Int) -> Double {
      if isAnimating && nocke == 1 {
         return index >= 0 && index < 3 ? 1 : 0
      }
      if isAnimating && nocke == 2 {
         return index >= 1 && index < 4 ? 1 : 0
      }
      if isAnimating && nocke == 3 {
         return index >= 2 && index < 5 ? 1 : 0
      }
      return isAnimating ? 1 : 0
   }
   
   public var body: some View {
      ZStack {
         Image("Nocke_part_0", bundle: .module)
            .resizable()
            .scaledToFit()
            .opacity(opacity(for: 0))
         Image("Nocke_part_1", bundle: .module)
            .resizable()
            .scaledToFit()
            .opacity(opacity(for: 1))
         Image("Nocke_part_2", bundle: .module)
            .resizable()
            .scaledToFit()
            .opacity(opacity(for: 2))
         Image("Nocke_part_3", bundle: .module)
            .resizable()
            .scaledToFit()
            .opacity(opacity(for: 3))
      }
      .onAppear() { start() }
   }
}

struct EvoActivityIndicator_Previews: PreviewProvider {
   static var previews: some View {
      Group {
         EvoActivityIndicator()
            .edgesIgnoringSafeArea(.all)
         EvoActivityIndicator()
            .frame(width: 50, height: 50)
            .edgesIgnoringSafeArea(.all)
         EvoActivityIndicator()
            .frame(width: 200, height: 200)
            .edgesIgnoringSafeArea(.all)
      }
   }
}
