//
//  ViewController.m
//  AGRegistrationForm
//
//  Created by Anton Gorlov on 11.04.16.
//  Copyright © 2016 Anton Gorlov. All rights reserved.
//

#import "ViewController.h"

typedef enum {
    
    AGFieldsName,
    AGFieldsLastName,
    AGFieldsLogin,
    AGFieldsPswd,
    AGFieldsAge,
    AGFieldsPhone,
    AGFieldsEmail,
    
    
} AGFields; //all fields


@interface ViewController () <UITextFieldDelegate> //will subscribe to Delegate for all "textField" and all "label"

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

     [self.firstNameField becomeFirstResponder]; //Your cursor in first field
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //first method
    
    for (int i = 0; i < ([self.textCollectionField count]-1); i++) { //press the button "Return" and cursor go to the next field.
        
        if (!([ textField isEqual:[self.textCollectionField objectAtIndex:i]])) {
            
            [textField resignFirstResponder]; // take away a kayboard
            
        }else {
            
            [[self.textCollectionField objectAtIndex:i+1] becomeFirstResponder];
        }
    }
    
    /* second method
     if ([textField isEqual:self.firstNameField]) {
     
     [self.lastNameField becomeFirstResponder];
     
     }
     
     if ([textField isEqual:self.lastNameField]) {
     
     [self.loginField becomeFirstResponder];
     
     }
     
     if ([textField isEqual:self.loginField]) {
     
     [self.passwordField becomeFirstResponder];
     
     }
     
     if ([textField isEqual:self.passwordField]) {
     
     [self.ageField becomeFirstResponder];
     
     }
     
     if ([textField isEqual:self.ageField]) {
     
     [self.numberField becomeFirstResponder];
     
     }
     
     if ([textField isEqual:self.numberField]) {
     
     [self.eMailField becomeFirstResponder];
     
     }else {
     [self.eMailField resignFirstResponder];
     
     }
     */
    
    return YES;
    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField  { // clean up a textField and a label.
    
    for (UILabel* label in self.labelCollectionField) {
        if (textField.tag == label.tag) {
            label.text = @"Empty";
        }
        
    }
    return YES;
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string { // change characters in the range
    
    NSString* resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    //this method change symbols in range with given string and return a new string
    
    
    switch (textField.tag) {
        case AGFieldsName:
            
            [self scriptNameField:textField shouldChangeCharactersInRange:range replacementString:string];
            self.nameLabel.text = resultString;
            return NO;
            break;
            
        case AGFieldsLastName:
            
            [self scriptLastNameField:textField shouldChangeCharactersInRange:range replacementString:string];
            self.surnameLabel.text = resultString;
            return NO;
            break;
            
        case AGFieldsLogin:
            self.loginLabel.text = resultString;
            break;
            
        case AGFieldsPswd:
            self.passwordLabel.text = resultString;
            break;
            
        case AGFieldsAge:
            
            [self scriptAgeField:textField shouldChangeCharactersInRange:range replacementString:string];
            self.ageLabel.text = resultString;
            
            return NO;
            break;
            
        case AGFieldsPhone:
            
            [self scriptPhoneField:textField shouldChangeCharactersInRange:range replacementString:string ];
            self.phoneLabel.text = resultString;
            
            return NO;
            break;
            
        case AGFieldsEmail:
            
            [self scriptEmailField:textField shouldChangeCharactersInRange:range replacementString:string];
            self.emailLabel.text = resultString;
            
            return NO;
            break;
            
            
        default:
            break;
    }
    
    return YES;
    
}

#pragma mark-Methods

- (BOOL)scriptPhoneField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    
    NSCharacterSet* validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray* components = [string componentsSeparatedByCharactersInSet:validationSet];
    
    if ([components count] > 1) {
        return NO;
    }
    
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    
    //+XX (XXX) XXX-XXXX
    
    NSLog(@"new string = %@", newString);
    
    NSArray* validComponents = [newString componentsSeparatedByCharactersInSet:validationSet];
    
    newString = [validComponents componentsJoinedByString:@""];
    
    // XXXXXXXXXXXX
    
    NSLog(@"new string fixed = %@", newString);
    
    static const int localNumberMaxLength = 7;
    static const int areaCodeMaxLength = 3;
    static const int countryCodeMaxLength = 3;
    
    if ([newString length] > localNumberMaxLength + areaCodeMaxLength + countryCodeMaxLength) {
        return NO;
    }
    
    
    NSMutableString* resultString = [NSMutableString string];
    
    /*
     XXXXXXXXXXXX
     +XX (XXX) XXX-XXXX - local number
     */
    
    NSInteger localNumberLength = MIN([newString length], localNumberMaxLength);
    
    if (localNumberLength > 0) {
        
        NSString* number = [newString substringFromIndex:(int)[newString length] - localNumberLength];
        
        [resultString appendString:number];
        
        if ([resultString length] > 3) {
            [resultString insertString:@"-" atIndex:3];
        }
        
    }
    
    if ([newString length] > localNumberMaxLength) {
        
        NSInteger areaCodeLength = MIN((int)[newString length] - localNumberMaxLength, areaCodeMaxLength);
        
        NSRange areaRange = NSMakeRange((int)[newString length] - localNumberMaxLength - areaCodeLength, areaCodeLength);
        
        NSString* area = [newString substringWithRange:areaRange];
        
        area = [NSString stringWithFormat:@"(%@) ", area];
        
        [resultString insertString:area atIndex:0];
    }
    
    if ([newString length] > localNumberMaxLength + areaCodeMaxLength) {
        
        NSInteger countryCodeLength = MIN((int)[newString length] - localNumberMaxLength - areaCodeMaxLength, countryCodeMaxLength);
        
        NSRange countryCodeRange = NSMakeRange(0, countryCodeLength);
        
        NSString* countryCode = [newString substringWithRange:countryCodeRange];
        
        countryCode = [NSString stringWithFormat:@"+%@ ", countryCode];
        
        [resultString insertString:countryCode atIndex:0];
    }
    
    
    textField.text = resultString;
    
    return NO;
    
    
}

