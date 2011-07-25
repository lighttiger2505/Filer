//
//  CompositeTableVIewController.m
//  Filer
//
//  Created by ohashi tosikazu on 11/07/14.
//  Copyright 2011 nagoya-bunri. All rights reserved.
//

#import "CompositeTableVIewController.h"

#import "EditCompositeViewController.h"

#import "Composite.h"
#import "Folder.h"
#import "File.h"

@interface CompositeTableVIewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation CompositeTableVIewController

@synthesize currentComposite;
@synthesize fetchedResultsController=__fetchedResultsController;
@synthesize managedObjectContext=__managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewComposite:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
}

/**
 表示内容を絞り込む
 */
- (void)filterContent
{    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent = %@" ,currentComposite];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    	
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }  
	
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // タイトル表示を現在表示のフォルダの名称にする
    self.title = currentComposite.name;
    // 表示内容を現在のフォルダの中身に限定する
    [self filterContent];
    // テーブルの内容表示をリフレッシュ
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark AddNewComposite

/**
 新規に新しいオブジェクトを作成する
 */
- (IBAction)addNewComposite:(id)sender
{
    // フェッチコントローラからコンテキストを取得
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    // 新規オブジェクトを作成、編集するビューを作成して現在表示しているフォルダとコンテキストを設定する
    EditCompositeViewController *editViewController = [[EditCompositeViewController alloc] initWithStyle:UITableViewStyleGrouped];
    editViewController.parentComposite = currentComposite;
    editViewController.managedObjectContext = context;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:editViewController];
    
    // オブジェクト編集ビューをモーダルで表示
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
    [editViewController release];
}

#pragma mark -
#pragma mark TableViewDataSourceDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // コントローラーのフェッチ内容からセクション数を取得して返す
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // セクションの情報を取得
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    // セクション内の行数を取得して返す
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    // セルを作成
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // セルの内容を編集
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

/**
 セルの内容を編集する
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // セルに表示させるデータを取得
    Composite *composite = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // セルに表示されるデータがファイルのものならば
    if ([composite isKindOfClass:[File class]]) {
        // ファイルの画像を表示
        cell.imageView.image = [UIImage imageNamed:@"File.png"];
    }
    // セルに表示されるデータがフォルダのものならば
    if ([composite isKindOfClass:[Folder class]]) {
        // フォルダの画像を表示
        cell.imageView.image = [UIImage imageNamed:@"Folder.png"];
    }
    
    // 名前を設定
    cell.textLabel.text = composite.name;
    // 作成日時を設定
    cell.detailTextLabel.text = [composite.timestamp description];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Composite *composite = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([composite isKindOfClass:[File class]]) {
        // アクション無し
    }
    if ([composite isKindOfClass:[Folder class]]) {
        CompositeTableVIewController *compositeTableViewController = [[CompositeTableVIewController alloc] init];
        compositeTableViewController.currentComposite = (Folder*)composite;
        compositeTableViewController.managedObjectContext = self.managedObjectContext;
        [self.navigationController pushViewController:compositeTableViewController animated:YES];
        [compositeTableViewController release];
    }
} 

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Composite" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}   
@end
