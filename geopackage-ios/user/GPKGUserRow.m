//
//  GPKGUserRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserRow.h"
#import <sqlite3.h>
#import "GPKGUtils.h"
#import "GPKGDateTimeUtils.h"

@implementation GPKGUserRow

-(instancetype) initWithTable: (GPKGUserTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    self = [super init];
    if(self != nil){
        self.table = table;
        self.columnTypes = columnTypes;
        self.values = values;
    }
    return self;
}

-(instancetype) initWithTable: (GPKGUserTable *) table{
    self = [super init];
    if(self != nil){
        self.table = table;
        
        int columnCount = [self.table columnCount];
        NSMutableArray * tempColumnTypes = [[NSMutableArray alloc] initWithCapacity:columnCount];
        NSMutableArray * tempValues = [[NSMutableArray alloc] initWithCapacity:columnCount];
        for(int i = 0; i < columnCount; i++){
            [GPKGUtils addObject:[NSNumber numberWithInt:SQLITE_NULL] toArray:tempColumnTypes];
            [GPKGUtils addObject:nil toArray:tempValues];
        }
        
        self.columnTypes = tempColumnTypes;
        self.values = tempValues;
    }
    return self;
}

-(instancetype) initWithRow: (GPKGUserRow *) row{
    self = [super init];
    if(self != nil){
        self.table = row.table;
        self.columnTypes = row.columnTypes;
        self.values = [[NSMutableArray alloc] init];
        for(int i = 0; i < row.values.count; i++){
            NSObject *value = [GPKGUtils objectAtIndex:i inArray:row.values];
            if(value != nil){
                GPKGUserColumn *column = [row columnWithIndex:i];
                value = [self copyValue:value forColumn:column];
            }
            [GPKGUtils addObject:value toArray:self.values];
        }
    }
    return self;
}

