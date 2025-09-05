import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    let container: NSPersistentContainer

    // Exposed init for tests
    init(inMemory: Bool = false) {
        // Programmatic model to avoid .xcdatamodeld file dependency
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "MatchEntity"
        entity.managedObjectClassName = "MatchEntity"

        func attr(_ name: String, _ type: NSAttributeType, optional: Bool = true) -> NSAttributeDescription {
            let a = NSAttributeDescription(); a.name = name; a.attributeType = type; a.isOptional = optional; return a
        }
        entity.properties = [
            attr("id", .stringAttributeType, optional: false),
            attr("firstName", .stringAttributeType),
            attr("lastName", .stringAttributeType),
            attr("age", .integer16AttributeType),
            attr("city", .stringAttributeType),
            attr("country", .stringAttributeType),
            attr("thumbnailURL", .stringAttributeType),
            attr("status", .stringAttributeType),
            attr("pendingSync", .booleanAttributeType),
            attr("page", .integer16AttributeType),
            attr("createdAt", .dateAttributeType)
        ]
        model.entities = [entity]

        container = NSPersistentContainer(name: "MatchMate", managedObjectModel: model)
        if inMemory {
            let desc = NSPersistentStoreDescription()
            desc.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [desc]
        }
        container.loadPersistentStores { desc, error in
            if let e = error { fatalError("Core Data store failed: \(e)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func saveContext() {
        let ctx = container.viewContext
        if ctx.hasChanges {
            try? ctx.save()
        }
    }
}
