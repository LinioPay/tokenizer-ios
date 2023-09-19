//
//  LinioPayTokenizer.m
//  pay-tokenizer-ios
//
//  Created by Omar on 3/3/17.
//  Copyright © 2017 omargon. All rights reserved.
//

#import "LinioPayTokenizer.h"
#import "LinioPayTokenizerConstants.h"

@interface LinioPayTokenizer ()

@property (nonatomic, readwrite, strong) NSString *tokenizationKey;
@property (nonatomic, readwrite, strong) NSMutableArray *errorMessages;
@property (readwrite) TokenEnvironment *environment;

@end

@implementation LinioPayTokenizer

const NSString *FORM_DICT_KEY_NAME = @"cardholder";
const NSString *FORM_DICT_KEY_NUMBER = @"number";
const NSString *FORM_DICT_KEY_CVC = @"cvc";
const NSString *FORM_DICT_KEY_MONTH = @"expiration_month";
const NSString *FORM_DICT_KEY_YEAR = @"expiration_year";
const NSString *FORM_DICT_KEY_ADDRESS = @"address";
const NSString *FORM_DICT_KEY_ADDRESS_FIRST_NAME = @"first_name";
const NSString *FORM_DICT_KEY_ADDRESS_LAST_NAME = @"last_name";
const NSString *FORM_DICT_KEY_STREET_1 = @"street1";
const NSString *FORM_DICT_KEY_STREET_2 = @"street2";
const NSString *FORM_DICT_KEY_STREET_3 = @"street3";
const NSString *FORM_DICT_KEY_PHONE = @"phone_number";
const NSString *FORM_DICT_KEY_CITY = @"city";
const NSString *FORM_DICT_KEY_STATE = @"state";
const NSString *FORM_DICT_KEY_COUNTY = @"county";
const NSString *FORM_DICT_KEY_COUNTRY = @"country_code";
const NSString *FORM_DICT_KEY_POSTAL_CODE = @"postal_code";
const NSString *FORM_DICT_KEY_EMAIL = @"email";

-(id)initWithKey:(NSString *)key environment:(TokenEnvironment)environment
{
    self = [super init];
    self.environment = environment;
    _errorMessages = [NSMutableArray arrayWithCapacity:1];
    
    if(self)
    {
        _tokenizationKey = key;
    }
    
    return self;
}

-(BOOL)validateKey:(NSString *)key error:(NSError **)outError
{
    const NSUInteger keyCharLength = CHAR_LENGTH_KEY;
    NSError *requiredError = [NSError errorWithDomain:ERROR_DOMAIN
                                                 code:ERROR_CODE_REQUIRED_KEY
                                             userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_REQUIRED_KEY }];
    NSError *invalidError = [NSError errorWithDomain:ERROR_DOMAIN
                                                code:ERROR_CODE_INVALID_KEY
                                            userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_INVALID_KEY }];
    NSString *regEx = [NSString stringWithFormat:@"^\\w{%lu}$", (unsigned long)keyCharLength];
    
    
    if (key == nil)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    NSMutableString *formattedKey = [NSMutableString stringWithString:key];
    formattedKey = [self trimString:formattedKey];
    
    if ([formattedKey length] == 0)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    if (![self testRegExp:formattedKey withPattern:regEx])
    {
        *outError = invalidError;
        return FALSE;
    }
    
    return TRUE;
}

