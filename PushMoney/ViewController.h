//
//  ViewController.h
//  PushMoney
//
//  Created by Jack Cox on 10/31/12.
//  Copyright (c) 2012 Jack Cox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, GKPeerPickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *peerTableView;

@property (strong, nonatomic) NSArray *peerList;

@end
