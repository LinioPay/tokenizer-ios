//
//  LinioPayTokenizer.h
//  pay-tokenizer-ios
//
//  Created by Omar on 3/3/17.
//  Copyright © 2017 omargon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinioPayTokenizer : NSObject

typedef NS_ENUM(NSInteger, NameType) {
    CreditCardHolderName,
    AddressFirstName,
    AddressLastName
};

typedef NS_ENUM(NSInteger, AddressLineType) {
    AddressStreet2,
    AddressStreet3,
    County,
    Phone
};

typedef NS_ENUM(NSInteger, TokenEnvironment) {
    prod,
    staging
};

extern const NSString *FORM_DICT_KEY_NAME;
extern const NSString *FORM_DICT_KEY_NUMBER;
extern const NSString *FORM_DICT_KEY_CVC;
extern const NSString *FORM_DICT_KEY_MONTH;
extern const NSString *FORM_DICT_KEY_YEAR;
extern const NSString *FORM_DICT_KEY_ADDRESS;
extern const NSString *FORM_DICT_KEY_ADDRESS_FIRST_NAME;
extern const NSString *FORM_DICT_KEY_ADDRESS_LAST_NAME;
extern const NSString *FORM_DICT_KEY_STREET_1;
extern const NSString *FORM_DICT_KEY_STREET_2;
extern const NSString *FORM_DICT_KEY_STREET_3;
extern const NSString *FORM_DICT_KEY_PHONE;
extern const NSString *FORM_DICT_KEY_CITY;
extern const NSString *FORM_DICT_KEY_STATE;
extern const NSString *FORM_DICT_KEY_COUNTRY;
extern const NSString *FORM_DICT_KEY_COUNTY;
extern const NSString *FORM_DICT_KEY_POSTAL_CODE;
extern const NSString *FORM_DICT_KEY_EMAIL;

- (id)initWithKey:(NSString *)key environment:(TokenEnvironment)environment;
- (BOOL)validateKey:(NSString *)key error:(NSError **)outError;
- (BOOL)validateName:(NSString*)name type:(NameType)nameType error:(NSError **)outError;
- (BOOL)validateNumber:(NSString *)cardNumber error:(NSError **)outError;
- (BOOL)validateCVC:(NSString *)cvcNumber card:(NSString *)cardNumber error:(NSError **)outError;
- (BOOL)validateExpDate:(NSString *)monthValue year:(NSString *)yearValue error:(NSError **)outError;
- (BOOL)validateAddressStreet1:(NSString *)addressStreet1 error:(NSError **)outError;
- (BOOL)validateOptionalAddressLine:(NSString *)addressLine type:(AddressLineType)lineType error:(NSError **)outError;
- (BOOL)validateAddressCity:(NSString *)city error:(NSError **)outError;
- (BOOL)validateAddressState:(NSString *)state error:(NSError **)outError;
- (BOOL)validateAddressCountry:(NSString *)country error:(NSError **)outError;
- (BOOL)validateAddressPostalCode:(NSString *)postalCode error:(NSError **)outError;
- (BOOL)validateEmail:(NSString*)email error:(NSError **)outError;
- (void)requestToken:(NSDictionary *)formValues oneTime:(BOOL)oneTime completion:(void (^)(NSDictionary* data, NSError* error))completion;

@end
