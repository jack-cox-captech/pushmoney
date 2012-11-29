//
//  CatchMoneyConversation.h
//  PushMoney
//
//  Created by Jack Cox on 11/3/12.
//  Copyright (c) 2012 Jack Cox. All rights reserved.
//

#import "Conversation.h"
#import "ConversationDelegate.h"
@interface CatchMoneyConversation : Conversation <UIAlertViewDelegate, ConversationDelegate> {
    UIAlertView *alertView;
    
}

@end
