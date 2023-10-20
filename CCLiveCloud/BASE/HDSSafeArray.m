//
//  HDSSafeArray.m
//  CCLiveCloud
//
//  Created by Apple on 2022/5/13.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSSafeArray.h"

@interface HDSSafeArray ()
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableArray *container;
@end

@implementation HDSSafeArray

- (id)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("hds_safe_array", NULL);
        self.container = [NSMutableArray array];
    }
    return self;
}

- (id)firstObject {
    __block id t;
    dispatch_barrier_sync(self.queue, ^{
        t = self.container.firstObject;
    });
    
    return t;
}

- (id)lastObject {
    __block id t;
    dispatch_barrier_sync(self.queue, ^{
        t = self.container.lastObject;
    });
    
    return t;
}

- (id)description {
    __block id t;
    dispatch_barrier_sync(self.queue, ^{
        t = [self.container description];
    });
    
    return t;
}

- (NSUInteger)count {
    __block NSUInteger t;
    dispatch_barrier_sync(self.queue, ^{
        t = [self.container count];
    });
    
    return t;
}

- (void)addObject:(id)obj {
    dispatch_barrier_sync(self.queue, ^{
        [self.container addObject:obj];
    });
}

- (void)addObjectsFromArray:(id)obj {
    dispatch_barrier_sync(self.queue, ^{
        [self.container addObjectsFromArray:obj];
    });
}

- (void)insertObject:(id)obj index:(NSUInteger)index {
    dispatch_barrier_sync(self.queue, ^{
        [self.container insertObject:obj atIndex:index];
    });
}

- (void)insertObjects:(id)obj atIndexes:(NSIndexSet *)atIndexes {
    dispatch_barrier_sync(self.queue, ^{
        [self.container insertObjects:obj atIndexes:atIndexes];
    });
}

- (void)removeAllObjects {
    dispatch_barrier_sync(self.queue, ^{
        [self.container removeAllObjects];
    });
}

- (void)removeObject:(id)obj {
    dispatch_barrier_sync(self.queue, ^{
        [self.container removeObject:obj];
    });
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    dispatch_barrier_sync(self.queue, ^{
        [self.container removeObjectAtIndex:index];
    });
}

- (id)objectAtIndex:(NSUInteger)index {
    __block id t;
    dispatch_barrier_sync(self.queue, ^{
        t = [self.container objectAtIndex:index];
    });
    
    return t;
}

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block {
    dispatch_barrier_sync(self.queue, ^{
        [self.container enumerateObjectsUsingBlock:block];
    });
}

- (NSArray<id> *)sortedArrayUsingComparator:(NSComparator NS_NOESCAPE)cmptr {
    __block NSArray<id> *t;
    dispatch_barrier_sync(self.queue, ^{
        t = [self.container sortedArrayUsingComparator:cmptr];
    });
    return t;
}

- (void)sortUsingComparator:(NSComparator NS_NOESCAPE)cmptr {
    dispatch_barrier_sync(self.queue, ^{
        [self.container sortUsingComparator:cmptr];
    });
}

- (BOOL)containsObject:(id)obj {
    __block BOOL t;
    dispatch_barrier_sync(self.queue, ^{
        t = [self.container containsObject:obj];
    });
    return t;
}

@end
