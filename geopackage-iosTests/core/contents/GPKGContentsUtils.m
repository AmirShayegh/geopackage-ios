//
//  GPKGContentsUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/25/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGContentsUtils.h"
#import "GPKGTestUtils.h"

@implementation GPKGContentsUtils

+(void) testReadWithGeoPackage: (GPKGGeoPackage *) geoPackage andExpectedResults: (NSNumber *) expectedResults{
    
    GPKGContentsDao *dao = [geoPackage getContentsDao];
    GPKGResultSet *results = [dao queryForAll];
    if (expectedResults != nil) {
        [GPKGTestUtils assertEqualIntWithValue:[expectedResults intValue] andValue2:results.count];
    }
    
    if (results.count > 0) {
        
        int count = results.count;
        
        // Verify non nulls
        while([results moveToNext]){
            GPKGContents *result = (GPKGContents *)[dao getObject:results];
            [GPKGTestUtils assertNotNil:result.tableName];
            [GPKGTestUtils assertNotNil:result.dataType];
            [GPKGTestUtils assertEqualWithValue:result.dataType andValue2:[GPKGContentsDataTypes name:[result getContentsDataType]]];
            [GPKGTestUtils assertNotNil:result.lastChange];
            GPKGSpatialReferenceSystem *srs = [dao getSrs:result];
            if (srs != nil) {
                [GPKGTestUtils assertNotNil:srs.srsName];
                [GPKGTestUtils assertNotNil:srs.srsId];
                [GPKGTestUtils assertNotNil:srs.organization];
                [GPKGTestUtils assertNotNil:srs.organizationCoordsysId];
                [GPKGTestUtils assertNotNil:srs.definition];
            }
        }
        //[results close];
        
        // Choose random contents
        int random = (int) ([GPKGTestUtils randomDouble] * results.count);
        [results moveToFirst];
        [results moveToPosition:random];
        GPKGContents *contents = (GPKGContents *)[dao getObject:results];
        [results close];
        
        // Query by id
        GPKGContents *queryContents = (GPKGContents *)[dao queryForIdObject:contents.tableName];
        [GPKGTestUtils assertNotNil:queryContents];
        [GPKGTestUtils assertEqualWithValue:contents.tableName andValue2:queryContents.tableName];
        
        // Query for equal
        GPKGResultSet *queryContentsResults = [dao queryForEqWithField:GPKG_CON_COLUMN_IDENTIFIER andValue:contents.identifier];
        
        [GPKGTestUtils assertNotNil:queryContentsResults];
        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:queryContentsResults.count];
        contents = (GPKGContents *)[dao getFirstObject:queryContentsResults];
        [GPKGTestUtils assertEqualWithValue:contents.identifier andValue2:contents.identifier];
        [queryContentsResults close];
        
        // Query for field values
        GPKGColumnValues * fieldValues = [[GPKGColumnValues alloc] init];
        [fieldValues addColumn:GPKG_CON_COLUMN_DATA_TYPE withValue:contents.dataType];
        if(contents.srsId != nil){
            [fieldValues addColumn:GPKG_CON_COLUMN_SRS_ID withValue:contents.srsId];
        }
        queryContentsResults = [dao queryForFieldValues:fieldValues];
        [GPKGTestUtils assertNotNil:queryContentsResults];
        [GPKGTestUtils assertTrue:queryContentsResults.count > 0];
        BOOL found = false;
        while ([queryContentsResults moveToNext]) {
            GPKGContents *queryContentsValue = (GPKGContents *)[dao getObject:queryContentsResults];
            [GPKGTestUtils assertEqualWithValue:contents.dataType andValue2:queryContentsValue.dataType];
            if(contents.srsId != nil){
                [GPKGTestUtils assertEqualWithValue:contents.srsId andValue2:queryContentsValue.srsId];
            }
            if (!found) {
                found = [contents.tableName isEqualToString:queryContentsValue.tableName];
            }
        }
        [GPKGTestUtils assertTrue:found];
        [queryContentsResults close];
        
        // Prepared query, less than equal date
        NSMutableString * where = [[NSMutableString alloc] init];
        [where appendString:[dao buildWhereWithField:GPKG_CON_COLUMN_LAST_CHANGE andValue:contents.lastChange andOperation:@"<="]];
        NSMutableArray * whereArgs = [[NSMutableArray alloc] init];
        [whereArgs addObject:contents.lastChange];
        queryContentsResults = [dao queryWhere:where andWhereArgs:whereArgs];
        
        int queryCount = queryContentsResults.count;
        
        found = false;
        while ([queryContentsResults moveToNext]) {
            GPKGContents *queryContentsValue = (GPKGContents *)[dao getObject:queryContentsResults];
            if([contents.tableName isEqualToString:queryContentsValue.tableName]){
                found = true;
                break;
            }
        }
        [GPKGTestUtils assertTrue:found];
        [queryContentsResults close];
        
        // Prepared query, greater than date
        where = [[NSMutableString alloc] init];
        [where appendString:[dao buildWhereWithField:GPKG_CON_COLUMN_LAST_CHANGE andValue:contents.lastChange andOperation:@">"]];
        whereArgs = [[NSMutableArray alloc] init];
        [whereArgs addObject:contents.lastChange];
        queryContentsResults = [dao queryWhere:where andWhereArgs:whereArgs];
        
        found = false;
        while ([queryContentsResults moveToNext]) {
            GPKGContents *queryContentsValue = (GPKGContents *)[dao getObject:queryContentsResults];
            if([contents.tableName isEqualToString:queryContentsValue.tableName]){
                found = true;
                break;
            }
        }
        [GPKGTestUtils assertFalse:found];
        [queryContentsResults close];
        
        queryCount += queryContentsResults.count;
        [GPKGTestUtils assertEqualIntWithValue:count andValue2:queryCount];
        
    }
}

+(void) testUpdateWithGeoPackage: (GPKGGeoPackage *) geoPackage{

}

+(void) testCreateWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
}

+(void) testDeleteWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
}

+(void) testDeleteCascadeWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
}

@end
