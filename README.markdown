#TIManagedObjectExtensions
*A category on NSManagedObject to facilitate easy fetching and counting of objects with Core Data *  

Tim Isted  
[http://www.timisted.net](http://www.timisted.net)  
Twitter: @[timisted](http://twitter.com/timisted)

##License
TIManagedObjectExtensions are offered under the **MIT** license.

##Summary
`TIManagedObjectExtensions` is a category on `NSManagedObject`, adding one-line code utilities to **subclasses** of `NSManagedObject`, making it easy to:

* Create an instance in a given managed object context (MOC).
* Create a fetch request for a given MOC with optional predicate and/or sort descriptor(s).
* Fetch all instances of an entity in a MOC with optional sort descriptor(s).
* Fetch instances matching a predicate, or predicate format string and arguments.
* Count all instances of an entity in a MOC.
* Count instances matching a predicate, or predicate format string and arguments.

All methods are class methods, prefixed with `ti_` to avoid future conflicts.

##Basic Usage
Copy all the files in the TIManagedObjectExtensions directory into your project.

TIManagedObjectExtensions makes use of a method called `ti_entityName` to get the name of the entity for this class. It takes the name of the class and removes the first two characters, to convert e.g. a classname of `TIEmployee` to an entity name of `Employee`. If your class and entity don't follow this naming convention, you'll need to override `ti_entityName` to return a string with the name of your entity.

TIManagedObjectExtensions currently only works for subclasses of `NSManagedObject`, not `NSManagedObject` itself, because it obviously can't determine the name of the entity (in a class method) for generic `NSManagedObject`. In the future, all methods will have `ti_someMethod:::forEntityName:` equivalents.

The methods in `TIManagedObjectExtensions.h` should all be self explanatory.

To fetch *all* the objects for the current entity:
    NSArray *results;
    NSError *anyError = nil;
    
    results = [TIEmployee ti_allObjectsInManagedObjectContext:someContext error:&anyError];

To fetch all the objects matching a predicate, you can either create the predicate:
    NSPredicate *testPredicate = [NSPredicate predicateWithFormat:@"self.department == %@", someDepartment];
    
    results = [TIEmployee ti_objectsMatchingPredicate:testPredicate
                               inManagedObjectContext:someContext
                                                error:&anyError];

or specify it as a format string:                         
    results = [TIEmployee ti_objectsInManagedObjectContext:someContext
                                                     error:&anyError
                               matchingPredicateWithFormat:@"self.department == %@", someDepartment];

All relevant methods can also take either a single sort descriptor, or an array of sort descriptors:
    NSSortDescriptor *singleDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]
    
    results = [TIEmployee ti_objectsMatchingPredicate:testPredicate
                               inManagedObjectContext:someContext
                                 sortedWithDescriptor:singleDescriptor
                                                error:&anyError];

##To Do List
* Add non-entity-specific versions of all methods