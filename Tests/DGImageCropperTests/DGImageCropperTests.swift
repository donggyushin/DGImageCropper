import Testing
@testable import DGImageCropper

@Test func generateRectUseCase() async throws {
    let useCase = GenerateRectUseCase(point1: .init(x: 1, y: 3), point2: .init(x: 7, y: 7))
    let rect = useCase.execute()
    
    #expect(rect.width == 6)
    #expect(rect.height == 4)
    #expect(rect.origin == .init(x: 1, y: 3))
}

@Test
func checkDraggableUseCase() async throws {
    #expect(CheckDraggableUseCase(point1: .zero, point2: .init(x: 4, y: 4), minDiff: 2).execute() == true)
    #expect(CheckDraggableUseCase(point1: .zero, point2: .init(x: 4, y: 4), minDiff: 3).execute() == true)
    #expect(CheckDraggableUseCase(point1: .zero, point2: .init(x: 4, y: 4), minDiff: 4).execute() == false)
    #expect(CheckDraggableUseCase(point1: .zero, point2: .init(x: 4, y: 4), minDiff: 5).execute() == false)
}
