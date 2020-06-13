import CoreData

@objc(Book)
final class Book: NSManagedObject {
    @NSManaged var name: String?

    static var all: NSFetchRequest<Book> {
        NSFetchRequest<Book>(entityName: "Book").apply {
            $0.sortDescriptors = [
                NSSortDescriptor(keyPath: \Book.name, ascending: true)
            ]
        }
    }
}

enum Schema {
    /// Swift package manager not support *.xcdatamodel files.
    static let model = NSManagedObjectModel().apply {
        $0.entities = [book]
    }

    private static let book = NSEntityDescription().apply {
        $0.name = "Book"
        $0.managedObjectClassName = $0.name
        $0.properties = [
            NSAttributeDescription().apply {
                $0.attributeType = .stringAttributeType
                $0.name = "name"
            }
        ]
    }
}

extension NSObjectProtocol {
    func apply(configure: (Self) -> Void) -> Self {
        configure(self)
        return self
    }
}
