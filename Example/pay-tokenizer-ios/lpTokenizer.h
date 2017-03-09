//
//  lpTokenizer.h
//  pay-tokenizer-ios
//
//  Created by Omar on 3/3/17.
//  Copyright © 2017 omargon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface lpTokenizer : NSObject

-(id)initWithKey: (NSString *)key;

-(BOOL)validateKey: (NSString *)key;

-(BOOL)validateName: (NSString*)name;

-(BOOL)validateNumber: (NSString *)cardNumber;

-(BOOL)validateCVC: (NSString *)cvcNumber card:(NSString *)cardNumber;

-(BOOL)validateExpDate: (NSString *)monthValue year:(NSString *)yearValue;

-(BOOL)validateAddressStreet1: (NSString *)addressStreet1;

-(BOOL)validateAddressStreet2: (NSString *)addressStreet2;

-(BOOL)validateAddressCity: (NSString *)city;

-(BOOL)validateAddressState: (NSString *)state;

-(BOOL)validateAddressCountryCode: (NSString *)countryCode;

-(BOOL)validateAddressPostalCode: (NSString *)postalCode;

-(BOOL)requestToken: (NSDictionary *)formValues;

@end
