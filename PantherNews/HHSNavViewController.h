//
//  HHSNavViewController.h
//  PantherNews
//
//  Created by Thomas Reeve on 6/20/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHSTableViewController.h"
#import "HHSScheduleTableViewController.h"
#import "HHSDailyAnnTableViewController.h"
#import "HHSEventsTableViewController.h"
#import "HHSNewsTableViewController.h"

@class HHSTableViewController;

@interface HHSNavViewController : UIViewController <HHSTableViewControllerDelegate>
@property (nonatomic) HHSTableViewController *tableViewController;
@property (nonatomic, strong) NSDictionary *tableviews;
@property (nonatomic) BOOL schedulesDownloaded;
@property (nonatomic) BOOL eventsDownloaded;
@property (nonatomic) BOOL newsDownloaded;
@property (nonatomic) BOOL dailAynnDownloaded;

@property (nonatomic, strong) HHSScheduleTableViewController *schedulesTVC;
@property (nonatomic, strong) HHSEventsTableViewController *eventsTVC;
@property (nonatomic, strong) HHSNewsTableViewController *newsTVC;
@property (nonatomic, strong) HHSDailyAnnTableViewController *dailyAnnTVC;


-(void)refreshDone:(int)type;
-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
-(void)setCurrentPopoverController:(UIPopoverController *)poc;
@end
