import SwiftUI

public struct LibraryCopyrightView: View {
   let libraries: [LibraryCopyright]
   let sectionHeader: String
   
   public init(libraries: [LibraryCopyright], sectionHeader: String) {
      self.libraries = libraries
      self.sectionHeader = sectionHeader
   }
   
   public var body: some View {
      List {
         Section(sectionHeader) {
            LibraryCopyrightView.forEachLibrary(libraries: libraries)
         }
      }
      .listStyle(.plain)
   }
   
   public static func forEachLibrary(libraries: [LibraryCopyright]) -> some View {
      ForEach(libraries) { lib in
         NavigationLink(destination: licenseTextView(library: lib)) {
            libraryRow(library: lib)
         }
      }
   }
   
   private static func libraryRow(library: LibraryCopyright) -> some View {
      VStack(alignment: .leading) {
         Text(library.name)
         Text("Version: \(library.version), License: \(library.license.rawValue)")
         Text(library.copyright)
      }
   }
   
   private static func licenseTextView(library: LibraryCopyright) -> some View {
      ScrollView {
         if (library.shortName != nil) {
            Text(library.name)
               .font(.largeTitle)
               .frame(maxWidth: .infinity, alignment: .leading)
               .padding([.leading, .trailing, .bottom])
         }
         Link(library.url, destination: URL(string: library.url)!)
            .padding([.leading, .trailing, .bottom])
         Text(library.license.readLicenseText(name: library.name))
            .padding([.leading, .trailing, .bottom])
      }
      .navigationTitle(library.shortName ?? library.name)
   }
}

struct SwiftUIView_Previews: PreviewProvider {
   static let libraries = [
      LibraryCopyright(name: "Test Lib 1", shortName: "TL1", version: "1.1.1", license: .mit, copyright: "Copyright (c) Blub GmbH.", url: "https://www.goggle.de"),
      LibraryCopyright(name: "Super Lib", shortName: nil, version: "4.4.2", license: .mit, copyright: "Copyright (c) Blub Corporation.", url: "https://www.goggle.com")
   ]
   
   static var previews: some View {
      LibraryCopyrightView(libraries: libraries, sectionHeader: "Rechtliche Hinweise")
   }
}
