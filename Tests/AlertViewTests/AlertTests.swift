import XCTest
@testable import AlertView

@available(iOS 13, *)
final class AlertTests: XCTestCase {
    
    func testInit() {
        let toast = AlertToast(type: .regular, title: "Title", subTitle: "Subtitle")
        XCTAssertEqual(toast.type, .regular)
        XCTAssertEqual(toast.title, "Title")
        XCTAssertEqual(toast.subTitle, "Subtitle")
    }

    static var allTests = [
        ("testInit", testInit),
    ]
}
