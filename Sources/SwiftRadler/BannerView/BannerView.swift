import SwiftUI

public struct BannerView: View {
   @ObservedObject var controller: BannerController
   
   @State var hasBanner = false
   
   public init(controller: BannerController) {
      self.controller = controller
   }
   
   private func bgColor(for type: BannerType) -> Color {
      switch type {
      case .info:      return Color.gray
      case .success:   return Color.green
      case .error:     return Color.red
      }
   }
   
   private func textColor(for type: BannerType) -> Color {
      switch type {
      case .info:      return Color.white
      case .success:   return Color.black
      case .error:     return Color.black
      }
   }
   
   public var body: some View {
      VStack {
         if hasBanner {
            VStack {
               bannerBox(title: controller.banner?.title ?? "",
                         message: controller.banner?.message ?? "",
                         type: controller.banner?.type ?? .info)
               
               Spacer()
            }
            .transition(AnyTransition.move(edge: .top))
            .onTapGesture {
               withAnimation { controller.hide() }
            }
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
               .onEnded({ value in
                  if value.translation.height < 0 {
                     withAnimation { controller.hide() }
                  }
               }))
         }
      }
      .onChange(of: controller.banner) { (banner) in
         withAnimation { hasBanner = banner != nil }
      }
   }
   
   func bannerBox(title: String, message: String, type: BannerType) -> some View {
      HStack {
         VStack(alignment: .leading, spacing: 2) {
            Text(title)
               .bold()
               .foregroundColor(textColor(for: type))
            Text(message)
               .font(Font.system(size: 15, weight: Font.Weight.light, design: Font.Design.default))
               .foregroundColor(textColor(for: type))
         }
         Spacer()
      }
      .frame(minHeight: 130)
      .foregroundColor(Color.white)
      .padding(12)
      .background(bgColor(for: type))
      .cornerRadius(8)
   }
}
