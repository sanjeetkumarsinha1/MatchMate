import Foundation
import CoreData

@objc(MatchEntity)
public class MatchEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchEntity> {
        return NSFetchRequest<MatchEntity>(entityName: "MatchEntity")
    }

    @NSManaged public var id: String
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var age: Int16
    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var thumbnailURL: String?
    @NSManaged public var status: String?
    @NSManaged public var pendingSync: Bool
    @NSManaged public var page: Int16
    @NSManaged public var createdAt: Date?
}
