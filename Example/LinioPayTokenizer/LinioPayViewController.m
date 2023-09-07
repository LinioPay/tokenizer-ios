//
//  linioPayViewController.m
//  LinioPayTokenizer
//
//  Created by omargon on 03/14/2017.
//  Copyright (c) 2017 omargon. All rights reserved.
//

#import "LinioPayViewController.h"
#import "LinioPayTokenizer/LinioPayTokenizer.h"

@interface LinioPayViewController()

@property (nonatomic, readonly) LinioPayTokenizer *tokenizer;

@end

@implementation LinioPayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _tokenizer = [[LinioPayTokenizer alloc] initWithKey:@"test_20e3ec8c5ce9bb5adced9b8abe297929684" environment:prod];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitForm:(id)sender
{
    [self makeRequest];
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self resignFirstResponder];
}

- (void)makeRequest
{
    NSLog(@"Submitting form");
    
    [_tokenizer requestToken:
     @{
       FORM_DICT_KEY_NAME: nameField.text,
       FORM_DICT_KEY_NUMBER: numberField.text,
       FORM_DICT_KEY_CVC: cvcField.text,
       FORM_DICT_KEY_MONTH: monthField.text,
       FORM_DICT_KEY_YEAR: yearField.text,
       FORM_DICT_KEY_ADDRESS: @{
               FORM_DICT_KEY_ADDRESS_FIRST_NAME: addressFirstNameField.text,
               FORM_DICT_KEY_ADDRESS_LAST_NAME: addressLastNameField.text,
               FORM_DICT_KEY_STREET_1: addressLine1Field.text,
               FORM_DICT_KEY_STREET_2: addressLine2Field.text,
               FORM_DICT_KEY_STREET_3: @"optional line 3",
               FORM_DICT_KEY_PHONE: @"(917) 1010-2020",
               FORM_DICT_KEY_CITY: addressCityField.text,
               FORM_DICT_KEY_STATE: addressStateField.text,
               FORM_DICT_KEY_COUNTY: @"optional line county",
               FORM_DICT_KEY_COUNTRY: addressCountryField.text,
               FORM_DICT_KEY_POSTAL_CODE: addressPostalCodeField.text,
               FORM_DICT_KEY_EMAIL: @"test@liniopay.com"
               },
       }
    oneTime:false
    completion: ^(NSDictionary *data, NSError *error)
    {
        NSMutableString *message = [[NSMutableString alloc] init];
        if(error!=nil)
        {
            message = [NSMutableString stringWithFormat:@"%@", [error userInfo]];
        }
        else
        {
            message = [NSMutableString stringWithFormat:@"%@", data];
        }

        dispatch_async(dispatch_get_main_queue(),
        ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tokenizer Response"
                                                            message:[NSString stringWithFormat:@"%@", message]
                                                           delegate:nil cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    }];
}

@end
