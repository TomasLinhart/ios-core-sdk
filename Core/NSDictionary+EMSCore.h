//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (EMSCore)

- (BOOL)subsetOfDictionary:(NSDictionary *)dictionary;

- (NSData *)archive;

+ (NSDictionary *)dictionaryWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END