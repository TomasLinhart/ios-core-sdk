//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

typedef void(^BindBlock)(sqlite3_stmt *statement);

@class EMSSQLiteHelper;
@protocol EMSModelMapperProtocol;

@protocol EMSSQLiteHelperSchemaHandler

- (void)onCreateWithDbHelper:(EMSSQLiteHelper *)dbHelper;

- (void)onUpgradeWithDbHelper:(EMSSQLiteHelper *)dbHelper oldVersion:(int)oldVersion newVersion:(int)newVersion;

- (int)schemaVersion;

@end

@interface EMSSQLiteHelper : NSObject

@property(nonatomic, strong) id <EMSSQLiteHelperSchemaHandler> schemaHandler;

- (instancetype)initWithDefaultDatabase;

- (instancetype)initWithDatabasePath:(NSString *)path;

- (instancetype)initWithDatabasePath:(NSString *)path schemaDelegate:(id <EMSSQLiteHelperSchemaHandler>)schemaDelegate;

- (int)version;

- (void)open;

- (void)close;

- (BOOL)executeCommand:(NSString *)command;

- (BOOL)executeCommand:(NSString *)command
             withValue:(NSString *)value;

- (BOOL)executeCommand:(NSString *)command
             withTimeIntervalValue:(NSTimeInterval)value;

- (BOOL)execute:(NSString *)command withBindBlock:(BindBlock)bindBlock;

- (NSArray *)executeQuery:(NSString *)query mapper:(id <EMSModelMapperProtocol>)mapper;

- (BOOL)insertModel:(id)model
          withQuery:(NSString *)insertSQL
             mapper:(id <EMSModelMapperProtocol>)mapper;

@end