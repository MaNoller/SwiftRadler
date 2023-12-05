import SwiftUI

public struct BannerView: View {
   @ObservedObject var controller: BannerController
   
   @State var hasBanner = false
   
   public init(controller: BannerController) {
      self.controller = controller
   }
   
   private func bgColor(for type: BannerType) -> Color {
      switch type {
      case .info:      return Color.blue
      case .success:   return Color.green
      case .error:     return Color.red
      }
   }
   
   private func textColor(for type: BannerType) -> Color {
      switch type {
      case .info:      return Color.black
      case .success:   return Color.black
      case .error:     return Color.black
      }
   }
   
   private func iconName(for type: BannerType) -> String {
      switch type {
      case .info:      return "info.circle"
      case .success:   return "checkmark.circle"
      case .error:     return "exclamationmark.circle"
      }
      
   }
   
   public var body: some View {
      VStack {
         if hasBanner {
            VStack {
               bannerBox(title: controller.banner?.title ?? "",
                         message: controller.banner?.message ?? "",
                         type: controller.banner?.type ?? controller.lastUsedType)
               
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
      .ignoresSafeArea(.all)
   }
   
   func bannerBox(title: String, message: String, type: BannerType) -> some View {
      HStack {
         VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .center) {
               Image(systemName: iconName(for: type))
                  .resizable()
                  .scaledToFit()
                  .frame(width: 25)
                  .foregroundColor(.black)
                  .offset(y: 9)
               Text(title)
                  .bold()
                  .font(.system(size: 20))
                  .foregroundColor(textColor(for: type))
                  .padding(.top)
            }
            Text(message)
               .font(Font.system(size: 15, weight: Font.Weight.light, design: Font.Design.default))
               .foregroundColor(textColor(for: type))
         }
         Spacer()
      }
      .frame(minHeight: 160)
      .foregroundColor(Color.white) 
      .padding(12)
      .background(bgColor(for: type))
   }
}

struct BannerView_Previews: PreviewProvider {
  static var previews: some View {
     BannerView(controller: makeMockBannerController())
  }
}

func makeMockBannerController() -> BannerController {
   let controller = BannerController()
   let msg = "Some message that isn't to short but also not very useful"
   let data = BannerData(title: "Dummy Title", message: msg, type: .error)
   controller.show(banner: data)
   return controller
}
