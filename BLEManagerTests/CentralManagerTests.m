//
//  CentralManagerTests.m
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/25/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CentralManager.h"

@interface CentralManagerTests : XCTestCase

@end

@implementation CentralManagerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_A_CheckInstance {
    XCTAssertNotNil(CentralManager.SharedInstance);
}


@end