-(NSObject *) toObjectValueWithIndex: (int) index andValue: (NSObject *) value{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSObject *) toDatabaseValueWithIndex: (int) index andValue: (NSObject *) value{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(int) columnCount{
    return [self.table columnCount];
}

-(NSArray *) columnNames{
    return self.table.columnNames;
}

-(NSString *) columnNameWithIndex: (int) index{
    return [self.table columnNameWithIndex:index];
}

-(int) columnIndexWithColumnName: (NSString *) columnName{
    return [self.table columnIndexWithColumnName:columnName];
}

-(NSObject *) valueWithIndex: (int) index{
    NSObject * value = [GPKGUtils objectAtIndex:index inArray:self.values];
    if(value != nil){
        GPKGUserColumn * column = [self columnWithIndex:index];
        if([value isKindOfClass:[NSString class]] && (column.dataType == GPKG_DT_DATE || column.dataType == GPKG_DT_DATETIME)){
            value = [GPKGDateTimeUtils convertToDateWithString:((NSString *) value)];
        }else{
            value = [self toObjectValueWithIndex:index andValue:value];
        }
    }
    return value;
}

-(NSObject *) valueWithColumnName: (NSString *) columnName{
    return [self valueWithIndex:[self.table columnIndexWithColumnName:columnName]];
}

-(NSString *) valueStringWithIndex: (int) index{
    NSString *stringValue = nil;
    NSObject *value = [self valueWithIndex:index];
    if(value != nil){
        stringValue = (NSString *) value;
    }
    return stringValue;
}

-(NSString *) valueStringWithColumnName: (NSString *) columnName{
    return [self valueStringWithIndex:[self.table columnIndexWithColumnName:columnName]];
}

-(NSObject *) databaseValueWithIndex: (int) index{
    NSObject * value = [GPKGUtils objectAtIndex:index inArray:self.values];
    if(value != nil){
        value =[self toDatabaseValueWithIndex:index andValue:value];
    }
    return value;
}

-(NSObject *) databaseValueWithColumnName: (NSString *) columnName{
    return [self databaseValueWithIndex:[self.table columnIndexWithColumnName:columnName]];
}

-(int) rowColumnTypeWithIndex: (int) index{
    return [((NSNumber *)[GPKGUtils objectAtIndex:index inArray:self.columnTypes]) intValue];
}

-(int) rowColumnTypeWithColumnName: (NSString *) columnName{
    return [((NSNumber *)[GPKGUtils objectAtIndex:[self.table columnIndexWithColumnName:columnName] inArray:self.columnTypes]) intValue];
}

-(GPKGUserColumn *) columnWithIndex: (int) index{
    return [self.table columnWithIndex:index];
}

-(GPKGUserColumn *) columnWithColumnName: (NSString *) columnName{
    return [self.table columnWithColumnName:columnName];
}

-(BOOL) hasColumnWithColumnName: (NSString *) columnName{
    return [self.table hasColumnWithColumnName:columnName];
}

-(NSNumber *) id{
    
    NSNumber * id = nil;
    NSObject * objectValue = [self valueWithIndex:[self pkIndex]];
    if(objectValue == nil){
        [NSException raise:@"Null Id" format:@"Row Id was null. Table: %@, Column Index: %d, Column Name: %@", self.table.tableName, [self pkIndex], [self pkColumn].name];
    }
    if([objectValue isKindOfClass:[NSNumber class]]){
        id = (NSNumber *) objectValue;
    }else{
        [NSException raise:@"Non Number Id" format:@"Row Id was not a number. Table: %@, Column Index: %d, Column Name: %@", self.table.tableName, [self pkIndex], [self pkColumn].name];
    }
    return id;
}

-(int) idValue{
    return [[self id] intValue];
}

-(BOOL) hasIdColumn{
    return [self.table hasIdColumn];
}

-(BOOL) hasId{
    BOOL hasId = NO;
    if([self hasIdColumn]){
        NSObject * objectValue = [self valueWithIndex:[self idIndex]];
        hasId = objectValue != nil && [objectValue isKindOfClass:[NSNumber class]];
    }
    return hasId;
}

-(int) idIndex{
    return [self.table idIndex];
}

-(GPKGUserColumn *) idColumn{
    return [self.table idColumn];
}

-(NSString *) idColumnName{
    return [self.table idColumnName];
}

-(NSObject *) pk{
    return [self valueWithIndex:[self pkIndex]];
}

-(BOOL) hasPkColumn{
    return [self.table hasPkColumn];
}

-(BOOL) hasPk{
    BOOL hasPk = NO;
    if([self hasPkColumn]){
        NSObject * objectValue = [self valueWithIndex:[self pkIndex]];
        hasPk = objectValue != nil;
    }
    return hasPk;
}

-(int) pkIndex{
    return [self.table pkIndex];
}

-(GPKGUserColumn *) pkColumn{
    return [self.table pkColumn];
}

-(NSString *) pkColumnName{
    return [self.table pkColumnName];
}

-(void) setValueWithIndex: (int) index andValue: (NSObject *) value{
    if(index == self.table.pkIndex){
        [NSException raise:@"Primary Key Update" format:@"Can not update the primary key of the row. Table Name: %@, Index: %d, Name: %@", self.table.tableName, index, [self.table pkColumn].name];
    }
    [self setValueNoValidationWithIndex:index andValue:value];
}

-(void) setValueNoValidationWithIndex: (int) index andValue: (NSObject *) value{
    
    if(value != nil){
        if([value isKindOfClass:[NSDate class]]){
            GPKGUserColumn *userColumn = [self columnWithIndex:index];
            value = [GPKGDateTimeUtils convertToStringWithDate:(NSDate *)value andType:userColumn.dataType];
        }
    }
    
    [GPKGUtils replaceObjectAtIndex:index withObject:value inArray:self.values];
}

-(void) setValueWithColumnName: (NSString *) columnName andValue: (NSObject *) value{
    [self setValueWithIndex:[self columnIndexWithColumnName:columnName] andValue:value];
}

-(void) setId: (NSNumber *) id{
    if([self hasIdColumn]){
        [GPKGUtils replaceObjectAtIndex:[self pkIndex] withObject:id inArray:self.values];
    }
}

-(void) resetId{
    [GPKGUtils replaceObjectAtIndex:[self pkIndex] withObject:nil inArray:self.values];
}

-(void) validateValueWithColumn: (GPKGUserColumn *) column andValue: (NSObject *) value andValueTypes: (NSArray *) valueTypes{
    
    enum GPKGDataType dataType = column.dataType;
    Class dataTypeClass = [GPKGDataTypes classType:dataType];
    
    BOOL valid = false;
    for(Class valueType in valueTypes){
        if(valueType == dataTypeClass){
            valid = true;
            break;
        }
    }
    
    if(!valid){
        [NSException raise:@"Illegal Value" format:@"Column: %@, Value: %@, Expected Type: %@, Actual Type: %@", column.name, value, [dataTypeClass description], [[[GPKGUtils objectAtIndex:0 inArray:valueTypes] class] description]];
    }
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGUserRow *userRow = [[[self class] allocWithZone:zone] init];
    userRow.table = _table;
    userRow.columnTypes = _columnTypes;
    userRow.values = [[NSMutableArray alloc] initWithCapacity:_values.count];
    for(int i = 0; i < _values.count; i++){
        NSObject *value = [_values objectAtIndex:i];
        if(![value isEqual:[NSNull null]]){
            GPKGUserColumn *column = [self columnWithIndex:i];
            value = [self copyValue:value forColumn:column];
        }
        [userRow.values addObject:value];
    }
    return userRow;
}

-(NSObject *) copyValue: (NSObject *) value forColumn: (GPKGUserColumn *) column{
    
    NSObject *copyValue = value;
        
    switch(column.dataType){
            
        case GPKG_DT_TEXT:
        case GPKG_DT_DATE:
        case GPKG_DT_DATETIME:
            
            if([value isKindOfClass:[NSMutableString class]]){
                NSMutableString *mutableString = (NSMutableString *) value;
                copyValue = [mutableString mutableCopy];
            }
            
            break;
            
        case GPKG_DT_BLOB:
            
            if([value isKindOfClass:[NSMutableData class]]){
                NSMutableData *mutableData = (NSMutableData *) value;
                copyValue = [mutableData mutableCopy];
            }
            
            break;
        default:
            break;
    }
    
    return copyValue;
}

@end
