//
//  GPKGUserTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTable.h"
#import "GPKGUtils.h"

@implementation GPKGUserTable

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    self = [super init];
    if(self != nil){
    
        self.tableName = tableName;
    
        // Sort the columns by index
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:true];
        columns = [columns sortedArrayUsingDescriptors:@[sort]];
        
        // Verify the columns have ordered indices without gaps
        for(int i = 0; i < [columns count]; i++){
            GPKGUserColumn * column = [GPKGUtils objectAtIndex:i inArray:columns];
            if(column == nil){
                [NSException raise:@"Missing Column" format:@"No column found at index: %d, Table Name: %@", i, tableName];
            } else if(column.index != i){
                [NSException raise:@"Invalid Column" format:@"Column has wrong index of %d, found at index: %d, Table Name: %@", column.index, i, tableName];
            }
        }
        
        NSNumber * pk = nil;
    
        // Build the column name array for queries, find the primary key and geometry
        NSMutableArray * tempColumnNames = [NSMutableArray arrayWithCapacity:[columns count]];
        NSMutableDictionary * tempNameToIndex = [NSMutableDictionary dictionaryWithCapacity:[columns count]];
        for(GPKGUserColumn * column in columns){
        
            int index = column.index;
            NSNumber * indexNumber = [NSNumber numberWithInt:index];
        
            if(column.primaryKey){
                if(pk != nil){
                    [NSException raise:@"Multiple Primary Keys" format:@"More than one primary key column was found for table '%@'. Index %@ and %d", tableName, pk, index];
                }
                pk = indexNumber;
            }
            
            [GPKGUtils addObject:column.name toArray:tempColumnNames];
            [GPKGUtils setObject:indexNumber forKey:column.name inDictionary:tempNameToIndex];
        }
        self.columns = columns;
        self.columnNames = tempColumnNames;
        self.nameToIndex = tempNameToIndex;
        
        if(pk != nil){
            self.pkIndex = [pk intValue];
        }else{
            self.pkIndex = -1;
        }

    }
    return self;
}

-(instancetype) initWithUserTable: (GPKGUserTable *) userTable{
    self = [super init];
    if(self != nil){
        self.tableName = userTable.tableName;
        self.columnNames = userTable.columnNames;
        self.columns = userTable.columns;
        self.nameToIndex = userTable.nameToIndex;
        self.pkIndex = userTable.pkIndex;
        self.uniqueConstraints = userTable.uniqueConstraints;
    }
    return self;
}

-(void) duplicateCheckWithIndex: (int) index andPreviousIndex: (NSNumber *) previousIndex andColumn: (NSString *) column{
    if(previousIndex != nil){
        [NSException raise:@"Duplicate Column" format:@"More than one %@ column was found for table '%@'. Index %@ and %d", column, self.tableName, previousIndex, index];
    }
}

-(void) typeCheckWithExpected: (enum GPKGDataType) expected andColumn: (GPKGUserColumn *) column{
    enum GPKGDataType actual = column.dataType;
    if(actual != expected){
        [NSException raise:@"Unexpected Data Type" format:@"Unexpected %@ column data type was found for table '%@', expected: %@, actual: %@", column.name, self.tableName, [GPKGDataTypes name:expected], [column getTypeName]];
    }
}

-(void) missingCheckWithIndex: (NSNumber *) index andColumn: (NSString *) column{
    if(index == nil){
        [NSException raise:@"Missing Column" format:@"No %@ column was found for table '%@'", column, self.tableName];
    }
}

-(int) getColumnIndexWithColumnName: (NSString *) columnName{
    NSNumber * index = [GPKGUtils objectForKey:columnName inDictionary:self.nameToIndex];
    if(index == nil){
        [NSException raise:@"No Column" format:@"Column does not exists in table '%@', column: %@", self.tableName, columnName];
    }
    return [index intValue];
}

-(NSString *) getColumnNameWithIndex: (int) index{
    return [GPKGUtils objectAtIndex:index inArray:self.columnNames];
}

-(GPKGUserColumn *) getColumnWithIndex: (int) index{
    return [GPKGUtils objectAtIndex:index inArray:self.columns];
}

-(GPKGUserColumn *) getColumnWithColumnName: (NSString *) columnName{
    return [self getColumnWithIndex:[self getColumnIndexWithColumnName:columnName]];
}

-(BOOL) hasColumnWithColumnName: (NSString *) columnName{
    return [self.nameToIndex objectForKey:columnName] != nil;
}

-(int) columnCount{
    return (int)[self.columns count];
}

-(BOOL) hasPkColumn{
    return self.pkIndex >= 0;
}

-(GPKGUserColumn *) getPkColumn{
    GPKGUserColumn * column = nil;
    if([self hasPkColumn]){
        column = [GPKGUtils objectAtIndex:self.pkIndex inArray:self.columns];
    }
    return column;
}

-(void) addUniqueConstraint: (GPKGUserUniqueConstraint *) uniqueConstraint{
    if(self.uniqueConstraints == nil){
        self.uniqueConstraints = [[NSMutableArray alloc] init];
    }
    [GPKGUtils addObject:uniqueConstraint toArray:self.uniqueConstraints];
}

-(NSArray *) columnsOfType: (enum GPKGDataType) type{
    NSMutableArray * columnsOfType = [[NSMutableArray alloc] init];
    for(GPKGUserColumn *column in self.columns){
        if(column.dataType == type){
            [columnsOfType addObject:column];
        }
    }
    return columnsOfType;
}

@end
