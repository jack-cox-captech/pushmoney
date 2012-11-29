//
//  CatchMoneyConversation.m
//  PushMoney
//
//  Created by Jack Cox on 11/3/12.
//  Copyright (c) 2012 Jack Cox. All rights reserved.
//

#import "CatchMoneyConversation.h"

@implementation CatchMoneyConversation

- (void) changeConversationState:(GKPeerConnectionState)state {
    [super changeConversationState:state];
    
    NSError *error = nil;
    switch (self.conversationState) {
        case GKPeerStateAvailable:
            if (state == GKPeerStateConnecting) {
                NSLog(@"Connecting to peer %@", self.peer.peerName);
                [[NetworkManager sharedNetworkManager] acceptConnectFromPeer:self.peer error:&error];
                if (error != nil) {
                    [self reportError:[error localizedDescription]];
                }
            } else {
                // invalidate state change
                NSLog(@"Invalid state transition from %d to %d", self.conversationState, state);
            }
            break;
        case GKPeerStateConnected:
            // do nothing
            break;
        case GKPeerStateDisconnected:
            // do nothing, just cleanup
            break;
        default: {
            NSLog(@"Invalid state transition from %d to %d", self.conversationState, state);
        }
            break;
    }
}

- (void) receivedDataForConversation:(NSData *)data {
    [super receivedDataForConversation:data];
    
    NSError *error = nil;
    NSDictionary *jsonObject = [NSJSONSerialization
                                JSONObjectWithData:data
                                options:NSJSONReadingMutableContainers
                                error:&error];
    if ((error == nil) && [jsonObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"received data: %@", jsonObject);
        NSString *payloadType = [jsonObject objectForKey:@"payloadType"];

        if ([payloadType isEqualToString:@"pushMoney"]) {
            
            NSDecimalNumber *amount = [jsonObject
                                       valueForKeyPath:@"data.amount"];
            
            NSString *msg = [NSString
                             stringWithFormat:@"%@ wants to send you $%@. Accept it?",
                             self.peer.peerName, amount];
            alertView = [[UIAlertView alloc]
                         initWithTitle:@"You've got money"
                         message:msg
                         delegate:self
                         cancelButtonTitle:@"No"
                         otherButtonTitles:@"Yes", nil];
            [alertView show];
            
        } else {
            NSLog(@"Unknown response");
        }
    }
}

- (void) alertView:(UIAlertView *)av clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"User selected button %d", buttonIndex);
    if (buttonIndex <= 1) {
        [self sendPushMoneyResponse:(buttonIndex == 1)];
    }
}

- (void) sendPushMoneyResponse:(BOOL)accept {
    // do the next step in making a payment
    NSString *secretToken = [self newUUID];
    NetworkManager *nm = [NetworkManager sharedNetworkManager];
    [self reportStatusOfSend:@"Pushing money response..."];
    NSDictionary *payload=@{@"payloadType":@"pushMoneyResponse",
        @"payloadVersion":@1.0,
        @"data":@{@"sendingPeerID":[nm myPeerID],
        @"accept": (accept?@"YES":@"NO"),
        @"token":secretToken
    }};
    NSError *error = nil;
    [nm sendData:payload toPeer:self.peer error:&error];
    if (error != nil) {
        [self reportError:[error localizedDescription]];
    }
}

- (void) errorInSend:(NSString *)error {
    // TODO add error reporting
}

- (void) statusOfSend:(NSString *)status {
    NSLog(@"Status of send is: %@", status);
}

- (void) start {
    [super start];
}

-(void) end {
    [super end];
    if (alertView != nil) {
        [alertView dismissWithClickedButtonIndex:3 animated:YES];
    }
    
}

@end