-(BOOL)validateName:(NSString *)name type:(NameType)nameType error:(NSError **)outError
{
    const NSUInteger minCharacters = MIN_CHAR_NAME;
    const NSUInteger maxCharacters = MAX_CHAR_NAME;
    NSString *nameErrorType = nil;
    
    switch(nameType) {
        case CreditCardHolderName:
            nameErrorType = ERROR_DESC_REQUIRED_NAME;
            break;
        case AddressFirstName:
            nameErrorType = ERROR_DESC_REQUIRED_ADDRESS_FIRST_NAME;
            break;
        case AddressLastName:
            nameErrorType = ERROR_DESC_REQUIRED_ADDRESS_LAST_NAME;
            break;
    }
    
    NSError *requiredError = [NSError errorWithDomain:ERROR_DOMAIN
                                                 code:ERROR_CODE_REQUIRED_NAME
                                             userInfo:@{ NSLocalizedDescriptionKey : nameErrorType }];
    NSError *charMinLimitError = [NSError errorWithDomain:ERROR_DOMAIN
                                                     code:ERROR_CODE_CHAR_MIN_LIMIT_NAME
                                                 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:ERROR_DESC_CHAR_MIN_LIMIT_NAME, (unsigned long)minCharacters] }];
    NSError *charMaxLimitError = [NSError errorWithDomain:ERROR_DOMAIN
                                                     code:ERROR_CODE_CHAR_MAX_LIMIT_NAME
                                                 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:ERROR_DESC_CHAR_MAX_LIMIT_NAME, (unsigned long)maxCharacters] }];
    
    if (name == nil)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    NSMutableString *formattedName = [self trimString:[NSMutableString stringWithString:name]];
    
    if ([formattedName length] == 0)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    if ([formattedName length] < minCharacters)
    {
        *outError = charMinLimitError;
        return FALSE;
    }
    
    if ([formattedName length] > maxCharacters)
    {
        *outError = charMaxLimitError;
        return FALSE;
    }
    
    return TRUE;
}

-(BOOL)validateNumber:(NSString *)cardNumber error:(NSError **)outError
{
    NSError *requiredError = [NSError errorWithDomain:ERROR_DOMAIN
                                                 code:ERROR_CODE_REQUIRED_CARD_NUMBER
                                             userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_REQUIRED_CARD_NUMBER }];
    NSError *invalidError = [NSError errorWithDomain:ERROR_DOMAIN
                                                code:ERROR_CODE_INVALID_CARD_NUMBER
                                            userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_INVALID_CARD_NUMBER }];
    const NSError *error = nil;
    const NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"\\s|-"
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:&error];
    
    if (cardNumber == nil)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    NSString *modifiedCardNumber = [regEx stringByReplacingMatchesInString:cardNumber
                                                                   options:0
                                                                     range:NSMakeRange(0, [cardNumber length])
                                                              withTemplate:@""];
    
    if ([modifiedCardNumber length] == 0)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    // accept only digits after removing dashes or spaces
    
    if([self testRegExp:modifiedCardNumber withPattern:@"^\\d+$"] == 0)
    {
        *outError = invalidError;
        return FALSE;
    }
    
    // Luhn Check
    
    NSMutableString *reversedString = [NSMutableString stringWithCapacity:[modifiedCardNumber length]];
    
    [cardNumber enumerateSubstringsInRange:NSMakeRange(0, [modifiedCardNumber length])
                                   options:(NSStringEnumerationReverse |NSStringEnumerationByComposedCharacterSequences)
                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
     {
        [reversedString appendString:substring];
    }];
    
    NSUInteger oddSum = 0, evenSum = 0;
    
    for (NSUInteger i = 0; i < [reversedString length]; i++)
    {
        NSInteger digit = [[NSString stringWithFormat:@"%C", [reversedString characterAtIndex:i]] integerValue];
        
        if (i % 2 == 0)
        {
            evenSum += digit;
        }
        else
        {
            oddSum += digit / 5 + (2 * digit) % 10;
        }
    }
    
    if ((oddSum + evenSum) % 10 != 0)
    {
        *outError = invalidError;
        return FALSE;
    }
    
    return TRUE;
}

