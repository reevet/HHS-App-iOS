//
//  HHSSchedulesVC.m
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSSchedulesVC.h"
#import "HHSScheduleCell.h"
#import "HHSScheduleDetailsViewController.h"
#import "HHSMainViewController.h"
#import "HHSDetailPager.h"

@interface HHSSchedulesVC ()
@property (nonatomic, strong) NSDictionary *images;
@property (nonatomic) BOOL skipToday;

@end

@implementation HHSSchedulesVC

- (id)initWithStore:(HHSArticleStore *)store
{
    self = [super initWithStore:store];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Schedules";
        
        
        UIImage *a = [UIImage imageNamed:@"a_sm"];
        UIImage *b = [UIImage imageNamed:@"b_sm"];
        UIImage *c = [UIImage imageNamed:@"c_sm"];
        UIImage *d = [UIImage imageNamed:@"d_sm"];
        UIImage *star = [UIImage imageNamed:@"star_sm"];
        
        _images = @{@"a" : a,
                    @"b" : b,
                    @"c" : c,
                    @"d" : d,
                    @"star" : star };
    }
    
    self.skipToday = NO;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"HHSScheduleCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"HHSScheduleCell"];
    
    [self reloadArticlesFromStore];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.owner.splitViewController) {
        [self sendToDetailPager:0 parentViewController:self];
    }
    
}

- (void)reloadArticlesFromStore {
    
    [super reloadArticlesFromStore];
    
    NSMutableArray *articles = [[self.articleStore allArticles] mutableCopy];
    
    if ((articles == nil) || !(self.viewLoaded) ) {
        return;
    }
    
    [self.articlesList removeAllObjects];
    [self.tableView reloadData];
    
    /*for (int i = 0; i< [self.tableView numberOfSections]; i++) {
     NSIndexSet *is = [[NSIndexSet alloc] initWithIndex:0];
     [self.tableView deleteSections:is withRowAnimation:UITableViewRowAnimationNone];
     }*/
    
    if ([articles count] >=2) {
        NSDate *todayDate = [[NSDate alloc] init];
        NSDateComponents *todayComp = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:todayDate];
        NSInteger todayMonth = [todayComp month];
        NSInteger todayDay = [todayComp day];
        NSInteger todayHour = [todayComp hour];
        
        if (todayHour >=14) {
            HHSArticle *firstArticle = (HHSArticle *) articles[0];
            NSDate *firstDate = firstArticle.date;
            NSDateComponents *firstComp =[[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:firstDate] ;
            NSInteger firstMonth = [firstComp month];
            NSInteger firstDay = [firstComp day];
            
            if ((todayMonth == firstMonth) && (todayDay == firstDay)) {
                [articles removeObjectAtIndex:0];
                self.skipToday = YES;
            }
        }
    }
    
    int currentWeek = -1;
    int numSections = 0;
    int numRows = 0;
    
    [self.tableView beginUpdates];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    for (HHSArticle *art in articles) {
        
        NSDate *date= art.date;
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:NSWeekOfYearCalendarUnit fromDate:date];
        int weekOfYear = (int)[components weekOfYear];
        
        if(weekOfYear != currentWeek) {
            [self.articlesList addObject:[[NSMutableArray alloc] init]];
            numSections++;
            numRows=1;
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:numSections-1] withRowAnimation:UITableViewRowAnimationNone];
            
        }
        currentWeek = weekOfYear;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numRows-1 inSection:numSections-1];
        [indexPaths addObject:indexPath];
        numRows++;
        
        [self.articlesList[numSections-1] addObject:art];
    }
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView endUpdates];
    [self.activityView stopAnimating];
    
    if (self.owner.currentView == self) {
        [self.owner hideWaiting];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [self.articlesList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.articlesList[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //static NSString *kArticleCellID = @"ArticleCellID";
    HHSScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HHSScheduleCell"];
    
    int section = (int)indexPath.section;
    int row = (int)indexPath.row;
    
    // Get the specific earthquake for this row.
    HHSArticle *article = self.articlesList[section][row];
    
    //Configure the cell with the BNRItem
    cell.titleLabel.text = article.title;
    //cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEE, MMM d";
        //dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    
    //Use filtered NSDate object to set dateLabel contents
    cell.dateLabel.text = [dateFormatter stringFromDate:article.date];
    //cell.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    NSString *initial = [article.title substringToIndex:1];
    if ([initial isEqualToString:@"A"]) {
        cell.iconView.image = _images[@"a"];
    }
    else if ([initial isEqualToString:@"B"]) {
        cell.iconView.image = _images[@"b"];
    }
    else if ([initial isEqualToString:@"C"]) {
        cell.iconView.image = _images[@"c"];
    }
    else if ([initial isEqualToString:@"D"]) {
        cell.iconView.image = _images[@"d"];
    }
    else {
        cell.iconView.image = _images[@"star"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //HHSScheduleDetailsViewController *vc = [[HHSScheduleDetailsViewController alloc] init];
    int index = 0;
    for (int j=0; j<=indexPath.section; j++) {
        for (int i=0; i<[self.articlesList[j] count]; i++) {
            if ((j==indexPath.section) && (i==indexPath.row)) {
                break;
            }
            index++;
        }
    }
    if (_skipToday) {
        index++;
    }
    
    [self sendToDetailPager:index parentViewController:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSArray *articles = [[self articleStore] allArticles];
    UIViewController *returnVC = [UIViewController alloc];
    
    int index = [(HHSScheduleDetailsViewController *)viewController articleNumber];
    
    index++;
    if (index >=articles.count) {
        returnVC = nil;
    } else {
        returnVC =[self viewControllerAtIndex:index];
    }
    
    return returnVC;
    
}
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    UIViewController *returnVC = [UIViewController alloc];
    
    int index = [(HHSScheduleDetailsViewController *)viewController articleNumber];
    
    index--;
    if (index <0) {
        returnVC = nil;
    } else {
        returnVC =[self viewControllerAtIndex:index];
    }
    
    return returnVC;
    
}

-(UIViewController *)viewControllerAtIndex:(int)index {
    
    NSArray *articles = [[self articleStore] allArticles];
    
    HHSScheduleDetailsViewController *detailvc = [[HHSScheduleDetailsViewController alloc] init];
    detailvc.articleNumber = index;
    detailvc.article = articles[index];
    
    return detailvc;
}

@end