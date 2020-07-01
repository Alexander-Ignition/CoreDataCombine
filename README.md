# 🚜 CombineCoreData 🗄

[![SPM compatible](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/Alexander-Ignition/OSLogging/blob/master/LICENSE)

> Inspired by [ReactiveCocoa and Core Data Concurrency](https://thoughtbot.com/blog/reactive-core-data)

- You will no longer need to use method `perform(_:)` directly with `do catch`.
- You can forget about the callback based api when working with CoreData.

## Features

- [x] NSManagedObjectContext produce Publisher
- [x] NSManagedObjectContext + Scheduler


## Instalation

Add dependency to `Package.swift`...

```swift
.package(url: "https://github.com/Alexander-Ignition/CombineCoreData", from: "0.0.2"),
```

... and your target

```swift
.target(name: "ExampleApp", dependencies: ["CombineCoreData"]),
```

## Usage

Wrap any operation with managed objects in context with method `publisher(_:)`.

```swift
import CombineCoreData

managedObjectContext.publisher {
    // do something
}
```

Full examples you can see in [Sources/Books](Sources/Books). This module contains [Book](Sources/Books/Book.swift) and [BookStorage](Sources/Books/BookStorage.swift) that manages books.

### Save objects

Example of asynchronously saving books in а `backgroundContex` on its private queue.

```swift
func saveBooks(names: [String]) -> AnyPublisher<Void, Error> {
    backgroundContex.publisher {
        for name in names {
            let book = Book(context: self.backgroundContex)
            book.name = name
        }
        try self.backgroundContex.save()
    }.eraseToAnyPublisher()
}
```

### Fetch objects

Example of asynchronously fetching books in а `backgroundContex` on its private queue.

```swift
func fetchBooks() -> AnyPublisher<[Book], Error> {
    backgroundContex.fetchPublisher(Book.all).eraseToAnyPublisher()
}
```

## Scheduler

You can use `NSManagedObjectContext` instead of `OperationQeue`, `DispatchQueue` or `RunLoop` with operators `receive(on:)` and `subscribe(on:)`

```swift
let subscription = itemService.load()
    .receive(on: viewContext)
    .sink(receiveCompletion: { completion in
        // Receive `completion` on main queue in `viewContext`
        print(completion)
    }, receiveValue: { (items: [Item]) in
        // Receive `[Item]` on main queue in `viewContext`
        print(book)
    })
```

`CombineCoreData` extends `NSManagedObjectContext` to adapt the `Scheduler` protocol. Because `NSManagedObjectContext` has a private queue and and schedule task through method `perform(_:)`.
