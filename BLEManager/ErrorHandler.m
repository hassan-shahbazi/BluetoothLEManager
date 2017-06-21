//
//  ErrorHandler.m
//  BLEManager
//
//  Created by Hassan Shahbazi on 6/21/17.
//  Copyright © 2017 Hassan Shahbazi. All rights reserved.
//

#define domain      @"com.Vancosys.BLEManager.ErrorDomain"

#import "ErrorHandler.h"

@interface ErrorHandler()

@end

@implementation ErrorHandler

+ (NSError *)GenerateErrorWithCode:(NSInteger )errorCode {
    NSString *desc = [self GetErrorDescription:
                      [self GetErrorCodeIndex:errorCode]];
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
    NSError *error = [[NSError alloc] initWithDomain:domain
                                                code:errorCode
                                            userInfo:userInfo];
    
    return error;
}

+ (NSDictionary *)GetAllErrors {
    NSString* plistPath = [[NSBundle bundleForClass:[self class]]
                           pathForResource:@"ErrorCodes" ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:plistPath];
}

+ (NSInteger )GetErrorCodeIndex:(NSInteger )errorCode {
    NSArray *errorCodes = [[self GetAllErrors] objectForKey:@"Codes"];
    return [errorCodes indexOfObject:
            [NSString stringWithFormat:@"%ld", (long)errorCode]];
}

+ (NSString *)GetErrorDescription:(NSInteger )index {
    NSArray *errorDescriptions = [[self GetAllErrors] objectForKey:@"Descriptions"];
    return [errorDescriptions objectAtIndex:index];
}

@end
