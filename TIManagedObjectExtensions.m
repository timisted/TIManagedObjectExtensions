// Copyright (c) 2010 Tim Isted
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "TIManagedObjectExtensions.h"

@implementation NSManagedObject (TIManagedObjectExtensions)

#pragma mark 
#pragma mark Entity Information
+ (NSString *)ti_entityName
{
    NSString *nameOfClass = NSStringFromClass([self class]);
    return [nameOfClass substringFromIndex:2];
}

+ (NSEntityDescription *)ti_entityDescriptionInManagedObjectContext:(NSManagedObjectContext *)aContext
{
    return [NSEntityDescription entityForName:[self ti_entityName] inManagedObjectContext:aContext];
}

#pragma mark -
#pragma mark Creating Objects
+ (id)ti_objectInManagedObjectContext:(NSManagedObjectContext *)aContext
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self ti_entityName] inManagedObjectContext:aContext];
}

#pragma mark -
#pragma mark Fetch Requests
+ (NSFetchRequest *)ti_fetchRequestInManagedObjectContext:(NSManagedObjectContext *)aContext
{
    return [self ti_fetchRequestWithPredicate:nil inManagedObjectContext:aContext];
}

+ (NSFetchRequest *)ti_fetchRequestWithPredicate:(NSPredicate *)aPredicate inManagedObjectContext:(NSManagedObjectContext *)aContext
{
    return [self ti_fetchRequestWithPredicate:aPredicate inManagedObjectContext:aContext sortedWithDescriptors:nil];
}

+ (NSFetchRequest *)ti_fetchRequestWithPredicate:(NSPredicate *)aPredicate inManagedObjectContext:(NSManagedObjectContext *)aContext sortedWithDescriptor:(NSSortDescriptor *)aDescriptor
{
    NSArray *sortDescriptors = nil;
    if( aDescriptor ) sortDescriptors = [NSArray arrayWithObject:aDescriptor];
    
    return [self ti_fetchRequestWithPredicate:aPredicate inManagedObjectContext:aContext sortedWithDescriptors:sortDescriptors];
}

+ (NSFetchRequest *)ti_fetchRequestWithPredicate:(NSPredicate *)aPredicate inManagedObjectContext:(NSManagedObjectContext *)aContext sortedWithDescriptors:(NSArray *)someDescriptors
{
    NSFetchRequest *requestToReturn = [[NSFetchRequest alloc] init];
    [requestToReturn setEntity:[self ti_entityDescriptionInManagedObjectContext:aContext]];
    
    if( aPredicate ) [requestToReturn setPredicate:aPredicate];
    if( someDescriptors ) [requestToReturn setSortDescriptors:someDescriptors];
    
    return [requestToReturn autorelease];
}

+ (NSFetchRequest *)ti_fetchRequestInManagedObjectContext:(NSManagedObjectContext *)aContext withPredicateWithFormat:(NSString *)aFormat, ...
{
    va_list args;
    va_start(args, aFormat);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:aFormat arguments:args];
    va_end(args);
    
    return [self ti_fetchRequestWithPredicate:predicate inManagedObjectContext:aContext];
}
#pragma mark -
#pragma mark Counting Objects
+ (int)ti_numberOfObjectsInManagedObjectContext:(NSManagedObjectContext *)aContext error:(NSError **)outError
{
    return [self ti_numberOfObjectsMatchingPredicate:nil inManagedObjectContext:aContext error:outError];
}

+ (int)ti_numberOfObjectsMatchingPredicate:(NSPredicate *)aPredicate inManagedObjectContext:(NSManagedObjectContext *)aContext error:(NSError **)outError
{
    NSFetchRequest *countRequest = [self ti_fetchRequestWithPredicate:aPredicate inManagedObjectContext:aContext];
    
    NSError *anyError = nil;
    NSUInteger count = [aContext countForFetchRequest:countRequest error:&anyError];
    
    if( outError && anyError ) *outError = anyError;
    
    return count;
}

+ (int)ti_numberOfObjectsInManagedObjectContext:(NSManagedObjectContext *)aContext error:(NSError **)outError matchingPredicateWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSPredicate *thePredicate = [NSPredicate predicateWithFormat:format arguments:args];
    va_end(args);
    
    return [self ti_numberOfObjectsMatchingPredicate:thePredicate inManagedObjectContext:aContext error:outError];
}

