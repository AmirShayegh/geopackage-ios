//
//  GPKGGeoPackageExtensions.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGeoPackageExtensions.h"
#import "GPKGNGAExtensions.h"
#import "GPKGRTreeIndexExtension.h"
#import "GPKGRelatedTablesExtension.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGCoverageData.h"
#import "GPKGSchemaExtension.h"
#import "GPKGMetadataExtension.h"
#import "GPKGCrsWktExtension.h"

@implementation GPKGGeoPackageExtensions

+(void) deleteTableExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{
    
    // Handle deleting any extensions with extra tables here
    [GPKGNGAExtensions deleteTableExtensionsWithGeoPackage:geoPackage andTable:table];
    
    [self deleteRTreeSpatialIndexWithGeoPackage:geoPackage andTable:table];
    [self deleteRelatedTablesWithGeoPackage:geoPackage andTable:table];
    [self deleteGriddedCoverageWithGeoPackage:geoPackage andTable:table];
    [self deleteSchemaWithGeoPackage:geoPackage andTable:table];
    [self deleteMetadataWithGeoPackage:geoPackage andTable:table];
    
    [self deleteWithGeoPackage:geoPackage andTable:table];
}

+(void) deleteExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    // Handle deleting any extensions with extra tables here
    [GPKGNGAExtensions deleteExtensionsWithGeoPackage:geoPackage];
    
    [self deleteRTreeSpatialIndexExtensionWithGeoPackage:geoPackage];
    [self deleteRelatedTablesExtensionWithGeoPackage:geoPackage];
    [self deleteGriddedCoverageExtensionWithGeoPackage:geoPackage];
    [self deleteSchemaExtensionWithGeoPackage:geoPackage];
    [self deleteMetadataExtensionWithGeoPackage:geoPackage];
    [self deleteCrsWktExtensionWithGeoPackage:geoPackage];
    
    [self deleteWithGeoPackage:geoPackage];
}

/**
 *  Delete the extensions for the table
 *
 *  @param geoPackage GeoPackage
 *  @param table      table
 */
+(void) deleteWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{
    
    GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
    
    if([extensionsDao tableExists]){
        [extensionsDao deleteByTableName:table];
    }
    
}

/**
 *  Delete the extensions
 *
 *  @param geoPackage GeoPackage
 */
+(void) deleteWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
    
    if([extensionsDao tableExists]){
        [geoPackage dropTable:extensionsDao.tableName];
    }
}

+(void) copyTableExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{
    
    @try {
        
        [self copyRTreeSpatialIndexWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        [self copyRelatedTablesWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        [self copyGriddedCoverageWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        [self copySchemaWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        [self copyMetadataWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        
        // Handle copying any extensions with extra tables here
        [GPKGNGAExtensions copyTableExtensionsWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to copy extensions for table: %@, copied from table: %@. error: %@", newTable, table, exception);
    }
    
}

+(void) deleteRTreeSpatialIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{

    GPKGRTreeIndexExtension *rTreeIndexExtension = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:geoPackage];
    if([rTreeIndexExtension hasWithTableName:table]){
        [rTreeIndexExtension deleteWithTableName:table];
    }

}

+(void) deleteRTreeSpatialIndexExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGRTreeIndexExtension *rTreeIndexExtension = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:geoPackage];
    if([rTreeIndexExtension has]){
        [rTreeIndexExtension deleteAll];
    }
    
}

+(void) copyRTreeSpatialIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{
    // TODO
}

+(void) deleteRelatedTablesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{

    GPKGRelatedTablesExtension *relatedTablesExtension = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    if ([relatedTablesExtension has]) {
        [relatedTablesExtension removeRelationshipsWithTable:table];
    }
    
}

+(void) deleteRelatedTablesExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGRelatedTablesExtension *relatedTablesExtension = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    if ([relatedTablesExtension has]) {
        [relatedTablesExtension removeExtension];
    }
    
}

+(void) copyRelatedTablesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{
    // TODO
}

+(void) deleteGriddedCoverageWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{

    if([geoPackage isTable:table ofType:GPKG_CDT_GRIDDED_COVERAGE]){
        
        GPKGGriddedTileDao *griddedTileDao = [geoPackage getGriddedTileDao];
        GPKGGriddedCoverageDao *griddedCoverageDao = [geoPackage getGriddedCoverageDao];
        GPKGExtensionsDao *extensionsDao = [geoPackage getExtensionsDao];
        
        if ([griddedTileDao tableExists]) {
            [griddedTileDao deleteByTableName:table];
        }
        if ([griddedCoverageDao tableExists]) {
            [griddedCoverageDao deleteByTableName:table];
        }
        if ([extensionsDao tableExists]) {
            [extensionsDao deleteByExtension:[GPKGExtensions buildDefaultAuthorExtensionName:GPKG_GRIDDED_COVERAGE_EXTENSION_NAME] andTable:table];
        }
        
    }
    
}

+(void) deleteGriddedCoverageExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    NSArray *coverageTables = [geoPackage getTablesByType:GPKG_CDT_GRIDDED_COVERAGE];
    for(NSString *table in coverageTables){
        [geoPackage deleteTable:table];
    }
    
    GPKGGriddedTileDao *griddedTileDao = [geoPackage getGriddedTileDao];
    GPKGGriddedCoverageDao *griddedCoverageDao = [geoPackage getGriddedCoverageDao];
    GPKGExtensionsDao *extensionsDao = [geoPackage getExtensionsDao];
    
    if ([griddedTileDao tableExists]) {
        [geoPackage dropTable:griddedTileDao.tableName];
    }
    if ([griddedCoverageDao tableExists]) {
        [geoPackage dropTable:griddedCoverageDao.tableName];
    }
    if ([extensionsDao tableExists]) {
        [extensionsDao deleteByExtension:[GPKGExtensions buildDefaultAuthorExtensionName:GPKG_GRIDDED_COVERAGE_EXTENSION_NAME]];
    }
    
}

+(void) copyGriddedCoverageWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{
    // TODO
}

+(void) deleteSchemaWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{

    GPKGDataColumnsDao *dataColumnsDao = [geoPackage getDataColumnsDao];
    if([dataColumnsDao tableExists]){
        [dataColumnsDao deleteByTableName:table];
    }

}

+(void) deleteSchemaExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGSchemaExtension *schemaExtension = [[GPKGSchemaExtension alloc] initWithGeoPackage:geoPackage];
    if ([schemaExtension has]) {
        [schemaExtension removeExtension];
    }
    
}

+(void) copySchemaWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{
    // TODO
}

+(void) deleteMetadataWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{

    GPKGMetadataReferenceDao *metadataReferenceDao = [geoPackage getMetadataReferenceDao];
    if([metadataReferenceDao tableExists]){
        [metadataReferenceDao deleteByTableName:table];
    }
    
}

+(void) deleteMetadataExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGMetadataExtension *metadataExtension = [[GPKGMetadataExtension alloc] initWithGeoPackage:geoPackage];
    if ([metadataExtension has]) {
        [metadataExtension removeExtension];
    }
    
}

+(void) copyMetadataWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{
    // TODO
}

+(void) deleteCrsWktExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGCrsWktExtension *crsWktExtension = [[GPKGCrsWktExtension alloc] initWithGeoPackage:geoPackage];
    if ([crsWktExtension has]) {
        [crsWktExtension removeExtension];
    }
    
}

@end
