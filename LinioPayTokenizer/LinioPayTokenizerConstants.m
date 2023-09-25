//
//  LinioPayTokenizerConstants.m
//  Pods
//
//  Created by Omar on 3/23/17.
//
//

#import "LinioPayTokenizerConstants.h"

@implementation LinioPayTokenizerConstants

NSString * const LPTS_API_PATH = @"https://vault.liniopay.com/token";
NSString * const LPTS_API_STG_PATH = @"https://vault-new.staging-liniopay.com/token";
NSString * const ERROR_DOMAIN = @"com.LinioPay.Tokenizer.ErrorDomain";
NSUInteger const CHAR_LENGTH_KEY = 40;
NSUInteger const CHAR_LENGTH_CVC = 3;
NSUInteger const CHAR_LENGTH_CVC_AMEX = 4;
NSUInteger const CHAR_LENGTH_COUNTRY = 2;
NSUInteger const MIN_CHAR_NAME = 5;
NSUInteger const MAX_CHAR_NAME = 60;
NSUInteger const MAX_CHAR_STREET_1 = 255;
NSUInteger const MAX_CHAR_STREET_2 = 255;
NSUInteger const MAX_CHAR_STREET_3 = 255;
NSUInteger const MAX_CHAR_CITY = 255;
NSUInteger const MAX_CHAR_STATE = 120;
NSUInteger const MAX_CHAR_COUNTY = 255;
NSUInteger const MAX_CHAR_PHONE = 50;
NSUInteger const MAX_CHAR_POSTAL_CODE = 20;
NSUInteger const ERROR_CODE_REQUIRED_KEY = 100;
NSUInteger const ERROR_CODE_REQUIRED_NAME = 105;
NSUInteger const ERROR_CODE_REQUIRED_CARD_NUMBER = 110;
NSUInteger const ERROR_CODE_REQUIRED_MONTH = 130;
NSUInteger const ERROR_CODE_REQUIRED_YEAR = 140;
NSUInteger const ERROR_CODE_REQUIRED_STREET_1 = 160;
NSUInteger const ERROR_CODE_REQUIRED_CITY = 170;
NSUInteger const ERROR_CODE_REQUIRED_STATE = 180;
NSUInteger const ERROR_CODE_REQUIRED_COUNTRY = 190;
NSUInteger const ERROR_CODE_REQUIRED_POSTAL_CODE = 195;
NSUInteger const ERROR_CODE_INVALID_KEY = 400;
NSUInteger const ERROR_CODE_INVALID_CARD_NUMBER = 410;
NSUInteger const ERROR_CODE_INVALID_CVC = 420;
NSUInteger const ERROR_CODE_INVALID_MONTH = 430;
NSUInteger const ERROR_CODE_INVALID_YEAR = 440;
NSUInteger const ERROR_CODE_INVALID_EXPIRATION = 450;
NSUInteger const ERROR_CODE_INVALID_COUNTRY = 490;
NSUInteger const ERROR_CODE_INVALID_POSTAL_CODE = 495;
NSUInteger const ERROR_CODE_INVALID_EMAIL = 496;
NSUInteger const ERROR_CODE_CHAR_MAX_LIMIT_NAME = 505;
NSUInteger const ERROR_CODE_CHAR_MAX_LIMIT_STREET_1 = 560;
NSUInteger const ERROR_CODE_CHAR_MAX_LIMIT_STREET_2 = 565;
NSUInteger const ERROR_CODE_CHAR_MAX_LIMIT_STREET_3 = 566;
NSUInteger const ERROR_CODE_CHAR_MAX_LIMIT_PHONE = 567;
NSUInteger const ERROR_CODE_CHAR_MAX_LIMIT_CITY = 570;
NSUInteger const ERROR_CODE_CHAR_MAX_LIMIT_STATE = 580;
NSUInteger const ERROR_CODE_CHAR_MAX_LIMIT_COUNTY = 581;
NSUInteger const ERROR_CODE_CHAR_MAX_LIMIT_POSTAL_CODE = 585;
NSUInteger const ERROR_CODE_CHAR_MIN_LIMIT_NAME = 605;
NSString * const ERROR_DESC_REQUIRED_KEY = @"Tokenization Key is Required";
NSString * const ERROR_DESC_REQUIRED_NAME = @"Card Holder Name is Required";
NSString * const ERROR_DESC_REQUIRED_CARD_NUMBER = @"Credit Card Number is Required";
NSString * const ERROR_DESC_REQUIRED_MONTH = @"Expiration Month is Required";
NSString * const ERROR_DESC_REQUIRED_YEAR = @"Expiration Year is Required";
NSString * const ERROR_DESC_REQUIRED_ADDRESS_FIRST_NAME = @"Address First Name is Required";
NSString * const ERROR_DESC_REQUIRED_ADDRESS_LAST_NAME = @"Address Last Name is Required";
NSString * const ERROR_DESC_REQUIRED_STREET_1 = @"Address Street line 1 is Required";
NSString * const ERROR_DESC_REQUIRED_CITY = @"Address City is Required";
NSString * const ERROR_DESC_REQUIRED_STATE = @"Address State is Required";
NSString * const ERROR_DESC_REQUIRED_COUNTRY = @"Address Country is Required";
NSString * const ERROR_DESC_REQUIRED_POSTAL_CODE = @"Address Postal Code is Required";
NSString * const ERROR_DESC_INVALID_KEY = @"Invalid Tokenization Key - Should Contain 40 Characters";
NSString * const ERROR_DESC_INVALID_CARD_NUMBER = @"Invalid Credit Card Number";
NSString * const ERROR_DESC_INVALID_CVC = @"Invalid CVC Number";
NSString * const ERROR_DESC_INVALID_MONTH = @"Invalid Expiration Month - Should Contain 2 Numeric Characters";
NSString * const ERROR_DESC_INVALID_YEAR = @"Invalid Expiration Year - Should Contain 4 Numeric Characters";
NSString * const ERROR_DESC_INVALID_EXPIRATION = @"Invalid Expiration date - Should Containt Current or Future Date";
NSString * const ERROR_DESC_INVALID_COUNTRY = @"Invalid Country - Should Contain 3 Characters Country Code";
NSString * const ERROR_DESC_INVALID_POSTAL_CODE = @"Invalid Postal Code - Should Contain Only Numeric Characters";
NSString * const ERROR_DESC_INVALID_EMAIL = @"Invalid E-mail Address: %@";
NSString * const ERROR_DESC_CHAR_MAX_LIMIT_NAME = @"Card Holder Name Should Have Less Than %lu Characters";
NSString * const ERROR_DESC_CHAR_MAX_LIMIT_STREET_1 = @"Address Street line 1 Should Have Less Than %lu Characters";
NSString * const ERROR_DESC_CHAR_MAX_LIMIT_STREET_2 = @"Address Street line 2 Should Have Less Than %lu Characters";
NSString * const ERROR_DESC_CHAR_MAX_LIMIT_STREET_3 = @"Address Street line 3 Should Have Less Than %lu Characters";
NSString * const ERROR_DESC_CHAR_MAX_LIMIT_PHONE = @"Phone Number Should Have Less Than %lu Characters";
NSString * const ERROR_DESC_CHAR_MAX_LIMIT_CITY = @"Address City Should Have Less Than %lu Characters";
NSString * const ERROR_DESC_CHAR_MAX_LIMIT_STATE = @"Address State Should Have Less Than %lu Characters";
NSString * const ERROR_DESC_CHAR_MAX_LIMIT_COUNTY = @"County Should Have Less Than %lu Characters";
NSString * const ERROR_DESC_CHAR_MAX_LIMIT_POSTAL_CODE = @"Address Postal Code Should Have Less Than %lu Characters";
NSString * const ERROR_DESC_CHAR_MIN_LIMIT_NAME = @"Card Holder Name Should Have More Than %lu Characters";

@end
