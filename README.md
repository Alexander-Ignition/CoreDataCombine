# 🚜 CombineCoreData 🗄

[![SPM compatible](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/Alexander-Ignition/OSLogging/blob/master/LICENSE)

- You will no longer need to use method `perform(_:)` directly with `do catch`.
- You can forget about the callback based api when working with CoreData.

> Inspired by [ReactiveCocoa and Core Data Concurrency](https://thoughtbot.com/blog/reactive-core-data)

## Features

- [x] NSManagedObjectContexts produce Publisher
- [x] NSManagedObjectContexts + Scheduler


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

`import CombineCoreData`

Wrap any operation with managed objects in context with method `publisher(_:)`.

> Full examples you can see in *Sources/Books*


### Save objects

Example save books in `backgroundContex`  on background queue.

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

Fetch books in `backgroundContex` on background queue.

```swift
func fetchBooks() -> AnyPublisher<[Book], Error> {
    backgroundContex.fetchPublisher(Book.all).eraseToAnyPublisher()
}
```

##  Scheduler

Many types adopts protocol `Scheduler`, like a `DispatchQueue`, `OperationQueue` and `RunLoop`.

`NSManagedObjectContext` has private queue and schedule task throuth method `perform(_:)`.

Combine provides several schedulers like a DispatchQueue, OperationQueue, RunLoop,  

```swift
import Combine
import CoreData
import CombineCoreData

let subscription = Deferred {
    // Write `Book` on background thread in `backgroundContext`
    Result<NSManagedObjectID, Error> {
        let book = Book(context: self.backgroundContext)
        book.name = "CoreData"
        try self.backgroundContext.save()
        return book.objectID
    }.publisher
}
.subscribe(on: backgroundContext)
.receive(on: viewContext)
.map { (id: NSManagedObjectID) -> Book in
    // Read `Book` on main thread in `viewContext`.
    return self.viewContext.object(with: id) as! Book
}
.sink(
    receiveCompletion: { completion in
        print(completion)
    },
    receiveValue: { (book: Book) in
        // Receive `Book` on main thread in `viewContext`
        print(book)
    })
```