-(BOOL)validateCVC:(NSString *)cvcNumber card:(NSString *)cardNumber error:(NSError **)outError
{
    // Field is optional
    if (cvcNumber != nil)
    {
        NSError *invalidError = [NSError errorWithDomain:ERROR_DOMAIN
                                                    code:ERROR_CODE_INVALID_CVC
                                                userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_INVALID_CVC }];
        NSInteger validCVCNumberLength = CHAR_LENGTH_CVC;
        NSMutableString *formattedCVC = [NSMutableString stringWithString:cvcNumber];
        formattedCVC = [self trimString:formattedCVC];
        NSMutableString *formattedCardNumber = [NSMutableString stringWithString:cardNumber];
        formattedCardNumber = [self trimString:formattedCardNumber];
        
        // If card Type Amex expect 4 digits CVC number
        
        if ([self testRegExp:formattedCardNumber withPattern:@"^3[47]"])
        {
            validCVCNumberLength = CHAR_LENGTH_CVC_AMEX;
        }
        
        if (![self testRegExp:formattedCVC withPattern:[NSString stringWithFormat:@"^\\d{%lu}$", (long)validCVCNumberLength]])
        {
            *outError = invalidError;
            return FALSE;
        }
    }
    
    return TRUE;
}

-(BOOL)validateExpDate:(NSString *)monthValue year:(NSString *)yearValue error:(NSError **)outError
{
    id errorObjectInstance;
    NSUInteger errorIndexKey = 0;
    NSMutableArray *errorUserInfo = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *errorsDictionary = [[NSMutableDictionary alloc] init];
    NSError *requiredMonthError = [NSError errorWithDomain:ERROR_DOMAIN
                                                      code:ERROR_CODE_REQUIRED_MONTH
                                                  userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_REQUIRED_MONTH }];
    NSError *invalidMonthError = [NSError errorWithDomain:ERROR_DOMAIN
                                                     code:ERROR_CODE_INVALID_MONTH
                                                 userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_INVALID_MONTH }];
    NSError *requiredYearError = [NSError errorWithDomain:ERROR_DOMAIN
                                                     code:ERROR_CODE_REQUIRED_YEAR
                                                 userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_REQUIRED_YEAR }];
    NSError *invalidYearError = [NSError errorWithDomain:ERROR_DOMAIN
                                                    code:ERROR_CODE_INVALID_YEAR
                                                userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_INVALID_YEAR }];
    NSError *invalidExpError = [NSError errorWithDomain:ERROR_DOMAIN
                                                   code:ERROR_CODE_INVALID_EXPIRATION
                                               userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_INVALID_EXPIRATION }];
    
    if (monthValue == nil)
    {
        [errorUserInfo addObject:requiredMonthError.userInfo];
    }
    
    if (yearValue == nil)
    {
        [errorUserInfo addObject:requiredYearError.userInfo];
    }
    
    if ([errorUserInfo count] > 0)
    {
        for (errorObjectInstance in errorUserInfo)
        {
            [errorsDictionary setObject:errorObjectInstance
                                 forKey:[NSString stringWithFormat:@"Error-%lu", (unsigned long)errorIndexKey++]];
        }
        
        *outError = [NSError errorWithDomain:ERROR_DOMAIN code:ERROR_CODE_INVALID_EXPIRATION userInfo:errorsDictionary];
        return FALSE;
    }
    
    NSString *formattedMonth = [self trimString:[NSMutableString stringWithString:monthValue]];
    NSString *formattedYear = [self trimString:[NSMutableString stringWithString:yearValue]];
    
    if ([formattedMonth length] == 0)
    {
        [errorUserInfo addObject:requiredMonthError.userInfo];
    }
    
    if ([formattedYear length] == 0)
    {
        [errorUserInfo addObject:requiredYearError.userInfo];
    }
    
    if ([errorUserInfo count] > 0)
    {
        for (errorObjectInstance in errorUserInfo)
        {
            [errorsDictionary setObject:errorObjectInstance
                                 forKey:[NSString stringWithFormat:@"Error-%lu", (unsigned long)errorIndexKey++]];
        }
        
        *outError = [NSError errorWithDomain:ERROR_DOMAIN code:ERROR_CODE_INVALID_EXPIRATION userInfo:errorsDictionary];
        return FALSE;
    }
    
    if (![self testRegExp:formattedMonth withPattern:@"^\\d{1,2}$"])
    {
        [errorUserInfo addObject:invalidMonthError.userInfo];
    }
    
    if (![self testRegExp:formattedYear withPattern:@"^\\d{4}$"])
    {
        [errorUserInfo addObject:invalidYearError.userInfo];
    }
    
    if ([errorUserInfo count] > 0)
    {
        for (errorObjectInstance in errorUserInfo)
        {
            [errorsDictionary setObject:errorObjectInstance
                                 forKey:[NSString stringWithFormat:@"Error-%lu", (unsigned long)errorIndexKey++]];
        }
        
        *outError = [NSError errorWithDomain:ERROR_DOMAIN code:ERROR_CODE_INVALID_EXPIRATION userInfo:errorsDictionary];
        return FALSE;
    }
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSDate *expirationDate =[dateFormatter dateFromString:[NSString stringWithFormat:@"%@-%@", formattedYear, formattedMonth]];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:1];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    expirationDate = [calendar dateByAddingComponents:dateComponents toDate:expirationDate options:0];
    
    if ([expirationDate compare:today] == NSOrderedAscending)
    {
        *outError = invalidExpError;
        return FALSE;
    }
    
    return TRUE;
}

