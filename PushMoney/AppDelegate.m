//
//  AppDelegate.m
//  PushMoney
//
//  Created by Jack Cox on 10/31/12.
//  Copyright (c) 2012 Jack Cox. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

#import "NetworkManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    
    NetworkManager *netManager = [NetworkManager sharedNetworkManager];
    [netManager setupSession];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NetworkManager sharedNetworkManager] stopAcceptingInvitations];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NetworkManager sharedNetworkManager] setupSession];
    [[NetworkManager sharedNetworkManager] startAcceptingInvitations];
}



@end
