//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "FakeLogRepository.h"

@implementation FakeLogRepository

- (void)add:(NSDictionary<NSString *, id> *)item {

}

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification {

}

- (NSArray<NSDictionary<NSString *, id> *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    return nil;
}

- (BOOL)isEmpty {
    return NO;
}

@end