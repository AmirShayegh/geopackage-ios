//
//  GPKGFeatureIndexResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/15/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureRow.h"

/**
 *  Feature Index Results fast enumeration to iterate on feature rows in a for loop
 */
@interface GPKGFeatureIndexResults : NSObject <NSFastEnumeration>

/**
 *  Initialize
 *
 *  @return feature index results
 */
-(instancetype) init;

/**
 *  Get the count of results
 *
 *  @return count
 */
-(int) count;

/**
 *  Move to the next feature row if additional exist
 *
 *  @return true if feature row to retrieve
 */
-(BOOL) moveToNext;

/**
 *  Get the current location feature row
 *
 *  @return feature row
 */
-(GPKGFeatureRow *) getFeatureRow;

/**
 *  Get the current location feature id
 *
 *  @return feature id
 */
-(NSNumber *) getFeatureId;

/**
 *  Close the results
 */
-(void) close;

@end
