//
//  SearchViewController.m
//  pixster
//
//  Created by Timothy Lee on 7/30/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"

@interface SearchViewController ()

@property (nonatomic, strong) NSMutableArray *imageResults;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Pixster";
        self.imageResults = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [self.imageResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImageView *imageView = nil;
    const int IMAGE_TAG = 1;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = IMAGE_TAG;
        [cell.contentView addSubview:imageView];
    } else {
        imageView = (UIImageView *)[cell.contentView viewWithTag:IMAGE_TAG];
    }
    
    // Clear the previous image
    imageView.image = nil;
    [imageView setImageWithURL:[NSURL URLWithString:[self.imageResults[indexPath.row] valueForKeyPath:@"url"]]];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300;
}


#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
//    NSString *searchTerm = self.imageResults[section];
//    return [self.imageResults[searchTerm] count];
    return 1;
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return [self.imageResults count];
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];

    UIImageView *imageView = nil;
    const int IMAGE_TAG = 1;
    if (cell == nil) {
        cell = [cv dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = IMAGE_TAG;
        [cell.contentView addSubview:imageView];
    } else {
        imageView = (UIImageView *)[cell.contentView viewWithTag:IMAGE_TAG];
    }
    
    // Clear the previous image
    imageView.image = nil;
    [imageView setImageWithURL:[NSURL URLWithString:[self.imageResults[indexPath.row] valueForKeyPath:@"url"]]];
    
    return cell;

}
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
    
    UIImageView *photo =  self.imageResults[indexPath.row];
    // 2
    CGSize retval = photo.image.size.width > 0 ? photo.image.size : CGSizeMake(100, 100);
    retval.height += 35; retval.width += 35; return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

#pragma mark - UISearchDisplay delegate

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    [self.imageResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id results = [JSON valueForKeyPath:@"responseData.results"];
        if ([results isKindOfClass:[NSArray class]]) {
            [self.imageResults removeAllObjects];
            [self.imageResults addObjectsFromArray:results];
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    } failure:nil];
    
    [operation start];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    return YES;
}

@end
