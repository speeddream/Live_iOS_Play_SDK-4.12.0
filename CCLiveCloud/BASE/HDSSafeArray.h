//
//  HDSSafeArray.h
//  CCLiveCloud
//
//  Created by Apple on 2022/5/13.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSSafeArray <__covariant ObjectType> : NSMutableArray
- (id)init;

- (id)firstObject;

- (id)lastObject;

- (id)description;

- (NSUInteger)count;

- (void)addObject:(id)obj;

- (void)addObjectsFromArray:(id)obj;

- (id)objectAtIndex:(NSUInteger)index;

- (void)insertObject:(id)obj index:(NSUInteger)index;

- (void)insertObjects:(id)obj atIndexes:(NSIndexSet *)atIndexes;

- (void)removeAllObjects;

- (void)removeObject:(id)obj;

- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block;

- (NSArray<id> *)sortedArrayUsingComparator:(NSComparator NS_NOESCAPE)cmptr;
- (void)sortUsingComparator:(NSComparator NS_NOESCAPE)cmptr;

- (BOOL)containsObject:(id)obj;

- (NSMutableArray *)container;

@end

NS_ASSUME_NONNULL_END
