//
//  SendMoneyViewController.m
//  PushMoney
//
//  Created by Jack Cox on 10/31/12.
//  Copyright (c) 2012 Jack Cox. All rights reserved.
//

#import "SendMoneyViewController.h"
#import "PMPeer.h"
#import "NetworkManager.h"

#import "PushMoneyConversation.h"

@interface SendMoneyViewController ()

@end

@implementation SendMoneyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Push Money";
    
    self.amountField.inputAccessoryView = self.keyboardToolbar;
    
    self.promptLabel.text = [NSString stringWithFormat:@"Push Money To %@", self.peer.peerName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)keyboardDonePressed:(id)sender {
    [self.amountField resignFirstResponder];
}
- (IBAction)sendItPressed:(id)sender {
    [self.statusSpinner startAnimating];
    
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:self.amountField.text];
    
    PushMoneyConversation *conf = [[PushMoneyConversation alloc] init];
    
    conf.amount = amount;
    self.peer.conversation = conf;
    self.peer.conversation.delegate = self;
    [self.peer.conversation start];
    
}

- (void)responseReceived:(NSDictionary *)response {
    BOOL accepted = [[response valueForKeyPath:@"data.accept"] isEqualToString:@"YES"];
    NSString *token = [response valueForKeyPath:@"data.token"];
    NSLog(@"Accepted = %d and token = %@", accepted, token);
    
    self.statusLabel.text = (accepted ? @"Money Accepted" : @"Money Rejected");
    
    [self.statusSpinner stopAnimating];
    
}
- (void)statusOfSend:(NSDictionary *)statusInfo {
    
    NSString *status = [statusInfo objectForKey:@"status"];
    self.statusLabel.text = status;
}
- (void)errorInSend:(NSDictionary *)errorInfo {
    
    [self.statusSpinner stopAnimating];
}
@end
