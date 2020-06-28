import CoreData

public enum Schema {
    /// Swift package manager not support *.xcdatamodel files.
    public static let model = NSManagedObjectModel().apply {
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
