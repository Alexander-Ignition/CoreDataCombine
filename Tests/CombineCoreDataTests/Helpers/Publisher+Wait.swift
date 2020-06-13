import Combine
import XCTest

/// Result of subscribing to the publisher.
///
/// Similar to `Swift.Result` and `Combine.Record`.
public struct PublisherResult<Output, Failure> where Failure: Error {
    /// Published values.
    public var output: [Output] = []

    /// Failure or finished completion result.
    public var completion: Subscribers.Completion<Failure> = .finished

    /// Published error if failure. Use it for testing errors.
    ///
    ///     let error = URLError(.notConnectedToInternet)
    ///     let result = Fail<Int, URLError>(error: error).wait()
    ///     XCTAssertEqual(result.values, [])
    ///     XCTAssertEqual(result.error, error)
    ///
    public var error: Failure? {
        switch completion {
        case .failure(let error):
            return error
        case .finished:
            return nil
        }
    }

    /// Empty finished result.
    public init() {}

    /// Returns the output values as a throwing expression.
    ///
    ///     let publisher = [1, 2, 3].publisher
    ///     let numbers = try publisher.wait().get() // [1, 2, 3]
    ///
    ///     let error = URLError(.networkConnectionLost)
    ///     let record = Record(output: [1, 2], completion: .failure(error))
    ///     let numbers = try record.wait().get() // assert and error
    ///
    /// - Parameters:
    ///   - file: The file in which the failure occurred. The default is the file name of the test case in which this function was called.
    ///   - line: The line number on which the failure occurred. The default is the line number on which this function was called.
    /// - Throws: The error, if a publisher is failure.
    /// - Returns: The output values, if a publisher is successfully finished.
    public func get(file: StaticString = #file, line: UInt = #line) throws -> [Output] {
        switch completion {
        case .failure(let error):
            XCTFail("\(error)", file: file, line: line)
            throw error
        case .finished:
            return output
        }
    }

    /// Сheck that the result was completed successfully with a single value.
    ///
    ///     try Just(4).wait().single() // 4
    ///     try Empty<Int, Never>().wait().single() // assert fail and error
    ///     try [1, 2, 3].publisher.wait().single() // assert fail
    ///
    /// - Parameters:
    ///   - file: The file in which the failure occurred. The default is the file name of the test case in which this function was called.
    ///   - line: The line number on which the failure occurred. The default is the line number on which this function was called.
    /// - Throws: Publisher error or empty result error.
    /// - Returns: The first outgoing element of the publisher.
    public func single(file: StaticString = #file, line: UInt = #line) throws -> Output {
        let values = try get(file: file, line: line)
        XCTAssertEqual(values.count, 1, file: file, line: line)
        return try XCTUnwrap(values.first, file: file, line: line)
    }
}

extension Publisher {
    /// Wait for the publisher to complete.
    ///
    ///     final class ExampleTests: XCTestCase {
    ///         func testJust() {
    ///             let publisher = Just("Hello")
    ///             let string = try publisher.wait().single()
    ///             XCTAssertEqual(string, "Hello")
    ///         }
    ///     }
    ///
    /// - Warning: Not thread safe!
    /// - Parameters:
    ///   - timeout: The amount of time within which all expectations must be fulfilled.
    ///   - description: A string to display in the test log for this expectation, to help diagnose failures.
    ///   - file: The file in which the failure occurred. The default is the file name of the test case in which this function was called.
    ///   - line: The line number on which the failure occurred. The default is the line number on which this function was called.
    /// - Returns: Result of subscribing to the publisher.
    public func wait(
        timeout: TimeInterval = 5,
        description: String = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) -> PublisherResult<Output, Failure> {

        var result = PublisherResult<Output, Failure>()
        let expectation = XCTestExpectation(description: description)

        let subscription = sink(receiveCompletion: { completion in
            result.completion = completion
            expectation.fulfill()
        }, receiveValue: { value in
            result.output.append(value)
        })
        let waiterResult = XCTWaiter.wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(waiterResult, .completed, file: file, line: line)

        subscription.cancel()
        return result
    }
}
