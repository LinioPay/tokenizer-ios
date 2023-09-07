//
//  LinioPayTokenizerTests.m
//  LinioPayTokenizerTests
//
//  Created by omargon on 03/14/2017.
//  Copyright (c) 2017 omargon. All rights reserved.
//
#import "LinioPayTokenizer/LinioPayTokenizer.h"

@import XCTest;

@interface Tests : XCTestCase

@property (strong, nonatomic) LinioPayTokenizer *tokenizer;
@property (strong, nonatomic) NSString *stringWithMoreThan255Characters;

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.tokenizer = [[LinioPayTokenizer alloc] initWithKey:@"test_0618f5c21603cd9d33ba8a8f0c9e2446283" environment:prod];
    
    self.stringWithMoreThan255Characters = @"Omar Gonzalez Gonzalez Family Friends Pets and Community of Doral FloridaOmar Gonzalez Gonzalez Family Friends Pets and Community of Doral FloridaOmar Gonzalez Gonzalez Family Friends Pets and Community of Doral FloridaOmar Gonzalez Gonzalez Family Friends Pets and Community of Doral FloridaOmar Gonzalez Gonzalez Family Friends Pets and Community of Doral FloridaOmar Gonzalez Gonzalez Family Friends Pets and Community of Doral FloridaOmar Gonzalez Gonzalez Family Friends Pets and Community of Doral Florida";
}

- (void)tearDown
{
    self.tokenizer = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitWithKey
{
    XCTAssertNotNil(self.tokenizer, @"Object instantiated");
}

- (void)testValidateKeyWithValidKey
{
    NSError *error;
    XCTAssertTrue([self.tokenizer validateKey:@"test_0618f5c21603cd9d33ba8a8f0c9e2446283" error:&error],
                  @"True if valid key value");
}

- (void)testValidateKeyWithNil
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateKey:nil error:&error],
                  @"validateKey with invalid data should return false");
}

- (void)testValidateKeyWithStringLengthEqual0
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateKey:@"" error:&error],
                   @"False when key length is 0");
}

- (void)testValidateKeyWithStringLengthLessThan40
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateKey:@"0618f5c21603cd9d33ba8a8f0c9e2446283" error:&error],
                   @"False when key length is less than 40 characters");
}

- (void)testValidateKeyWithStringLengthMoreThan40
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateKey:@"wefkssladfs0618f5c21603cd9d33ba8a8f0c9e2446283" error:&error],
                   @"False when key length is less more than 40 characters");
}

- (void)testValidateNameWithValidValue
{
    NSError *error;
    XCTAssertTrue([self.tokenizer validateName:@"Omar Gonzalez" error:&error],
                  @"True if valid cardholder name value");
}

- (void)testValidateNameWithNil
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateName:nil error:&error], @"False when key has a nil value");
}

- (void)testValidateNameWithStringLengthEqual0
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateName:@"" error:&error], 
					@"False when key string is empty");
}

- (void)testValidateNameWithStringLengthLessThan5
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateName:@"Omar" error:&error], 
					@"False when name length is less than 60 charaters");
}

- (void)testValidateNameWithStringLengthMoreThan60
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateName:@"Omar Gonzalez Gonzalez Family Friends Pets and Community of Doral Florida"
                      error:&error], 
					@"False when name length is more than 60 charaters");
}

- (void)testValidateCardNumberWithValidValues
{
    NSError *error;
    NSArray *cardNumbers = @[
                             @"378282246310005",
                             @"371449635398431",
                             @"378734493671000",
                             @"5610591081018250",
                             @"30569309025904",
                             @"38520000023237",
                             @"6011111111111117",
                             @"6011000990139424",
                             @"3530111333300000",
                             @"3566002020360505",
                             @"5555555555554444",
                             @"5105105105105100",
                             @"4111111111111111",
                             @"4012888888881881",
                             @"4222222222222",
                             @"5019717010103742",
                             @"6331101999990016"];
    
    for (NSString *number in cardNumbers)
    {
        XCTAssertTrue([self.tokenizer validateNumber:number error:&error],
                      @"True if valid cardNumber value");
    }
}

- (void)testValidateCardNumberWithNil
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateNumber:nil error:&error],
                   @"False when number has a nil value");
}

- (void)testValidateCardNumberWithStringLengthEqual0
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateNumber:@"" error:&error],
                   @"False when number string is empty");
}

- (void)testValidateCardNumberWithAlphaCharacters
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateNumber:@"wefwefwefr2323wfwfwe" error:&error],
                   @"False when number value includes alpha characters");
}