-(BOOL)validateAddressStreet1:(NSString *)addressStreet1 error:(NSError **)outError
{
    const NSUInteger maxCharacters = MAX_CHAR_STREET_1;
    NSError *requiredError = [NSError errorWithDomain:ERROR_DOMAIN
                                                 code:ERROR_CODE_REQUIRED_STREET_1
                                             userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_REQUIRED_STREET_1 }];
    NSError *charMaxLimitError = [NSError errorWithDomain:ERROR_DOMAIN
                                                     code:ERROR_CODE_CHAR_MAX_LIMIT_STREET_1
                                                 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:ERROR_DESC_CHAR_MAX_LIMIT_STREET_1, (unsigned long)maxCharacters] }];
    
    if (addressStreet1 == nil)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    NSString *formattedAddressStreet1 = [self trimString:[NSMutableString stringWithString:addressStreet1]];
    
    if ([formattedAddressStreet1 length] == 0)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    if ([formattedAddressStreet1 length] > maxCharacters)
    {
        *outError = charMaxLimitError;
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)validateOptionalAddressLine:(NSString *)addressLine type:(AddressLineType)lineType error:(NSError **)outError;
{
    // Street 2, Street 3, County, Phone are always optional
    if (addressLine != nil)
    {
        
        NSUInteger maxCharacters;
        NSUInteger errorCode;
        NSString *errorString;
        
        switch(lineType) {
            case AddressStreet2:
                maxCharacters = MAX_CHAR_STREET_2;
                errorCode = ERROR_CODE_CHAR_MAX_LIMIT_STREET_2;
                errorString = ERROR_DESC_CHAR_MAX_LIMIT_STREET_2;
                break;
            case AddressStreet3:
                maxCharacters = MAX_CHAR_STREET_3;
                errorCode = ERROR_CODE_CHAR_MAX_LIMIT_STREET_3;
                errorString = ERROR_DESC_CHAR_MAX_LIMIT_STREET_3;
                break;
            case County:
                maxCharacters = MAX_CHAR_COUNTY;
                errorCode = ERROR_CODE_CHAR_MAX_LIMIT_COUNTY;
                errorString = ERROR_DESC_CHAR_MAX_LIMIT_COUNTY;
                break;
            case Phone:
                maxCharacters = MAX_CHAR_PHONE;
                errorCode = ERROR_CODE_CHAR_MAX_LIMIT_PHONE;
                errorString = ERROR_DESC_CHAR_MAX_LIMIT_PHONE;
                break;
        }
        
        NSError *charMaxLimitError = [NSError errorWithDomain:ERROR_DOMAIN
                                                         code:errorCode
                                                     userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:errorString, (unsigned long)maxCharacters] }];
        
        NSString *formattedOptionalAddressLine = [self trimString:[NSMutableString stringWithString:addressLine]];
        
        if ([formattedOptionalAddressLine length] > maxCharacters)
        {
            *outError = charMaxLimitError;
            return FALSE;
        }
    }
    
    return TRUE;
}

