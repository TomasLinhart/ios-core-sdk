//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSQueueProtocol.h"
#import "EMSSQLiteQueue.h"
#import "EMSRequestModelBuilder.h"
#import "EMSSQLiteHelper.h"
#import "EMSSqliteQueueSchemaHandler.h"

#define TEST_DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TestDB.db"]

SPEC_BEGIN(SQLiteQueueTests)

    beforeEach(^{
        [[NSFileManager defaultManager] removeItemAtPath:TEST_DB_PATH
                                                   error:nil];
    });


    id (^requestModel)(NSString *url, NSDictionary *payload) = ^id(NSString *url, NSDictionary *payload) {
        return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:url];
            [builder setMethod:HTTPMethodPOST];
            [builder setPayload:payload];
        }];
    };

    id (^createQueue)() = ^id <EMSQueueProtocol>() {
        EMSSQLiteHelper *helper = [[EMSSQLiteHelper alloc] initWithDatabasePath:TEST_DB_PATH
                                                                 schemaDelegate:[EMSSqliteQueueSchemaHandler new]];
        return [[EMSSQLiteQueue alloc] initWithSQLiteHelper:helper];
    };
    describe(@"pop", ^{
        it(@"should return nil when the queue is isEmpty", ^{
            id <EMSQueueProtocol> queue = createQueue();

            [[[queue pop] should] beNil];
        });
    });

    describe(@"push:", ^{
        it(@"should assert for nil parameter", ^{
            id <EMSQueueProtocol> queue = createQueue();
            @try {
                [queue push:nil];
                fail(@"Expected Exception when model is nil!");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });
    });

    describe(@"push:", ^{
        it(@"should add an item to the queue", ^{
            id <EMSQueueProtocol> queue = createQueue();

            EMSRequestModel *firstModel = requestModel(@"https://url1.com", nil);
            [queue push:firstModel];

            [[[queue pop] should] equal:firstModel];
        });
    });

    describe(@"pushAndPop", ^{
        it(@"should keep the order of the elements", ^{
            id <EMSQueueProtocol> queue = createQueue();

            EMSRequestModel *firstModel = requestModel(@"https://url1.com", nil);
            EMSRequestModel *secondModel = requestModel(@"https://url2.com", nil);

            [queue push:firstModel];
            [queue push:secondModel];

            [[[queue pop] should] equal:firstModel];
            [[[queue pop] should] equal:secondModel];
            [[theValue([queue isEmpty]) should] beTrue];
        });
    });

    describe(@"peek", ^{
        it(@"should return the first added element from the queue", ^{
            id <EMSQueueProtocol> queue = createQueue();

            EMSRequestModel *firstModel = requestModel(@"https://url1.com", nil);
            EMSRequestModel *secondModel = requestModel(@"https://url2.com", nil);

            [queue push:firstModel];
            [queue push:secondModel];

            [[[queue peek] should] equal:firstModel];
            [[[queue peek] should] equal:firstModel];
        });
    });


SPEC_END