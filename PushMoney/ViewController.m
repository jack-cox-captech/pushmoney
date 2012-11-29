//
//  ViewController.m
//  PushMoney
//
//  Created by Jack Cox on 10/31/12.
//  Copyright (c) 2012 Jack Cox. All rights reserved.
//

#import "ViewController.h"
#import "NetworkManager.h"
#import "PMPeer.h"
#import "SendMoneyViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.peerTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PeerCell"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerListChanged:) name:kPeerListChanged object:nil];
	// Do any additional setup after loading the view, typically from a nib.
    
    // make yourself known and accept connection invitation
    [[NetworkManager sharedNetworkManager] startAcceptingInvitations];
    
    [self.peerTableView reloadData];
    
    self.title = @"Friends";
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // uncomment if you want to see the GKPeerPickerController work it's magic
//    GKPeerPickerController *ctl = [[GKPeerPickerController alloc] init];
//    ctl.delegate = self;
//
//    [ctl show];
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
    NSLog(@"picker connected to peer %@", peerID);
    
    [picker dismiss];
    
}
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
    return [[NetworkManager sharedNetworkManager] session];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

/**
 * Catches the global alert that the peer list changed.  Redraws the peer list table when this occurs
 **/
- (void) peerListChanged:(NSNotification *) notif {
    self.peerList = [notif.userInfo objectForKey:kPeerList];
    [self.peerTableView reloadData];
}

#pragma mark Tableview handling

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return fmax(1,[self.peerList count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PeerCell" forIndexPath:indexPath];
    
    if ([self.peerList count] > 0) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = [[self.peerList objectAtIndex:indexPath.row] peerName];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else {
        cell.textLabel.text = @"No Friends Nearby";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}
- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.peerList count] == 0) {
        return nil;
    }
    return indexPath;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    SendMoneyViewController *ctl = [[SendMoneyViewController alloc] initWithNibName:@"SendMoneyViewController" bundle:nil];
    ctl.peer = [self.peerList objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:ctl animated:YES];
}

@end
