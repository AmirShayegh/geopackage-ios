//
//  GPKGTileDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileDao.h"
#import "GPKGTileRow.h"
#import "GPKGTileMatrix.h"
#import "GPKGTileMatrixSetDao.h"
#import "GPKGUtils.h"
#import "GPKGTileDaoUtils.h"
#import "SFPProjectionTransform.h"
#import "SFPProjectionFactory.h"
#import "SFPProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"

@implementation GPKGTileDao

-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGTileTable *) table andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andTileMatrices: (NSArray *) tileMatrices{
    self = [super initWithDatabase:database andTable:table];
    if(self != nil){
        self.database = database;
        self.tileMatrixSet = tileMatrixSet;
        self.tileMatrices = tileMatrices;
        
        NSInteger count = [tileMatrices count];
        NSMutableDictionary * tempZoomLevelToTileMatrix = [[NSMutableDictionary alloc] initWithCapacity:count];
        NSMutableArray * tempWidths = [[NSMutableArray alloc] initWithCapacity:count];
        NSMutableArray * tempHeights = [[NSMutableArray alloc] initWithCapacity:count];
        
        GPKGTileMatrixSetDao * dao =  [self tileMatrixSetDao];
        self.projection = [dao projection:tileMatrixSet];
        
        // Set the min and max zoom levels
        if([tileMatrices count] == 0){
            self.minZoom = 0;
            self.maxZoom = 0;
        }else{
            self.minZoom = [((GPKGTileMatrix *)[tileMatrices objectAtIndex:0]).zoomLevel intValue];
            self.maxZoom = [((GPKGTileMatrix *)[tileMatrices objectAtIndex:(count-1)]).zoomLevel intValue];
        }
        
        // Populate the zoom level to tile matrix and the sorted tile widths and
        // heights
        for (int i = ((int)count)-1; i >= 0; i--) {
            GPKGTileMatrix * tileMatrix = (GPKGTileMatrix *) [tileMatrices objectAtIndex:i];
            [GPKGUtils setObject:tileMatrix forKey:tileMatrix.zoomLevel inDictionary:tempZoomLevelToTileMatrix];
            double width = [tileMatrix.pixelXSize doubleValue] * [tileMatrix.tileWidth intValue];
            double height = [tileMatrix.pixelYSize doubleValue] * [tileMatrix.tileHeight intValue];
            [GPKGUtils addObject:[[NSDecimalNumber alloc] initWithDouble:width] toArray:tempWidths];
            [GPKGUtils addObject:[[NSDecimalNumber alloc] initWithDouble:height] toArray:tempHeights];
        }
        
        if([dao contents:tileMatrixSet] == nil){
            [NSException raise:@"No Contents" format:@"Tile Matrix Set %@ has null Contents", tileMatrixSet.tableName];
        }
        
        if([dao srs:tileMatrixSet] == nil){
            [NSException raise:@"No SRS" format:@"Tile Matrix Set %@ has null Spatial Reference System", tileMatrixSet.tableName];
        }
        
        self.zoomLevelToTileMatrix = tempZoomLevelToTileMatrix;
        self.widths = tempWidths;
        self.heights = tempHeights;
    }
    return self;
}

-(NSObject *) createObject{
    return [self newRow];
}

-(GPKGBoundingBox *) boundingBoxWithZoomLevel: (int) zoomLevel{
    GPKGBoundingBox * boundingBox = nil;
    GPKGTileMatrix * tileMatrix = [self tileMatrixWithZoomLevel:zoomLevel];
    if(tileMatrix != nil){
        GPKGTileGrid * tileGrid = [self queryForTileGridWithZoomLevel:zoomLevel];
        if(tileGrid != nil){
            GPKGBoundingBox * matrixSetBoundingBox = [self boundingBox];
            boundingBox = [GPKGTileBoundingBoxUtils boundingBoxWithTotalBoundingBox:matrixSetBoundingBox andTileMatrix:tileMatrix andTileGrid:tileGrid];
        }
    }
    return boundingBox;
}

-(GPKGTileGrid *) tileGridWithZoomLevel: (int) zoomLevel{
    GPKGTileGrid * tileGrid = nil;
    GPKGTileMatrix * tileMatrix = [self tileMatrixWithZoomLevel:zoomLevel];
    if(tileMatrix != nil){
        tileGrid = [[GPKGTileGrid alloc] initWithMinX:0 andMinY:0 andMaxX:[tileMatrix.matrixWidth intValue] - 1 andMaxY:[tileMatrix.matrixHeight intValue] - 1];
    }
    return tileGrid;
}

