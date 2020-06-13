import Combine
import CoreData
import CombineCoreData
import XCTest

final class SchedulerTests: TestCase {

    func testNow() {
        let scheduler = ImmediateScheduler.shared
        XCTAssertEqual(viewContext.now, scheduler.now)
        XCTAssertEqual(backgroundContext.now, scheduler.now)
        XCTAssertEqual(backgroundContext.now, viewContext.now)
    }

    func testMinimumTolerance() {
        let scheduler = ImmediateScheduler.shared
        XCTAssertEqual(viewContext.minimumTolerance, scheduler.minimumTolerance)
        XCTAssertEqual(backgroundContext.minimumTolerance, scheduler.minimumTolerance)
        XCTAssertEqual(backgroundContext.minimumTolerance, viewContext.minimumTolerance)
    }

    func testSubscribeOn() throws {
        XCTAssertNoThrow(try saveBooks())

        let context = try Just(Book.all)
            .eraseToAnyPublisher()
            .tryMap { try $0.execute().first?.managedObjectContext }
            .subscribe(on: backgroundContext)
            .wait()
            .single()

        XCTAssertEqual(context, backgroundContext)
    }

    func testReceiveOn() throws {
        XCTAssertNoThrow(try saveBooks())

        let context = try Just(Book.all)
            .eraseToAnyPublisher()
            .receive(on: backgroundContext)
            .tryMap { try $0.execute().first?.managedObjectContext }
            .wait()
            .single()

        XCTAssertEqual(context, backgroundContext)
    }
}
