//
//  GPKGAttributesDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGUserDao.h"
#import "GPKGAttributesRow.h"
#import "GPKGAttributesTable.h"

/**
 * Attributes DAO for reading attributes user data tables
 */
@interface GPKGAttributesDao : GPKGUserDao

/**
 * Constructor
 *
 * @param database        database connection
 * @param table           feature table
 * @return new attributes dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGAttributesTable *) table;

/**
 *  Create a new attributes row
 *
 *  @return attributes row
 */
-(GPKGAttributesRow *) newRow;

@end