-(GPKGTileTable *) tileTable{
    return (GPKGTileTable *) self.table;
}

-(GPKGTileRow *) tileRow: (GPKGResultSet *) results{
    return (GPKGTileRow *) [super row:results];
}

-(GPKGUserRow *) newRowWithColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values{
    return [[GPKGTileRow alloc] initWithTileTable:[self tileTable] andColumns:(GPKGTileColumns *) columns andValues:values];
}

-(GPKGTileRow *) newRow{
    return [[GPKGTileRow alloc] initWithTileTable:(GPKGTileTable *)self.table];
}

-(void) adjustTileMatrixLengths{
    [GPKGTileDaoUtils adjustTileMatrixLengthsWithTileMatrixSet:self.tileMatrixSet andTileMatrices:self.tileMatrices];
}

-(GPKGTileMatrix *) tileMatrixWithZoomLevel: (int) zoomLevel{
    return (GPKGTileMatrix *)[GPKGUtils objectForKey:[NSNumber numberWithInt:zoomLevel] inDictionary:self.zoomLevelToTileMatrix];
}

-(GPKGTileRow *) queryForTileWithColumn: (int) column andRow: (int) row andZoomLevel: (int) zoomLevel{
    
    GPKGColumnValues * fieldValues = [[GPKGColumnValues alloc] init];
    [fieldValues addColumn:GPKG_TC_COLUMN_TILE_COLUMN withValue:[NSNumber numberWithInt:column]];
    [fieldValues addColumn:GPKG_TC_COLUMN_TILE_ROW withValue:[NSNumber numberWithInt:row]];
    [fieldValues addColumn:GPKG_TC_COLUMN_ZOOM_LEVEL withValue:[NSNumber numberWithInt:zoomLevel]];
    
    GPKGResultSet * results = [self queryForFieldValues:fieldValues];
    GPKGTileRow * tileRow = nil;
    @try{
        if([results moveToNext]){
            tileRow = [self tileRow:results];
        }
    }@finally{
        [results close];
    }
    
    return tileRow;
}

-(GPKGResultSet *) queryforTileWithZoomLevel: (int) zoomLevel{
    return [self queryForEqWithField:GPKG_TC_COLUMN_ZOOM_LEVEL andValue:[NSNumber numberWithInt:zoomLevel]];
}

-(GPKGResultSet *) queryForTileDescending: (int) zoomLevel{
    return [self queryForEqWithField:GPKG_TC_COLUMN_ZOOM_LEVEL andValue:[NSNumber numberWithInt:zoomLevel] andGroupBy:nil andHaving:nil andOrderBy:[NSString stringWithFormat:@"%@ DESC, %@ DESC", GPKG_TC_COLUMN_TILE_COLUMN, GPKG_TC_COLUMN_TILE_ROW]];
}

-(GPKGResultSet *) queryForTilesInColumn: (int) column andZoomLevel: (int) zoomLevel{
    
    GPKGColumnValues * fieldValues = [[GPKGColumnValues alloc] init];
    [fieldValues addColumn:GPKG_TC_COLUMN_TILE_COLUMN withValue:[NSNumber numberWithInt:column]];
    [fieldValues addColumn:GPKG_TC_COLUMN_ZOOM_LEVEL withValue:[NSNumber numberWithInt:zoomLevel]];
    
    return [self queryForFieldValues:fieldValues];
}

-(GPKGResultSet *) queryForTilesInRow: (int) row andZoomLevel: (int) zoomLevel{
    GPKGColumnValues * fieldValues = [[GPKGColumnValues alloc] init];
    [fieldValues addColumn:GPKG_TC_COLUMN_TILE_ROW withValue:[NSNumber numberWithInt:row]];
    [fieldValues addColumn:GPKG_TC_COLUMN_ZOOM_LEVEL withValue:[NSNumber numberWithInt:zoomLevel]];
    
    return [self queryForFieldValues:fieldValues];
}

-(NSNumber *) zoomLevelWithLength: (double) length{
    return [GPKGTileDaoUtils zoomLevelWithWidths:self.widths andHeights:self.heights andTileMatrices:self.tileMatrices andLength:length];
}

