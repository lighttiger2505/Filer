//
//  CompositeTableVIewController.h
//  Filer
//
//  Created by ohashi tosikazu on 11/07/14.
//  Copyright 2011 nagoya-bunri. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Folder;

/**
 ツリー構造における現在のフォルダの中身をテーブルで一覧表示するビューコントローラー
 */
@interface CompositeTableVIewController : UITableViewController <NSFetchedResultsControllerDelegate>{
    
}
@property (nonatomic, retain) Folder *currentComposite;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)addNewComposite:(id)sender;

@end
