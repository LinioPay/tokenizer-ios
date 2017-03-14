//
//  lpViewController.m
//  pay-tokenizer-ios
//
//  Created by omargon on 03/01/2017.
//  Copyright (c) 2017 omargon. All rights reserved.
//

#import "lpViewController.h"
#import "lpTokenizer.h"

@interface lpViewController ()


@end

@implementation lpViewController

lpTokenizer *tokenizer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    tokenizer = [[lpTokenizer alloc] initWithKey:@"1234345345333"];
    [self makeRequest];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitForm:(id)sender {
    [self makeRequest];
}

- (IBAction)DismissKeyboard:(id)sender {
    
    [self resignFirstResponder];
    
}

- (void)makeRequest {
    NSLog(@"Submitting form");
    [tokenizer requestToken:
     @{
       @"name": nameField.text,
       @"number": numberField.text,
       @"cvc": cvcField.text,
       @"month": monthField.text,
       @"year": yearField.text,
       @"address": @{
               @"addressStreet1": addressLine1Field.text,
               @"addressStreet2": addressLine2Field.text,
               @"addressCity": addressCityField.text,
               @"addressState": addressStateField.text,
               @"addressCountryCode": addressCountryCodeField.text,
               @"addressPostalCode": addressPostalCodeField.text,
               },
       } completion: ^(NSDictionary *data, NSError *error){
           
           NSMutableString *message = [[NSMutableString alloc] init];
           if(error!=nil)
           {
               message = [NSMutableString stringWithFormat:@"%@", error.userInfo];
           }
           else
           {
               message = [NSMutableString stringWithFormat:@"%@", data];
           }
           
           dispatch_async(dispatch_get_main_queue(), ^{
               UIAlertView *alert = [[UIAlertView alloc]
                                     initWithTitle:@"Tokenizer Response"
                                     message:[NSString stringWithFormat:@"%@", message]
                                     delegate:nil
                                     cancelButtonTitle:@"Dismiss"
                                     otherButtonTitles:nil];
               [alert show];
           });
           
       }];
}
@end