-(NSNumber *) zoomLevelWithWidth: (double) width andHeight: (double) height{
    return [GPKGTileDaoUtils zoomLevelWithWidths:self.widths andHeights:self.heights andTileMatrices:self.tileMatrices andWidth:width andHeight:height];
}

-(NSNumber *) closestZoomLevelWithLength: (double) length{
    return [GPKGTileDaoUtils closestZoomLevelWithWidths:self.widths andHeights:self.heights andTileMatrices:self.tileMatrices andLength:length];
}

-(NSNumber *) closestZoomLevelWithWidth: (double) width andHeight: (double) height{
    return [GPKGTileDaoUtils closestZoomLevelWithWidths:self.widths andHeights:self.heights andTileMatrices:self.tileMatrices andWidth:width andHeight:height];
}

-(NSNumber *) approximateZoomLevelWithLength: (double) length{
    return [GPKGTileDaoUtils approximateZoomLevelWithWidths:self.widths andHeights:self.heights andTileMatrices:self.tileMatrices andLength:length];
}

-(NSNumber *) approximateZoomLevelWithWidth: (double) width andHeight: (double) height{
    return [GPKGTileDaoUtils approximateZoomLevelWithWidths:self.widths andHeights:self.heights andTileMatrices:self.tileMatrices andWidth:width andHeight:height];
}

-(GPKGResultSet *) queryByTileGrid: (GPKGTileGrid *) tileGrid andZoomLevel: (int) zoomLevel{
    return [self queryByTileGrid:tileGrid andZoomLevel:zoomLevel andOrderBy:nil];
}

-(GPKGResultSet *) queryByTileGrid: (GPKGTileGrid *) tileGrid andZoomLevel: (int) zoomLevel andOrderBy: (NSString *) orderBy{
    GPKGResultSet * results = nil;
    
    if(tileGrid != nil){
        
        NSMutableString * where = [[NSMutableString alloc] init];
        
        NSNumber * zoom = [NSNumber numberWithInt:zoomLevel];
        NSNumber * minX = [NSNumber numberWithInt:tileGrid.minX];
        NSNumber * maxX = [NSNumber numberWithInt:tileGrid.maxX];
        NSNumber * minY = [NSNumber numberWithInt:tileGrid.minY];
        NSNumber * maxY = [NSNumber numberWithInt:tileGrid.maxY];
        
        [where appendString:[self buildWhereWithField:GPKG_TC_COLUMN_ZOOM_LEVEL andValue:zoom]];
        
        [where appendString:@" and "];
        [where appendString:[self buildWhereWithField:GPKG_TC_COLUMN_TILE_COLUMN andValue:minX andOperation:@">="]];
        
        [where appendString:@" and "];
        [where appendString:[self buildWhereWithField:GPKG_TC_COLUMN_TILE_COLUMN andValue:maxX andOperation:@"<="]];
        
        [where appendString:@" and "];
        [where appendString:[self buildWhereWithField:GPKG_TC_COLUMN_TILE_ROW andValue:minY andOperation:@">="]];
        
        [where appendString:@" and "];
        [where appendString:[self buildWhereWithField:GPKG_TC_COLUMN_TILE_ROW andValue:maxY andOperation:@"<="]];
        
        NSArray * whereArgs = [self buildWhereArgsWithValueArray:[[NSArray alloc] initWithObjects:zoom,
                               minX,
                               maxX,
                               minY,
                               maxY, nil]];
        
        results = [self queryWhere:where andWhereArgs:whereArgs andGroupBy:nil andHaving:nil andOrderBy:orderBy];
    }
    return results;
}

-(GPKGTileGrid *) queryForTileGridWithZoomLevel: (int) zoomLevel{
    
    NSNumber * zoomLevelNumber = [NSNumber numberWithInt:zoomLevel];
    NSString * where = [self buildWhereWithField:GPKG_TC_COLUMN_ZOOM_LEVEL andValue:zoomLevelNumber];
    NSArray * whereArgs = [self buildWhereArgsWithValue:zoomLevelNumber];
    
    NSNumber * minX = [self minOfColumn:GPKG_TC_COLUMN_TILE_COLUMN andWhere:where andWhereArgs:whereArgs];
    NSNumber * maxX = [self maxOfColumn:GPKG_TC_COLUMN_TILE_COLUMN andWhere:where andWhereArgs:whereArgs];
    NSNumber * minY = [self minOfColumn:GPKG_TC_COLUMN_TILE_ROW andWhere:where andWhereArgs:whereArgs];
    NSNumber * maxY = [self maxOfColumn:GPKG_TC_COLUMN_TILE_ROW andWhere:where andWhereArgs:whereArgs];
    
    GPKGTileGrid * tileGrid = nil;
    if(minX != nil && maxX != nil && minY != nil && maxY != nil){
        tileGrid = [[GPKGTileGrid alloc] initWithMinX:[minX intValue] andMinY:[minY intValue] andMaxX:[maxX intValue] andMaxY:[maxY intValue]];
    }
    
    return tileGrid;
}