- (void)testValidateCardNumberWithInvalidNumber
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateNumber:@"0003492383232356" error:&error],
                   @"False when number value doesn't pass the luhn check");
}

- (void)testValidateCVCWithValidValues
{
    NSError *error;
    XCTAssertTrue([self.tokenizer validateCVC:@"123" card:@"4111111111111111" error:&error],
                  @"True if valid cvc card number combination");
    
    XCTAssertTrue([self.tokenizer validateCVC:@"1234" card:@"378282246310005" error:&error],
                  @"True if valid cvc card number AMEX combination");
}

- (void)testValidateCVCWithInValidValues
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateCVC:@"1234" card:@"4111111111111111" error:&error],
                   @"False with invalid CVC and credit card number conbination");
    
    XCTAssertFalse([self.tokenizer validateCVC:@"123" card:@"378282246310005" error:&error],
                   @"False with invalid CVC and AMEX credit card number conbination");
}


- (void)testValidateExpDateWithFutureDate
{
    NSError *error;
    XCTAssertTrue([self.tokenizer validateExpDate:@"02" year:@"3001" error:&error],
                  @"True if valid expiration date");
}

- (void)testValidateExpDateWithPastDate
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateExpDate:@"12" year:@"2016" error:&error],
                   @"False with invalid expiration date set in the past");
}

- (void)testValidateExpDateWithMissingData
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateExpDate:nil year:@"3001" error:&error],
                   @"False when month is nil");
    
    XCTAssertFalse([self.tokenizer validateExpDate:@"02" year:nil error:&error],
                   @"False when year is nil");
    
    XCTAssertFalse([self.tokenizer validateExpDate:@"" year:@"3001" error:&error],
                   @"False when month string is empty");
    
    XCTAssertFalse([self.tokenizer validateExpDate:@"02" year:@"" error:&error],
                   @"False when year string is empty");
}

- (void)testValidateExpDateWithInvalidData
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateExpDate:@"1234" year:@"3001" error:&error],
                   @"False when month has more than 2 digits");
    
    XCTAssertFalse([self.tokenizer validateExpDate:@"02" year:@"02" error:&error],
                   @"False when year has less than 4 digits");
    
    XCTAssertFalse([self.tokenizer validateExpDate:@"as" year:@"3001" error:&error],
                   @"False when month contains alpha characters");
    
    XCTAssertFalse([self.tokenizer validateExpDate:@"02" year:@"23456" error:&error],
                   @"False when year has more than 4 digits");
}

- (void)testValidateAddressStreet1WithValidValue
{
    NSError *error;
    XCTAssertTrue([self.tokenizer validateAddressStreet1:@"Here Calle 2 Ayer" error:&error],
                  @"True when a valid address street 1");
}

- (void)testValidateAddressStreet1WithNil
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressStreet1:nil error:&error],
                   @"False when a nil or no address street 1");
}

- (void)testValidateAddressStreet1WithStringLengthEqual0
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressStreet1:@"" error:&error],
                   @"False when an empty address street 1");
}

- (void)testValidateAddressStreet1WithStringLengthMoreThan255
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressStreet1:self.stringWithMoreThan255Characters error:&error],
                   @"False when a address street 1 string value length > 255");
}

- (void)testValidateAddressStreet2WithValidValue
{
    NSError *error;
    XCTAssertTrue([self.tokenizer validateAddressStreet2:@"Here Calle 2 Ayer" error:&error],
                  @"True when a valid address street 2");
}

- (void)testValidateAddressStreet2WithStringLengthMoreThan255
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressStreet2:self.stringWithMoreThan255Characters error:&error],
                   @"False when a address street 2 string value length > 255");
}

- (void)testValidateAddressCityWithValidValue
{
    NSError *error;
    XCTAssertTrue([self.tokenizer validateAddressCity:@"Miami" error:&error],
                  @"True when a valid city");
}

- (void)testValidateAddressCityWithNil
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressCity:nil error:&error],
                   @"False when a nil or no address city");
}

- (void)testValidateAddressCityWithStringLengthEqual0
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressCity:@"" error:&error],
                   @"False when an empty city");
}

- (void)testValidateAddressCityWithStringLengthMoreThan255
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressCity:self.stringWithMoreThan255Characters error:&error],
                   @"False when a city string value length > 255");
}

- (void)testValidateAddressStateWithValidValue
{
    NSError *error;
    XCTAssertTrue([self.tokenizer validateAddressState:@"Florida" error:&error],
                  @"True when a valid state");
}

- (void)testValidateAddressStateWithNil
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressState:nil error:&error],
                   @"False when a nil or no address state");
}

