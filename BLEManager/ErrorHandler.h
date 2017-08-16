//
//  ErrorHandler.h
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/21/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorHandler : NSObject

+ (NSError *)GenerateErrorWithCode:(NSInteger )errorCode;

+ (NSError *)PairingError;

@end
