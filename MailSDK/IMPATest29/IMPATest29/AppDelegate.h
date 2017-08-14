//
//  AppDelegate.h
//  IMPATest29
//
//  Created by Deepak Bhati on 7/29/17.
//  Copyright © 2017 bdAppManiac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (strong, nonatomic) UIView *loadingView;

- (void)showLoading;
- (void)hideLoading;

- (void)saveContext;


@end

