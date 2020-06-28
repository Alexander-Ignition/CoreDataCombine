import CoreData

@objc(Book)
public final class Book: NSManagedObject {
    @NSManaged public var name: String?

    /// Use `try Book.all.execute()` for check context queue.
    public static var all: NSFetchRequest<Book> {
        let fetchRequest = NSFetchRequest<Book>(entityName: "Book")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Book.name, ascending: true)
        ]
        return fetchRequest
    }
}
