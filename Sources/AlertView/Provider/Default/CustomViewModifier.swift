import SwiftUI

@available(iOS 13, macOS 11, *)
struct CustomViewModifier: View {
    var body: some View {
        Text("Hello, World!")
    }
}

@available(iOS 13, macOS 11, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        CustomViewModifier()
    }
}