- (void)testValidateAddressStateWithStringLengthEqual0
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressState:@"" error:&error],
                   @"False when an empty state");
}

- (void)testValidateAddressStateWithStringLengthMoreThan120
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressState:self.stringWithMoreThan255Characters error:&error],
                   @"False when a state string value length > 120");
}

- (void)testValidateAddressCountryWithValidValue
{
    NSError *error;
    XCTAssertTrue([self.tokenizer validateAddressCountry:@"USA" error:&error],
                  @"True when a valid country");
}

- (void)testValidateAddressCountryWithNil
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressCountry:nil error:&error],
                   @"False when a nil or no address country");
}

- (void)testValidateAddressCountryWithStringLengthEqual0
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressCountry:@"" error:&error],
                   @"False when an empty country");
}

- (void)testValidateAddressCountryWithStringLengthMoreThan3
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressCountry:@"MXCC" error:&error],
                   @"False when a country string value length > 3");
}

- (void)testValidateAddressPostalCodeWithValidValue
{
    NSError *error;
    XCTAssertTrue([self.tokenizer validateAddressPostalCode:@"12345" error:&error],
                  @"True when a valid postal code");
}

- (void)testValidateAddressPostalCodeWithNil
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressPostalCode:nil error:&error],
                   @"False when a nil or no address postal code");
}

- (void)testValidateAddressPostalCodeWithStringLengthEqual0
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressPostalCode:@"" error:&error],
                   @"False when an empty postal code");
}

- (void)testValidateAddressPostalCodeWithAlphaCharacters
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressPostalCode:@"abcde" error:&error],
                   @"False when postal code value containing alpha characters");
}

- (void)testValidateAddressPostalCodeWithStringLengthMoreThan3
{
    NSError *error;
    XCTAssertFalse([self.tokenizer validateAddressPostalCode:@"123456789012345678901" error:&error],
                   @"False when a postal code string value length > 20");
}

- (void)testRequestTokenWithValidData
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out."];
    [self.tokenizer requestToken:@{
                                   FORM_DICT_KEY_NAME: @"Omar Gonzalez",
                                   FORM_DICT_KEY_NUMBER: @"4111111111111111",
                                   FORM_DICT_KEY_CVC: @"123",
                                   FORM_DICT_KEY_MONTH: @"02",
                                   FORM_DICT_KEY_YEAR: @"3012",
                                   FORM_DICT_KEY_ADDRESS: @{
                                           FORM_DICT_KEY_STREET_1: @"Here",
                                           FORM_DICT_KEY_STREET_2: @"",
                                           FORM_DICT_KEY_CITY: @"Miami",
                                           FORM_DICT_KEY_STATE: @"Florida",
                                           FORM_DICT_KEY_COUNTRY: @"USA",
                                           FORM_DICT_KEY_POSTAL_CODE: @"33178",
                                   },
                               }
                      completion: ^(NSDictionary *data, NSError *error)
    {
        // TODO: Assert response once server is available
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error)
    {
        if (error)
        {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)testRequestTokenWithValidDataButNoAddress
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out."];
    [self.tokenizer requestToken:@{
                                   FORM_DICT_KEY_NAME: @"Omar Gonzalez",
                                   FORM_DICT_KEY_NUMBER: @"4111111111111111",
                                   FORM_DICT_KEY_CVC: @"123",
                                   FORM_DICT_KEY_MONTH: @"02",
                                   FORM_DICT_KEY_YEAR: @"3012",
                                   }
                      completion: ^(NSDictionary *data, NSError *error)
     {
         // TODO: Assert response once server is available
         [expectation fulfill];
     }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error)
    {
        if (error)
        {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)testRequestTokenWithOneInvalidField
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out."];
    [self.tokenizer requestToken:@{
                                   FORM_DICT_KEY_NAME: @"Omar Gonzalez",
                                   FORM_DICT_KEY_NUMBER: @"4111111111111111",
                                   FORM_DICT_KEY_CVC: @"123",
                                   FORM_DICT_KEY_MONTH: @"223", // Invalid Expiration Month
                                   FORM_DICT_KEY_YEAR: @"3012",
                                   }
                      completion: ^(NSDictionary *data, NSError *error)
     {
         XCTAssertNotNil(error, @"RequestToken with invalid expiration month should return an error object");
         XCTAssertNil(data, @"RequestToken with invalid expiration month should return a nil data object");
         [expectation fulfill];
     }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error)
    {
        if (error)
        {
            NSLog(@"Error: %@", error);
        }
    }];
}
@end