-(int) deleteTileWithColumn: (int) column andRow: (int) row andZoomLevel: (int) zoomLevel{
    
    NSMutableString * where = [[NSMutableString alloc] init];
    
    NSNumber * zoom = [NSNumber numberWithInt:zoomLevel];
    NSNumber * columnNumber = [NSNumber numberWithInt:column];
    NSNumber * rowNumber = [NSNumber numberWithInt:row];
    
    [where appendString:[self buildWhereWithField:GPKG_TC_COLUMN_ZOOM_LEVEL andValue:zoom]];
    
    [where appendString:@" and "];
    [where appendString:[self buildWhereWithField:GPKG_TC_COLUMN_TILE_COLUMN andValue:columnNumber]];
    
    [where appendString:@" and "];
    [where appendString:[self buildWhereWithField:GPKG_TC_COLUMN_TILE_ROW andValue:rowNumber]];
    
    NSArray * whereArgs = [self buildWhereArgsWithValueArray:[[NSArray alloc] initWithObjects:zoom,
                           columnNumber,
                           rowNumber, nil]];
    int deleted = [self deleteWhere:where andWhereArgs:whereArgs];
    
    return deleted;
}

-(int) countWithZoomLevel: (int) zoomLevel{
    NSNumber * zoom = [NSNumber numberWithInt:zoomLevel];
    NSString * where = [self buildWhereWithField:GPKG_TC_COLUMN_ZOOM_LEVEL andValue:zoom];
    NSArray * whereArgs = [self buildWhereArgsWithValue:zoom];
    return [self countWhere:where andWhereArgs:whereArgs];
}

-(double) maxLength{
    return [GPKGTileDaoUtils maxLengthWithWidths:self.widths andHeights:self.heights];
}

-(double) minLength{
    return [GPKGTileDaoUtils minLengthWithWidths:self.widths andHeights:self.heights];
}

-(BOOL) isXYZTiles{
    
    // Convert the bounding box to wgs84
    GPKGBoundingBox * boundingBox = [self.tileMatrixSet boundingBox];
    SFPProjectionTransform * transform = [[SFPProjectionTransform alloc] initWithFromProjection:self.projection andToEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    GPKGBoundingBox * wgs84BoundingBox = [boundingBox transform:transform];

    BOOL isFormat = false;
    
    // Verify the bounds are the entire world
    if([wgs84BoundingBox.minLatitude doubleValue] <= PROJ_WEB_MERCATOR_MIN_LAT_RANGE
       && [wgs84BoundingBox.maxLatitude doubleValue] <= PROJ_WEB_MERCATOR_MAX_LAT_RANGE
       && [wgs84BoundingBox.minLongitude doubleValue] <= -PROJ_WGS84_HALF_WORLD_LON_WIDTH
       && [wgs84BoundingBox.maxLongitude doubleValue] >= PROJ_WGS84_HALF_WORLD_LON_WIDTH){
        
        isFormat = true;
        
        for(GPKGTileMatrix * tileMatrix in self.tileMatrices){
            int zoomLevel = [tileMatrix.zoomLevel intValue];
            int tilesPerSide = [GPKGTileBoundingBoxUtils tilesPerSideWithZoom:zoomLevel];
            if([tileMatrix.matrixWidth intValue] != tilesPerSide
               || [tileMatrix.matrixHeight intValue] != tilesPerSide){
                isFormat = false;
                break;
            }
        }
    }
    
    return isFormat;
}

-(GPKGTileMatrixSetDao *) tileMatrixSetDao{
    return [[GPKGTileMatrixSetDao alloc] initWithDatabase:self.database];
}

-(GPKGBoundingBox *) boundingBox{
    return [self.tileMatrixSet boundingBox];
}

-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection{
    return [[self tileMatrixSetDao] boundingBoxOfTileMatrixSet:self.tileMatrixSet inProjection:projection];
}

@end