#pragma mark -
#pragma mark Fetching Objects
#pragma mark - All Objects
+ (NSArray *)ti_allObjectsInManagedObjectContext:(NSManagedObjectContext *)aContext sortedWithDescriptor:(NSSortDescriptor *)aDescriptor error:(NSError **)outError
{
    return [self ti_objectsMatchingPredicate:nil inManagedObjectContext:aContext sortedWithDescriptor:aDescriptor error:outError];
}

+ (NSArray *)ti_allObjectsInManagedObjectContext:(NSManagedObjectContext *)aContext sortedWithDescriptors:(NSArray *)someDescriptors error:(NSError **)outError
{
    return [self ti_objectsMatchingPredicate:nil inManagedObjectContext:aContext sortedWithDescriptors:someDescriptors error:outError];
}

+ (NSArray *)ti_allObjectsInManagedObjectContext:(NSManagedObjectContext *)aContext error:(NSError **)outError
{
    return [self ti_allObjectsInManagedObjectContext:aContext sortedWithDescriptor:nil error:outError];
}

#pragma mark - Matching Predicate
+ (NSArray *)ti_objectsMatchingPredicate:(NSPredicate *)aPredicate inManagedObjectContext:(NSManagedObjectContext *)aContext sortedWithDescriptors:(NSArray *)someDescriptors error:(NSError **)outError
{
    NSError *anyError = nil;
    
    NSFetchRequest *request = [self ti_fetchRequestWithPredicate:aPredicate inManagedObjectContext:aContext sortedWithDescriptors:someDescriptors];
    
    NSArray *results = [aContext executeFetchRequest:request error:&anyError];
    
    if( !results && outError )
        *outError = anyError;
    
    return results;
}

+ (NSArray *)ti_objectsMatchingPredicate:(NSPredicate *)aPredicate inManagedObjectContext:(NSManagedObjectContext *)aContext sortedWithDescriptor:(NSSortDescriptor *)aDescriptor error:(NSError **)outError
{
    NSArray *sortDescriptors = nil;
    if( aDescriptor ) sortDescriptors = [NSArray arrayWithObject:aDescriptor];
    
    return [self ti_objectsMatchingPredicate:aPredicate inManagedObjectContext:aContext sortedWithDescriptors:sortDescriptors error:outError];
}

+ (NSArray *)ti_objectsMatchingPredicate:(NSPredicate *)aPredicate inManagedObjectContext:(NSManagedObjectContext *)aContext error:(NSError **)outError
{
    return [self ti_objectsMatchingPredicate:aPredicate inManagedObjectContext:aContext sortedWithDescriptors:nil error:outError];
}

+ (NSArray *)ti_objectsInManagedObjectContext:(NSManagedObjectContext *)aContext error:(NSError **)outError matchingPredicateWithFormat:(NSString *)aFormat, ...
{
    va_list args;
    va_start(args, aFormat);
    NSPredicate *thePredicate = [NSPredicate predicateWithFormat:aFormat arguments:args];
    va_end(args);
    
    return [self ti_objectsMatchingPredicate:thePredicate inManagedObjectContext:aContext error:outError];
}

+ (NSArray *)ti_objectsInManagedObjectContext:(NSManagedObjectContext *)aContext sortedWithDescriptor:(NSSortDescriptor *)aDescriptor error:(NSError **)outError matchingPredicateWithFormat:(NSString *)aFormat, ...
{
    va_list args;
    va_start(args, aFormat);
    NSPredicate *thePredicate = [NSPredicate predicateWithFormat:aFormat arguments:args];
    va_end(args);
    
    return [self ti_objectsMatchingPredicate:thePredicate inManagedObjectContext:aContext sortedWithDescriptor:aDescriptor error:outError];
}

+ (NSArray *)ti_objectsInManagedObjectContext:(NSManagedObjectContext *)aContext sortedWithDescriptors:(NSArray *)someDescriptors error:(NSError **)outError matchingPredicateWithFormat:(NSString *)aFormat, ...
{
    va_list args;
    va_start(args, aFormat);
    NSPredicate *thePredicate = [NSPredicate predicateWithFormat:aFormat arguments:args];
    va_end(args);
    
    return [self ti_objectsMatchingPredicate:thePredicate inManagedObjectContext:aContext sortedWithDescriptors:someDescriptors error:outError];
}


@end