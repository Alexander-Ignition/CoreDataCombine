import Books
import XCTest

enum TestError: Error {
    case error
}

final class PerformPublisherTests: TestCase {

    func testFetchPublisher() throws {
        let savedIds = try saveBooks().map(\.objectID)

        let fetchedIds = try backgroundContext
            .fetchPublisher(Book.all)
            .wait()
            .single()
            .map(\.objectID)

        XCTAssertEqual(fetchedIds, savedIds)
    }

    func testPublisherWithBlock() throws {
        let savedIds = try saveBooks().map(\.objectID)

        let fetchedIds = try backgroundContext
            .publisher { try Book.all.execute() }
            .wait()
            .single()
            .map(\.objectID)

        XCTAssertEqual(fetchedIds, savedIds)
    }

    func testPublisherWithFailedBlock() {
        let result = viewContext
            .publisher { () -> Book in throw TestError.error }
            .wait()

        XCTAssertEqual(result.output, [])
        XCTAssertTrue(result.error is TestError)
    }
}
