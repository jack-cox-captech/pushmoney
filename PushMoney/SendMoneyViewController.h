//
//  SendMoneyViewController.h
//  PushMoney
//
//  Created by Jack Cox on 10/31/12.
//  Copyright (c) 2012 Jack Cox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConversationDelegate.h"

@class PMPeer;
@interface SendMoneyViewController : UIViewController <UITextFieldDelegate, ConversationDelegate>



@property (strong, nonatomic) PMPeer        *peer;

@property (weak, nonatomic) IBOutlet UITextField *amountField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *statusSpinner;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (strong, nonatomic) IBOutlet UIToolbar *keyboardToolbar;

- (IBAction)sendItPressed:(id)sender;

- (IBAction)keyboardDonePressed:(id)sender;


@end
