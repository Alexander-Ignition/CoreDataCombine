import Books
import XCTest

class TestCase: XCTestCase {
    private var container: NSPersistentContainer!
    var viewContext: NSManagedObjectContext { container.viewContext }
    private(set) var backgroundContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        container = NSPersistentContainer(
            name: "Books",
            managedObjectModel: Schema.model
        )
        container.persistentStoreDescriptions.forEach {
            $0.type = NSInMemoryStoreType
        }
        container.loadPersistentStores { storeDescription, error in
            XCTAssertNil(error, "\(storeDescription)")
        }
        backgroundContext = container.newBackgroundContext()
        backgroundContext.name = "com.combine-coredata.tests.background-context"
        viewContext.name = "com.combine-coredata.tests.main-context"
    }

    @discardableResult
    func saveBooks(names: [String] = ["Combine", "CoreData"]) throws -> [Book] {
        let books = names.map { name -> Book in
            let book = Book(context: viewContext)
            book.name = name
            return book
        }
        try viewContext.save()
        return books
    }
}
