//
//  GPKGUserRelatedTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGUserCustomTable.h"
#import "GPKGContents.h"

/**
 * User Defined Related Table
 */
@interface GPKGUserRelatedTable : GPKGUserCustomTable

/**
 *  Foreign key to Contents
 */
@property (nonatomic, strong) GPKGContents *contents;

/**
 *  Initializer
 *
 *  @param tableName table name
 *  @param relationName   relation name
 *  @param columns   columns
 *
 *  @return new user related table
 */
-(instancetype) initWithTable: (NSString *) tableName andRelation: (NSString *) relationName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns;

/**
 *  Initializer
 *
 *  @param tableName table name
 *  @param relationName   relation name
 *  @param columns   columns
 *  @param requiredColumns   required columns
 *
 *  @return new user related table
 */
-(instancetype) initWithTable: (NSString *) tableName andRelation: (NSString *) relationName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns andRequiredColumns: (NSArray<NSString *> *) requiredColumns;

/**
 * Constructor
 *
 * @param relationName   relation name
 * @param userCustomTable user custom table
 *
 * @return new user related table
 */
-(instancetype) initWithRelation: (NSString *) relationName andCustomTable: (GPKGUserCustomTable *) userCustomTable;

/**
 * Get the relation name
 *
 * @return relation name
 */
-(NSString *) relationName;

@end