-(BOOL)validateAddressCity:(NSString *)city error:(NSError **)outError
{
    const NSUInteger maxCharacters = MAX_CHAR_CITY;
    NSError *requiredError = [NSError errorWithDomain:ERROR_DOMAIN
                                                 code:ERROR_CODE_REQUIRED_CITY
                                             userInfo:@{ NSLocalizedDescriptionKey: ERROR_DESC_REQUIRED_CITY }];
    NSError *charMaxLimitError = [NSError errorWithDomain:ERROR_DOMAIN
                                                     code:ERROR_CODE_CHAR_MAX_LIMIT_CITY
                                                 userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:ERROR_DESC_CHAR_MAX_LIMIT_CITY, (unsigned long)maxCharacters] }];
    
    if (city == nil)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    NSString *formattedCity = [self trimString:[NSMutableString stringWithString:city]];
    
    if ([formattedCity length] == 0)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    if ([formattedCity length] > maxCharacters)
    {
        *outError = charMaxLimitError;
        return FALSE;
    }
    
    return TRUE;
}

-(BOOL)validateAddressState:(NSString *)state error:(NSError **)outError
{
    const NSUInteger maxCharacters = MAX_CHAR_STATE;
    NSError *requiredError = [NSError errorWithDomain:ERROR_DOMAIN
                                                 code:ERROR_CODE_REQUIRED_STATE
                                             userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_REQUIRED_STATE }];
    NSError *charMaxLimitError = [NSError errorWithDomain:ERROR_DOMAIN
                                                     code:ERROR_CODE_CHAR_MAX_LIMIT_STATE
                                                 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:ERROR_DESC_CHAR_MAX_LIMIT_STATE, (unsigned long)maxCharacters] }];
    
    if (state == nil)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    NSString *formattedState = [self trimString:[NSMutableString stringWithString:state]];
    
    if ([formattedState length] == 0)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    if ([formattedState length] > maxCharacters)
    {
        *outError = charMaxLimitError;
        return FALSE;
    }
    
    return TRUE;
}

-(BOOL)validateAddressCountry:(NSString *)country error:(NSError **)outError
{
    const NSUInteger numberOfCharacters = CHAR_LENGTH_COUNTRY;
    NSError *requiredError = [NSError errorWithDomain:ERROR_DOMAIN
                                                 code:ERROR_CODE_REQUIRED_COUNTRY
                                             userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_REQUIRED_COUNTRY }];
    NSError *invalidError = [NSError errorWithDomain:ERROR_DOMAIN
                                                code:ERROR_CODE_INVALID_COUNTRY
                                            userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_INVALID_COUNTRY }];
    
    if (country == nil)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    NSString *formattedCountry = [self trimString:[NSMutableString stringWithString:country]];
    
    if ([formattedCountry length] == 0)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    if ([self testRegExp:formattedCountry withPattern:[NSString stringWithFormat:@"^[A-Za-z]{%lu}$", (unsigned long)numberOfCharacters]] == 0)
    {
        *outError = invalidError;
        return FALSE;
    }
    
    return TRUE;
}

