//
//  HHSNewsTableViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/21/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSNewsTableViewController.h"
#import "HHSNewsCell.h"
#import "HHSNewsDetailsViewController.h"
#import "HHSImageStore.h"


@interface HHSNewsTableViewController ()

@end

@implementation HHSNewsTableViewController

- (id)init
{
    self = [super init];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"School News";
        
        self.articleStore = [[HHSArticleStore alloc] initWithType:[HHSArticleStore HHSArticleStoreTypeNews]];
        
        //these are values that the parser will scan for
        NSDictionary *parserNames = @{@"entry" : @"entry",
                                      @"date" : @"updated",
                                      @"startTime" : @"",
                                      @"title" : @"title",
                                      @"link" : @"link",
                                      @"details" : @"content",
                                      @"keepHtmlTags" : @"keep"};
        self.parserElementNames = parserNames;
        
        self.feedUrlString = @"https://sites.google.com/a/holliston.k12.ma.us/holliston-high-school/general-info/news/posts.xml";
        
        if ([[self.articleStore allArticles] count] == 0) {
            [self getArticlesFromFeed];
        } else {
            NSArray *storeArticles = [self.articleStore allArticles] ;
            
            NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
            NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
            NSArray *sortedArray = [storeArticles sortedArrayUsingDescriptors:descriptors];
            NSArray* reversedArray = [[sortedArray reverseObjectEnumerator] allObjects];
            [self addArticlesToList:reversedArray];
            
            [self.articleStore replaceAllArticlesWith:reversedArray];
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"HHSNewsCell" bundle:nil];
    
    //Register this NIB, which contains the cell
    [self.tableView registerNib:nib forCellReuseIdentifier:@"HHSNewsCell"];
    
}

/**
 The NSOperation "ParseOperation" calls addArticlesToList: via NSNotification, on the main thread which in turn calls this method, with batches of parsed objects.
 */

- (void)addArticlesToList:(NSArray *)articles {
    
    [self.articlesList removeAllObjects];
    [self.tableView reloadData];
    
    NSInteger startingRow = [self.articlesList count];
    NSInteger articleCount = [articles count];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:articleCount];
    
    for (NSInteger row = startingRow; row < (startingRow + articleCount); row++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    [self.articlesList addObjectsFromArray:articles];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.articleStore saveChanges];
    
    [self.delegate refreshDone:[HHSArticleStore HHSArticleStoreTypeNews]];
    [self.activityView stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = (int)[self.articlesList count];
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //static NSString *kArticleCellID = @"ArticleCellID";
    HHSNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HHSNewsCell"];
    
    // Get the specific earthquake for this row.
    HHSArticle *article = (self.articlesList)[indexPath.row];
    
    //Configure the cell with the BNRItem
    cell.titleLabel.text = article.title;
    cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEE, MMM d";
        //dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    //Use filtered NSDate object to set dateLabel contents
    cell.dateLabel.text = [dateFormatter stringFromDate:article.date];
    cell.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    cell.thumbnailView.image = article.thumbnail;
    
    //__weak HHSNewsCell *weakCell = cell;
    
    cell.actionBlock = ^{NSLog(@"Going to show image for %@", article);
    
    //HHSNewsCell *strongCell = weakCell;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
    NSString *articleKey = article.articleKey;
    
    //If there is no image, we don't need to display anything
    UIImage *img = [[HHSImageStore sharedStore] imageForKey:articleKey];
    if (!img) {
        return;
    }
    
    //Make a rectangle for the frame of the thumbnail relative to table view
    //CGRect rect = [self.view convertRect:strongCell.thumbnailView.bounds
    //                fromView:strongCell.thumbnailView];
    
    //Create a new BNRImageViewController and set its image
    //BNRImageViewController *ivc = [[BNRImageViewController alloc] init];
    //ivc.image = img;
    
    ////Present a 600x600 popover from the rect
    //self.imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
    //self.imagePopover.delegate = self;
    //self.imagePopover.popoverContentSize = CGSizeMake(600, 600);
    //[self.imagePopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } ;
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HHSNewsDetailsViewController *vc = [[HHSNewsDetailsViewController alloc] init];
    
    //NSArray *items = [[BNRItemStore sharedStore] allItems];
    HHSArticle *selectedArticle = self.articlesList[indexPath.row];
    
    //Give deatil view controller a pointer to the item object in the row
    vc.article = selectedArticle;
    
    //Piush it onto the top of the navigation controller's stack
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

@end
