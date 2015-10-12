//
//  ViewController.m
//  AcronymDen
//
//  Created by Harish on 10/10/15.
//  Copyright © 2015 Harish. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "MBProgressHUD.h"

#define BASE_URL @"http://www.nactem.ac.uk/software/acromine/dictionary.py"

@interface ViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    UITableView *tblView;
}

@property (nonatomic, retain) NSMutableArray *responseList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect deviceFrame = [[UIScreen mainScreen] bounds];
    
    UITextField *ipField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 90.0, (CGRectGetWidth(deviceFrame) - 120.0), 30.0)];
    ipField.tag = 1;
    ipField.placeholder = @"Enter Your Acronym";
    ipField.borderStyle = UITextBorderStyleNone;
    
    ipField.layer.cornerRadius = 3.0;
    ipField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    ipField.layer.borderWidth = 0.75;
    ipField.layer.shadowOffset = CGSizeMake(0.5, 0.2);
    ipField.layer.shadowColor = [[UIColor blackColor] CGColor];
    
    ipField.font = [UIFont systemFontOfSize:13.0];
    ipField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:ipField];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake((CGRectGetMaxX(ipField.frame)+10.0), 92.0, 90.0, 27.0);
    [searchBtn setTitle:@"Search" forState:UIControlStateNormal];
    searchBtn.layer.cornerRadius = 3.0f;
    searchBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    searchBtn.layer.borderWidth = 0.75;
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [searchBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchForTheInput:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(10.0, (CGRectGetMaxY(searchBtn.frame) + 10.0), (CGRectGetWidth(deviceFrame) - 20.0), (CGRectGetHeight(deviceFrame) - CGRectGetMaxY(searchBtn.frame) - 35.0)) style:UITableViewStylePlain];
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    tblView.layer.borderWidth = 1.0;
    tblView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    tblView.layer.cornerRadius = 3.0f;
    
    [self.view addSubview:tblView];
    
    //    [self getAcronymFor:@"NASA"];
}

- (void)getAcronymFor:(NSString *)shortString {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *keyToLoad = @"sf";
    if ([shortString rangeOfString:@" "].location != NSNotFound) {
        keyToLoad=@"lf";
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:BASE_URL parameters:[NSDictionary dictionaryWithObjectsAndKeys:shortString, keyToLoad, nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error = nil;
        
        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@", obj);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            @try {
                self.responseList = obj;
            }
            @catch (NSException *exception) {
                NSLog(@"Error while retrieving response list.. %@", exception);
            }
            @finally {
            }
            
            [tblView reloadData];
            
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat: @"Error while loading the Data.. %@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];
    
}

- (void) searchForTheInput:(UIButton *)sender {
    
    UITextField *ipField = (UITextField *)[self.view viewWithTag:1];
    [ipField resignFirstResponder];
    
    [self getAcronymFor:ipField.text];
    
}

#pragma mark - TableView Delegate and Datasource Handler
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.responseList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[[self.responseList objectAtIndex:section] objectForKey:@"lfs"] count];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    @try{
        NSDictionary *dict = [[[self.responseList objectAtIndex:indexPath.section] objectForKey:@"lfs"] objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", [[self.responseList objectAtIndex:indexPath.section] objectForKey:@"sf"], [dict objectForKey:@"lf"]];
    }
    @catch (NSException *exception) {
        NSLog(@"Error while retrieving response list.. %@", exception);
    }
    @finally {
        
    }
    
    
    return cell;
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