-(BOOL)validateAddressPostalCode:(NSString *)postalCode error:(NSError **)outError
{
    const NSUInteger maxCharacters = MAX_CHAR_POSTAL_CODE;
    NSError *requiredError = [NSError errorWithDomain:ERROR_DOMAIN
                                                 code:ERROR_CODE_REQUIRED_POSTAL_CODE
                                             userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_REQUIRED_POSTAL_CODE }];
    NSError *charMaxLimitError = [NSError errorWithDomain:ERROR_DOMAIN
                                                     code:ERROR_CODE_CHAR_MAX_LIMIT_POSTAL_CODE
                                                 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:ERROR_DESC_CHAR_MAX_LIMIT_POSTAL_CODE, (unsigned long)maxCharacters] }];
    NSError *invalidError = [NSError errorWithDomain:ERROR_DOMAIN
                                                code:ERROR_CODE_INVALID_POSTAL_CODE
                                            userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_INVALID_POSTAL_CODE }];
    
    if (postalCode == nil)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    NSString *formattedPostalCode = [self trimString:[NSMutableString stringWithString:postalCode]];
    
    if ([formattedPostalCode length] == 0)
    {
        *outError = requiredError;
        return FALSE;
    }
    
    if ([self testRegExp:formattedPostalCode withPattern:[NSString stringWithFormat:@"^\\d+$"]] == 0)
    {
        *outError = invalidError;
        return FALSE;
    }
    
    if ([formattedPostalCode length] > maxCharacters)
    {
        *outError = charMaxLimitError;
        return FALSE;
    }
    
    return TRUE;
}

-(BOOL)validateEmail:(NSString *)email error:(NSError **)outError {
    if(email != nil) {
        const char cRegex[] = "^(?!(?:(?:\\x22?\\x5C[\\x00-\\x7E]\\x22?)|(?:\\x22?[^\\x5C\\x22]\\x22?)){255,})(?!(?:(?:\\x22?\\x5C[\\x00-\\x7E]\\x22?)|(?:\\x22?[^\\x5C\\x22]\\x22?)){65,}@)(?:(?:[\\x21\\x23-\\x27\\x2A\\x2B\\x2D\\x2F-\\x39\\x3D\\x3F\\x5E-\\x7E]+)|(?:\\x22(?:[\\x01-\\x08\\x0B\\x0C\\x0E-\\x1F\\x21\\x23-\\x5B\\x5D-\\x7F]|(?:\\x5C[\\x00-\\x7F]))*\\x22))(?:\\.(?:(?:[\\x21\\x23-\\x27\\x2A\\x2B\\x2D\\x2F-\\x39\\x3D\\x3F\\x5E-\\x7E]+)|(?:\\x22(?:[\\x01-\\x08\\x0B\\x0C\\x0E-\\x1F\\x21\\x23-\\x5B\\x5D-\\x7F]|(?:\\x5C[\\x00-\\x7F]))*\\x22)))*@(?:(?:(?!.*[^.]{64,})(?:(?:(?:xn--)?[a-z0-9]+(?:-+[a-z0-9]+)*\\.){1,126}){1,}(?:(?:[a-z][a-z0-9]*)|(?:(?:xn--)[a-z0-9]+))(?:-+[a-z0-9]+)*)|(?:\\[(?:(?:IPv6:(?:(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){7})|(?:(?!(?:.*[a-f0-9][:\\]]){7,})(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){0,5})?::(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){0,5})?)))|(?:(?:IPv6:(?:(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){5}:)|(?:(?!(?:.*[a-f0-9]:){5,})(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){0,3})?::(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){0,3}:)?)))?(?:(?:25[0-5])|(?:2[0-4][0-9])|(?:1[0-9]{2})|(?:[1-9]?[0-9]))(?:\\.(?:(?:25[0-5])|(?:2[0-4][0-9])|(?:1[0-9]{2})|(?:[1-9]?[0-9]))){3}))\\]))$";
        NSString *emailRegex = [NSString stringWithUTF8String:cRegex];
        NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
        BOOL isValid = [emailPredicate evaluateWithObject:email];
        
        if (!isValid) {
            *outError =  [NSError errorWithDomain:ERROR_DOMAIN
                                             code:ERROR_CODE_INVALID_EMAIL
                                         userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:ERROR_DESC_INVALID_EMAIL, email]}];
        }
        
        return isValid;
    }
    
    return TRUE;
}

