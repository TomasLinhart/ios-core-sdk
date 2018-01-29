//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSSQLiteHelper.h"
#import "EMSModelMapperProtocol.h"
#import "EMSSqliteQueueSchemaHandler.h"

#define DEFAULT_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"EMSSQLiteQueueDB.db"]

@interface EMSSQLiteHelper ()

@property(nonatomic, assign) sqlite3 *db;
@property(nonatomic, strong) NSString *dbPath;

@end

@implementation EMSSQLiteHelper

- (instancetype)initWithDefaultDatabase {
    return [self initWithDatabasePath:DEFAULT_DB_PATH schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
}

- (instancetype)initWithDatabasePath:(NSString *)path {
    return [self initWithDatabasePath:path schemaDelegate:nil];
}

- (instancetype)initWithDatabasePath:(NSString *)path
                      schemaDelegate:(id <EMSSQLiteHelperSchemaHandler>)schemaDelegate {
    self = [super init];
    if (self) {
        _dbPath = path;
        _schemaHandler = schemaDelegate;
    }

    return self;
}

- (int)version {
    NSParameterAssert(_db);

    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_db, [@"PRAGMA user_version;" UTF8String], -1, &statement, nil);
    if (result == SQLITE_OK) {
        int version = -2;
        int step = sqlite3_step(statement);
        if (step == SQLITE_ROW) {
            version = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
        return version;
    } else {
        return -1;
    };
}


- (void)open {
    if (sqlite3_open([self.dbPath UTF8String], &_db) == SQLITE_OK) {

        int version = [self version];
        if (version == 0) {
            [self.schemaHandler onCreateWithDbHelper:self];
        } else {
            int newVersion = [self.schemaHandler schemaVersion];
            if (version < newVersion) {
                [self.schemaHandler onUpgradeWithDbHelper:self oldVersion:version newVersion:newVersion];
            }
        }
    }
}

- (void)close {
    sqlite3_close(_db);
    _db = nil;
}


- (BOOL)executeCommand:(NSString *)command {
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, [command UTF8String], -1, &statement, nil) == SQLITE_OK) {
        int value = sqlite3_step(statement);
        sqlite3_finalize(statement);
        return value == SQLITE_ROW || value == SQLITE_DONE;
    }
    return NO;
}

- (BOOL)execute:(NSString *)command withBindBlock:(BindBlock)bindBlock {
    sqlite3_stmt *statement;
    int i = sqlite3_prepare_v2(_db, [command UTF8String], -1, &statement, nil);
    if (i == SQLITE_OK) {
        bindBlock(statement);
        int value = sqlite3_step(statement);
        sqlite3_finalize(statement);
        return value == SQLITE_ROW || value == SQLITE_DONE;
    }
    return NO;
}

- (BOOL)executeCommand:(NSString *)command withValue:(NSString *)value {
    return [self execute:command withBindBlock:^(sqlite3_stmt *statement) {
        sqlite3_bind_text(statement, 1, [value UTF8String], -1, SQLITE_TRANSIENT);
    }];
}

- (BOOL)executeCommand:(NSString *)command withTimeIntervalValue:(NSTimeInterval)value {
    return [self execute:command withBindBlock:^(sqlite3_stmt *statement) {
        sqlite3_bind_double(statement, 1, value);
    }];
}

- (BOOL)insertModel:(id)model
          withQuery:(NSString *)insertSQL
             mapper:(id <EMSModelMapperProtocol>)mapper {
    return [self execute:insertSQL withBindBlock:^(sqlite3_stmt *statement) {
        [mapper bindStatement:statement fromModel:model];
    }];
}

- (NSArray *)executeQuery:(NSString *)query
                   mapper:(id <EMSModelMapperProtocol>)mapper {
    NSMutableArray *models = [NSMutableArray new];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            [models addObject:[mapper modelFromStatement:statement]];
        }
        sqlite3_finalize(statement);
        return [NSArray arrayWithArray:models];
    }
    return nil;
}

@end
