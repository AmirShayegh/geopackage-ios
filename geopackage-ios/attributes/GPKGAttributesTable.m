//
//  GPKGAttributesTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGAttributesTable.h"
#import "GPKGContentsDataTypes.h"
#import "GPKGAttributesColumns.h"

@implementation GPKGAttributesTable

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    self = [super initWithColumns:[[GPKGAttributesColumns alloc] initWithTable:tableName andColumns:columns]];
    return self;
}

-(NSString *) dataType{
    return GPKG_CDT_ATTRIBUTES_NAME;
}

-(void) validateContents:(GPKGContents *)contents{
    // Verify the Contents have an attributes data type
    enum GPKGContentsDataType dataType = [contents contentsDataType];
    if (dataType != GPKG_CDT_ATTRIBUTES) {
        [NSException raise:@"Invalid Contents Data Type" format:@"The Contents of an Attributes Table must have a data type of %@", GPKG_CDT_ATTRIBUTES_NAME];
    }
}

-(GPKGAttributesColumns *) attributesColumns{
    return (GPKGAttributesColumns *) [super userColumns];
}

-(GPKGUserColumns *) createUserColumnsWithColumns: (NSArray<GPKGUserColumn *> *) columns{
    return [[GPKGAttributesColumns alloc] initWithTable:[self tableName] andColumns:columns andCustom:YES];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGAttributesTable *attributesTable = [super mutableCopyWithZone:zone];
    return attributesTable;
}

@end