-(NSMutableString *)trimString:(NSMutableString *)string
{
    const NSError *error;
    const NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\s+|\\s+$"
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:&error];
    const NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"\\s+"
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:&error];
    NSMutableString *modifiedString = [NSMutableString stringWithString:[regex stringByReplacingMatchesInString:string
                                                                                                        options:0
                                                                                                          range:NSMakeRange(0, [string length])
                                                                                                   withTemplate:@""]];
    modifiedString = [NSMutableString stringWithString:[regex2 stringByReplacingMatchesInString:modifiedString
                                                                                        options:0 range:NSMakeRange(0, [modifiedString length])
                                                                                   withTemplate:@" "]];
    return modifiedString;
}

-(BOOL)testRegExp:(NSString *)string withPattern:(NSString *)pattern
{
    const NSError *error = nil;
    const NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:&error];
    
    if ([regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] > 0)
    {
        return true;
    }
    
    return false;
}

-(void)requestToken:(NSDictionary *)formValues oneTime:(BOOL)oneTime completion:(void (^) (NSDictionary *, NSError *)) completion
{
    _errorMessages = [NSMutableArray arrayWithCapacity:1];
    
    
    NSError *keyError, *nameError, *numberError, *expDateError, *addressFirstNameError, *addressLastNameError, *street1Error, *street2Error, *street3Error, *phoneError, *cityError, *stateError, *countyError, *countryError, *postalCodeError, *emailError;
    
    
    if(![self validateKey:_tokenizationKey error:&keyError])
    {
        if (keyError != nil)
        {
            [_errorMessages addObject:keyError];
        }
    }
    
    if(![self validateName:[formValues objectForKey:FORM_DICT_KEY_NAME] type:CreditCardHolderName error:&nameError])
    {
        if (nameError != nil)
        {
            [_errorMessages addObject:nameError];
        }
    }
    
    if(![self validateNumber:[formValues objectForKey:FORM_DICT_KEY_NUMBER] error:&numberError])
    {
        if (numberError != nil)
        {
            [_errorMessages addObject:numberError];
        }
    }
    
    if(![self validateExpDate:[formValues objectForKey:FORM_DICT_KEY_MONTH]
                         year:[formValues objectForKey:FORM_DICT_KEY_YEAR]
                        error:&expDateError])
    {
        if (expDateError != nil)
        {
            [_errorMessages addObject:expDateError];
        }
    }
    
    
    if ([formValues objectForKey:FORM_DICT_KEY_ADDRESS] != nil)
    {
        NSDictionary *addressData = [formValues objectForKey:FORM_DICT_KEY_ADDRESS];
        
        if(![self validateName:[addressData objectForKey:FORM_DICT_KEY_ADDRESS_FIRST_NAME] type:AddressFirstName error:&addressFirstNameError])
        {
            if (addressFirstNameError != nil)
            {
                [_errorMessages addObject:addressFirstNameError];
            }
        }
        
        if(![self validateName:[addressData objectForKey:FORM_DICT_KEY_ADDRESS_LAST_NAME] type:AddressLastName error:&addressLastNameError])
        {
            if (addressLastNameError != nil)
            {
                [_errorMessages addObject:addressLastNameError];
            }
        }
        
        if(![self validateAddressStreet1:[addressData objectForKey:FORM_DICT_KEY_STREET_1] error:&street1Error])
        {
            if (street1Error != nil)
            {
                [_errorMessages addObject:street1Error];
            }
        }
        
        if(![self validateOptionalAddressLine:[addressData objectForKey:FORM_DICT_KEY_STREET_2]
                                         type:AddressStreet2
                                        error:&street2Error])
        {
            if (street2Error != nil)
            {
                [_errorMessages addObject:street2Error];
            }
        }
        
        if(![self validateOptionalAddressLine:[addressData objectForKey:FORM_DICT_KEY_STREET_3]
                                         type:AddressStreet3
                                        error:&street3Error])
        {
            if (street3Error != nil)
            {
                [_errorMessages addObject:street3Error];
            }
        }
        
        if(![self validateOptionalAddressLine:[addressData objectForKey:FORM_DICT_KEY_PHONE]
                                         type:Phone
                                        error:&phoneError])
        {
            if (phoneError != nil)
            {
                [_errorMessages addObject:phoneError];
            }
        }
        
        if(![self validateOptionalAddressLine:[addressData objectForKey:FORM_DICT_KEY_COUNTY]
                                         type:County
                                        error:&countyError])
        {
            if (countyError != nil)
            {
                [_errorMessages addObject:countyError];
            }
        }
        
        if(![self validateAddressCity:[addressData objectForKey:FORM_DICT_KEY_CITY] error:&cityError])
        {
            if (cityError != nil)
            {
                [_errorMessages addObject:cityError];
            }
        }
        
        if(![self validateAddressState:[addressData objectForKey:FORM_DICT_KEY_STATE] error:&stateError])
        {
            if (stateError != nil)
            {
                [_errorMessages addObject:stateError];
            }
        }
        
        if(![self validateAddressCountry:[addressData objectForKey:FORM_DICT_KEY_COUNTRY] error:&countryError])
        {
            if (countryError != nil)
            {
                [_errorMessages addObject:countryError];
            }
        }
        
        if(![self validateAddressPostalCode:[addressData objectForKey:FORM_DICT_KEY_POSTAL_CODE] error:&postalCodeError])
        {
            if (postalCodeError != nil)
            {
                [_errorMessages addObject:postalCodeError];
            }
        }
        
        if(![self validateEmail:[addressData objectForKey:FORM_DICT_KEY_EMAIL] error:&emailError])
        {
            if (emailError != nil)
            {
                [_errorMessages addObject:emailError];
            }
        }
    }
    
    if ([_errorMessages count] > 0)
    {
        id objectInstance;
        NSUInteger indexKey = 0;
        NSMutableDictionary *errorsDictionary = [[NSMutableDictionary alloc] init];
        
        for (objectInstance in _errorMessages)
        {
            [errorsDictionary setObject:objectInstance
                                 forKey:[NSString stringWithFormat:@"Error-%lu", (unsigned long)indexKey++]];
        }
        
        return completion(nil, [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:errorsDictionary]);
    }
    else
    {
        NSDictionary *postData =@{
            @"tokenization_key": _tokenizationKey,
            @"token": @{
                @"one_time": [NSNumber numberWithBool:oneTime],
                @"payment_method": @{
                    @"charge_card": formValues,
                },
            },
        };
        
        NSError *jsonError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postData
                                                           options:(NSJSONWritingOptions)0
                                                             error:&jsonError];
        
        if (!jsonData)
        {
            NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", [jsonError localizedDescription]);
            return completion(nil, [NSError errorWithDomain:NSURLErrorDomain
                                                       code:0
                                                   userInfo:@{@"Error message": @"JSON error"}]);
        }
        
        NSLog(@"JSON is %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        
        NSString *url;
        
        // Check the value of the environment variable using if statements
        if (self.environment == prod) {
            // Assign the production url to the url variable
            url = LPTS_API_PATH;
        } else if (self.environment == staging) {
            // Assign the staging url to the url variable
            url = LPTS_API_STG_PATH;
        } else {
            // Log a message if no environment is entered
            NSLog(@"no environment entered");
        }
        
        NSURL * apiURL = [NSURL URLWithString:url];
        NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:apiURL];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:jsonData];
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                     delegate:nil
                                                                delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest
                                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *sessionError) {
            if(sessionError != nil)
            {
                return completion(nil, sessionError);
            }
            else
            {
                NSError* jsonError;
                NSDictionary* results = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingAllowFragments
                                                                          error:&jsonError];
                
                if(jsonError!=nil)
                {
                    return completion(nil,jsonError);
                }
                else
                {
                    return completion(results,nil);
                }
            }
        }];
        [dataTask resume];
    }
}

@end

