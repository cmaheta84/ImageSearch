//
//  ViewController.m
//  googImageSearch
//
//  Created by Sandip Patel on 2/2/14.
//  Copyright (c) 2014 Y.CORP.YAHOO.COM\cmaheta84. All rights reserved.
//

#import "ViewController.h"
#import "FlickrPhotoCell.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"

@interface ViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, weak) IBOutlet UITextField *textField;
@property(nonatomic, strong) NSMutableDictionary *searchResults;
@property(nonatomic, strong) NSMutableArray *searches;
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_textField setDelegate:self];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_cork.png"]];
    
    UIImage *textFieldImage = [[UIImage imageNamed:@"search_field.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.textField setBackground:textFieldImage];
    self.searches = [@[] mutableCopy];
    self.searchResults = [@{} mutableCopy];
    [self.collectionView registerClass:[FlickrPhotoCell class] forCellWithReuseIdentifier:@"FlickrCell"];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) reloadMore:(int)startParam query:(NSString *)queryParam {
    NSString *searchTerm = queryParam;
    int start = startParam+4;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&start=%d",searchTerm,startParam]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id results = [JSON valueForKeyPath:@"responseData.results"];
        if ([results isKindOfClass:[NSArray class]]) {
            [self.searches insertObject:searchTerm atIndex:0];
            NSMutableArray *existingResults = [[NSMutableArray alloc] initWithArray:self.searchResults[searchTerm] copyItems:YES] ;
            [existingResults addObjectsFromArray:results];
            self.searchResults[searchTerm] = existingResults;
            dispatch_async(dispatch_get_main_queue(), ^{
                // Placeholder: reload collectionview data
                if(start == 40) {
                    [self.collectionView reloadData];
                }
            });
            [self reloadMore:start query:searchTerm];
        }
    } failure:nil];
    
    [operation start];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    NSString *searchTerm = [textField.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@",searchTerm]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id results = [JSON valueForKeyPath:@"responseData.results"];
        if ([results isKindOfClass:[NSArray class]]) {
            [self.searches insertObject:searchTerm atIndex:0];
            self.searchResults[searchTerm] = results;
            dispatch_async(dispatch_get_main_queue(), ^{
                // Placeholder: reload collectionview data
                [self.collectionView reloadData];
            });
            [self reloadMore:0 query:searchTerm];
        }
    } failure:nil];
    
    [operation start];
    [textField resignFirstResponder];
    return YES; 
}
#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSString *searchTerm = self.searches[section];
    return [self.searchResults[searchTerm] count];
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return [self.searches count];
}
// 3

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FlickrPhotoCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor whiteColor];
    NSString *searchTerm = self.searches[indexPath.section];
    UIImageView *imageView = [[UIImageView alloc]init];
    NSLog(@"%d",indexPath.row);
    [imageView setImageWithURL:[NSURL URLWithString:[self.searchResults[searchTerm][indexPath.row] valueForKeyPath:@"url"]]];
    
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    imageView.frame = CGRectMake(0,0,120,120);
    imageView.clipsToBounds = YES;
    [cell addSubview:imageView];
    return cell;
}
/*
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FlickrPhotoCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
    NSString *searchTerm = self.searches[indexPath.section];
    cell.photo = self.searchResults[searchTerm]
    [indexPath.row];
    return cell;
}
 */
// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 2
    CGSize retval = CGSizeMake(120, 120);
    retval.height += 35; retval.width += 35; return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}
@end