- (BOOL)scriptNameField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSCharacterSet* validationName = [NSCharacterSet characterSetWithCharactersInString:@" @!#$%^?&,.<>""''()+-:;{}[]|/*//\\ 0123456789"];
    
    NSArray* componentsName = [string componentsSeparatedByCharactersInSet:validationName];
    
    if ([componentsName count] > 1) {
        return NO;
    }
    
    NSString* nameResultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([nameResultString length] > 15 ) { // до 15 символов
        
        return NO;
        
    }
    
    
    textField.text = nameResultString;
    
    return NO;
}


- (BOOL)scriptLastNameField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSCharacterSet* validationLastName = [NSCharacterSet characterSetWithCharactersInString:@" @!#$%^?&,.<>""''()+-:;{}[]|/*//\\ 0123456789"];
    
    NSArray* componentsLastname = [string componentsSeparatedByCharactersInSet:validationLastName];
    
    if ([componentsLastname count] > 1) {
        return NO;
    }
    
    NSString* lastNameResultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([lastNameResultString length] > 20 ) {
        
        return NO;
        
    }
    
    
    textField.text = lastNameResultString;
    
    return NO;
}


- (BOOL) scriptEmailField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //create a set of characters
    NSCharacterSet* validation = [NSCharacterSet characterSetWithCharactersInString:@"!#$%^?&,<>""''()+-:;{}[]|/*//\\ "];
    
    NSArray* components = [string componentsSeparatedByCharactersInSet:validation];
    
    if ([components count] > 1) {
        return NO;
    }
    
    NSString* emailResultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    
    if (([emailResultString rangeOfString:@"@"].length < 1)) {
        
        self.atPresent = NO;
    }
    
    if ([emailResultString length] <2 && [string isEqualToString:@"@"]) {
        return NO;
        
    }
    
    if (self.atPresent && [string isEqualToString:@"@"]) {
        return NO;
    }
    
    if ([string isEqualToString:@"@"]) {
        self.atPresent = YES;
    }
    
    
    textField.text = emailResultString;
    
    return NO;
    
}


- (BOOL) scriptAgeField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSCharacterSet* validation = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    NSArray* components = [string componentsSeparatedByCharactersInSet:validation];
    
    if ([components count] > 1) {
        return NO;
    }
    NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([resultString intValue] < 18) {
        
        textField.text = resultString;
        
        return NO;
        
    }else if ([resultString intValue] > 120){
        
        return NO;
        
    }else {
        textField.text = resultString;
        
    }
    
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
