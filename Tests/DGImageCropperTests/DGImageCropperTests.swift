import Testing
@testable import DGImageCropper

@Test func generateRectUseCase() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    let useCase = GenerateRectUseCase(point1: .init(x: 1, y: 3), point2: .init(x: 7, y: 7))
    let rect = useCase.execute()
    
    #expect(rect.width == 6)
    #expect(rect.height == 4)
    #expect(rect.origin == .init(x: 1, y: 3))
}
