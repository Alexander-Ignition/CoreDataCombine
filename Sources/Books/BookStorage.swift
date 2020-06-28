import Combine
import CoreData
import CombineCoreData

final class BookStorage {
    let backgroundContex: NSManagedObjectContext

    init(backgroundContex: NSManagedObjectContext) {
        self.backgroundContex = backgroundContex
    }

    func rename(_ name: String, book: Book) -> AnyCancellable {
        return URLSession.shared
            .dataTaskPublisher(for: URL(string: "https://api.example")!)
            .map(\.data)
            .map { String(data: $0, encoding: .utf8) }
            .replaceError(with: book.name)
            .receive(on: book.managedObjectContext!)
            .assign(to: \.name, on: book)
    }
}

// MARK: - Save books

extension BookStorage {
    func saveBooks(names: [String], completion: @escaping (Error?) -> Void) {
        backgroundContex.perform {
            for name in names {
                let book = Book(context: self.backgroundContex)
                book.name = name
            }
            do {
                try self.backgroundContex.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}

extension BookStorage {
    func saveBooks(names: [String]) -> AnyPublisher<Void, Error> {
        backgroundContex.publisher {
            for name in names {
                let book = Book(context: self.backgroundContex)
                book.name = name
            }
            try self.backgroundContex.save()
        }.eraseToAnyPublisher()
    }
}

// MARK: - Fetch books

extension BookStorage {
    func fetchBooks(completion: @escaping (Result<[Book], Error>) -> Void) {
        backgroundContex.perform {
            do {
                let books = try self.backgroundContex.fetch(Book.all)
                completion(.success(books))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

extension BookStorage {
    func fetchBooks() -> AnyPublisher<[Book], Error> {
        backgroundContex.fetchPublisher(Book.all).eraseToAnyPublisher()
    }
}
