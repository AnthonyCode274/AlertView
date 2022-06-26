import SwiftUI
import Combine

@available(iOS 13, macOS 11, *)
public struct AlertToast: View {
    
    public enum DirectionAnimation {
        case topBottom, leftRight, bottomTop, rightLeft
    }
    
    public enum AlignmentToast {
        case top, center, bottom
    }
    
    public enum BannerAnimation{
        case slide, pop
    }
    
    /// Determine what the alert will display
    public enum AlertType: Equatable{
        
        ///Animated checkmark
        case complete(_ color: Color)
        
        ///Animated xmark
        case error(_ color: Color)
        
        ///System image from `SFSymbols`
        case systemImage(_ name: String, _ color: Color)
        
        ///Image from Assets
        case image(_ name: String, _ color: Color)
        
        ///Loading indicator (Circular)
        case loading
        
        ///Only text alert
        case regular
    }
    
    /// Customize Alert Appearance
    public enum AlertStyle: Equatable{
        
        case style(backgroundColor: Color? = nil,
                   titleColor: Color? = nil,
                   subTitleColor: Color? = nil,
                   titleFont: Font? = nil,
                   subTitleFont: Font? = nil)
        
        ///Get background color
        var backgroundColor: Color? {
            switch self{
            case .style(backgroundColor: let color, _, _, _, _):
                return color
            }
        }
        
        /// Get title color
        var titleColor: Color? {
            switch self{
            case .style(_,let color, _,_,_):
                return color
            }
        }
        
        /// Get subTitle color
        var subtitleColor: Color? {
            switch self{
            case .style(_,_, let color, _,_):
                return color
            }
        }
        
        /// Get title font
        var titleFont: Font? {
            switch self {
            case .style(_, _, _, titleFont: let font, _):
                return font
            }
        }
        
        /// Get subTitle font
        var subTitleFont: Font? {
            switch self {
            case .style(_, _, _, _, subTitleFont: let font):
                return font
            }
        }
    }
    
    ///Customize your alert appearance
    public var style: AlertStyle? = nil
    
    ///What the alert would show
    ///`complete`, `error`, `systemImage`, `image`, `loading`, `regular`
    public var type: AlertType
    
    ///The title of the alert (`Optional(String)`)
    public var title: String? = nil
    
    ///The subtitle of the alert (`Optional(String)`)
    public var subTitle: String? = nil
    
    public var body: some View {
        self.toast
    }
    
    public var toast: some View{
        Group{
            HStack(spacing: 16){
                switch type{
                case .complete(let color):
                    Image(systemName: "checkmark")
                        .hudModifier()
                        .foregroundColor(color)
                case .error(let color):
                    Image(systemName: "xmark")
                        .hudModifier()
                        .foregroundColor(color)
                case .systemImage(let name, let color):
                    Image(systemName: name)
                        .hudModifier()
                        .foregroundColor(color)
                case .image(let name, let color):
                    Image(name)
                        .hudModifier()
                        .foregroundColor(color)
                case .loading:
                    ActivityIndicator()
                case .regular:
                    EmptyView()
                }
                
                if title != nil || subTitle != nil{
                    VStack(alignment: type == .regular ? .center : .leading, spacing: 2){
                        if title != nil{
                            Text(LocalizedStringKey(title ?? ""))
                                .font(style?.titleFont ?? Font.body.bold())
                                .multilineTextAlignment(.center)
                                .textColor(style?.titleColor ?? nil)
                        }
                        if subTitle != nil{
                            Text(LocalizedStringKey(subTitle ?? ""))
                                .font(style?.subTitleFont ?? Font.footnote)
                                .opacity(0.7)
                                .multilineTextAlignment(.center)
                                .textColor(style?.subtitleColor ?? nil)
                        }
                    }
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .frame(minHeight: 50)
            .alertBackground(style?.backgroundColor ?? nil)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 6)
            .compositingGroup()
        }
        .padding(.top)
    }
}

@available(iOS 13, macOS 11, *)
public struct AlertToastModifier: ViewModifier{
    
    ///Presentation `Binding<Bool>`
    @Binding var isPresenting: Bool
    
    ///Duration time to display the alert
    @State var duration: Double = 2
    
    ///Tap to dismiss alert
    @State var tapToDismiss: Bool = true
    
    var offsetY: CGFloat = 0
    
    ///Init `AlertToast` View
    var alertToast: () -> AlertToast
    
    ///Completion block returns `true` after dismiss
    var onTap: (() -> ())? = nil
    var completion: (() -> ())? = nil
    
    @State private var workItem: DispatchWorkItem?
    
    @State private var hostRect: CGRect = .zero
    @State private var alertRect: CGRect = .zero
    
    private var screen: CGRect {
#if os(iOS)
        return UIScreen.main.bounds
#else
        return NSScreen.main?.frame ?? .zero
#endif
    }
    
    private var offset: CGFloat{
#if os(iOS)
        return -hostRect.midY + alertRect.height
#else
        return (-hostRect.midY + screen.midY) + alertRect.height
#endif
    }
    
    @ViewBuilder
    public func main() -> some View{
        if isPresenting{
            alertToast()
                .overlay(
                    GeometryReader{ geo -> AnyView in
                        let rect = geo.frame(in: .global)
                        
                        if rect.integral != alertRect.integral{
                            
                            DispatchQueue.main.async {
                                
                                self.alertRect = rect
                            }
                        }
                        return AnyView(EmptyView())
                    }
                )
                .onTapGesture {
                    onTap?()
                    if tapToDismiss{
                        withAnimation(Animation.spring()){
                            self.workItem?.cancel()
                            isPresenting = false
                            self.workItem = nil
                        }
                    }
                }
                .onDisappear(perform: {
                    completion?()
                })
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
        }
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader{ geo -> Color in
                    let rect = geo.frame(in: .global)
                    
                    if rect.integral != hostRect.integral{
                        DispatchQueue.main.async {
                            self.hostRect = rect
                        }
                    }
                    
                    return Color.clear
                }
                    .overlay(ZStack{
                        main()
                            .offset(y: offsetY)
                    }
                                .frame(maxWidth: screen.width, maxHeight: screen.height)
                                .offset(y: offset)
                                .animation(Animation.spring(), value: isPresenting))
            )
            .valueChanged(value: isPresenting, onChange: { (presented) in
                if presented{
                    onAppearAction()
                }
            })
        
    }
    
    private func onAppearAction(){
        if alertToast().type == .loading{
            duration = 0
            tapToDismiss = false
        }
        
        if duration > 0{
            workItem?.cancel()
            
            let task = DispatchWorkItem {
                withAnimation(Animation.spring()){
                    isPresenting = false
                    workItem = nil
                }
            }
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
        }
    }
}

@available(iOS 13, macOS 11, *)
public extension View{
    /// Choose the alert background
    /// - Parameter color: Some Color, if `nil` return `VisualEffectBlur`
    /// - Returns: some View
    fileprivate func alertBackground(_ color: Color? = nil) -> some View{
        modifier(BackgroundModifier(color: color))
    }
    
    /// Choose the alert background
    /// - Parameter color: Some Color, if `nil` return `.black`/`.white` depends on system theme
    /// - Returns: some View
    fileprivate func textColor(_ color: Color? = nil) -> some View{
        modifier(TextForegroundModifier(color: color))
    }
    
    @ViewBuilder fileprivate func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { (value) in
                onChange(value)
            }
        }
    }
    
}

@available(iOS 13, macOS 11, *)
struct AlertToast_Previews: PreviewProvider {
    static var previews: some View {
        AlertToast(type: .regular, title: "Title", subTitle: "Subtitle")
    }
}
