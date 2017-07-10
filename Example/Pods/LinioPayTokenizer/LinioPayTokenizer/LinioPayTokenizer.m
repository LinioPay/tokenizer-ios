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

@end

@implementation LinioPayTokenizer

const NSString *FORM_DICT_KEY_NAME = @"cardholder";
const NSString *FORM_DICT_KEY_NUMBER = @"number";
const NSString *FORM_DICT_KEY_CVC = @"cvc";
const NSString *FORM_DICT_KEY_MONTH = @"expiration_month";
const NSString *FORM_DICT_KEY_YEAR = @"expiration_year";
const NSString *FORM_DICT_KEY_ADDRESS = @"address";
const NSString *FORM_DICT_KEY_STREET_1 = @"street1";
const NSString *FORM_DICT_KEY_STREET_2 = @"street2";
const NSString *FORM_DICT_KEY_CITY = @"city";
const NSString *FORM_DICT_KEY_STATE = @"state";
const NSString *FORM_DICT_KEY_COUNTRY = @"country_code";
const NSString *FORM_DICT_KEY_POSTAL_CODE = @"postal_code";

-(id)initWithKey:(NSString *)key
{
    self = [super init];
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

-(BOOL)validateName:(NSString *)name error:(NSError **)outError
{
    const NSUInteger minCharacters = MIN_CHAR_NAME;
    const NSUInteger maxCharacters = MAX_CHAR_NAME;
    NSError *requiredError = [NSError errorWithDomain:ERROR_DOMAIN
                                                       code:ERROR_CODE_REQUIRED_NAME
                                                   userInfo:@{ NSLocalizedDescriptionKey : ERROR_DESC_REQUIRED_NAME }];
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

-(BOOL)validateAddressStreet2:(NSString *)addressStreet2 error:(NSError **)outError
{
    // Always optional
    if (addressStreet2 != nil)
    {
        const NSUInteger maxCharacters = MAX_CHAR_STREET_2;
        NSError *charMaxLimitError = [NSError errorWithDomain:ERROR_DOMAIN
                                                               code:ERROR_CODE_CHAR_MAX_LIMIT_STREET_2
                                                           userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:ERROR_DESC_CHAR_MAX_LIMIT_STREET_2, (unsigned long)maxCharacters] }];
        
        NSString *formattedAddressStreet2 = [self trimString:[NSMutableString stringWithString:addressStreet2]];
        
        if ([formattedAddressStreet2 length] > maxCharacters)
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

-(void)requestToken:(NSDictionary *)formValues completion:(void (^) (NSDictionary *, NSError *)) completion
{
    _errorMessages = [NSMutableArray arrayWithCapacity:1];
    
    
    NSError *keyError, *nameError, *numberError, *expDateError, *street1Error, *street2Error, *cityError, *stateError, *countryError, *postalCodeError;
    
    
    if(![self validateKey:_tokenizationKey error:&keyError])
    {
        if (keyError != nil)
        {
            [_errorMessages addObject:keyError];
        }
    }
    
    if(![self validateName:[formValues objectForKey:FORM_DICT_KEY_NAME] error:&nameError])
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
        
        if(![self validateAddressStreet1:[addressData objectForKey:FORM_DICT_KEY_STREET_1] error:&street1Error])
        {
            if (street1Error != nil)
            {
                [_errorMessages addObject:street1Error];
            }
        }
        
        if(![self validateAddressStreet2:[addressData objectForKey:FORM_DICT_KEY_STREET_2] error:&street2Error])
        {
            if (street2Error != nil)
            {
                [_errorMessages addObject:street2Error];
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
                                          @"one_time": @"false",
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
        
        // Else submit form
        NSURL * apiURL = [NSURL URLWithString:LPTS_API_PATH];
        NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:apiURL];
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