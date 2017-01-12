//
//  TIFFWriter.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFWriter.h"
#import "TIFFCompressionEncoder.h"
#import "TIFFIOUtils.h"
#import "TIFFConstants.h"

@implementation TIFFWriter

+(void) writeTiffWithFile: (NSString *) file andImage: (TIFFImage *) tiffImage{
    TIFFByteWriter * writer = [[TIFFByteWriter alloc] init];
    [self writeTiffWithFile:file andWriter:writer andImage:tiffImage];
    [writer close];
}

+(void) writeTiffWithFile: (NSString *) file andWriter: (TIFFByteWriter *) writer andImage: (TIFFImage *) tiffImage{
    NSData * data = [self writeTiffToDataWithWriter:writer andImage:tiffImage];
    NSInputStream * inputStream = [NSInputStream inputStreamWithData:data];
    [TIFFIOUtils copyInputStream:inputStream toFile:file];
}

+(NSData *) writeTiffToDataWithImage: (TIFFImage *) tiffImage{
    TIFFByteWriter * writer = [[TIFFByteWriter alloc] init];
    NSData * data = [self writeTiffToDataWithWriter:writer andImage:tiffImage];
    [writer close];
    return data;
}

+(NSData *) writeTiffToDataWithWriter: (TIFFByteWriter *) writer andImage: (TIFFImage *) tiffImage{
    [self writeTiffWithWriter:writer andImage:tiffImage];
    NSData * data = [writer getData];
    return data;
}

+(void) writeTiffWithWriter: (TIFFByteWriter *) writer andImage: (TIFFImage *) tiffImage{

    // Write the byte order (bytes 0-1)
    NSString * byteOrder = writer.byteOrder == CFByteOrderBigEndian ? TIFF_BYTE_ORDER_BIG_ENDIAN : TIFF_BYTE_ORDER_LITTLE_ENDIAN;
    [writer writeString:byteOrder];
    
    // Write the TIFF file identifier (bytes 2-3)
    [writer writeUnsignedShort:[NSNumber numberWithUnsignedShort:TIFF_FILE_IDENTIFIER]];
    
    // Write the first IFD offset (bytes 4-7), set to start right away at
    // byte 8
    [writer writeUnsignedInt:[NSNumber numberWithUnsignedInt:(unsigned int)TIFF_HEADER_BYTES]];
    
    // Write the TIFF Image
    [self writeImageFileDirectoriesWithWriter:writer andImage:tiffImage];
}

/**
 * Write the image file directories
 *
 * @param writer
 *            byte writer
 * @param tiffImage
 *            tiff image
 * @throws IOException
 */
+(void) writeImageFileDirectoriesWithWriter: (TIFFByteWriter *) writer andImage: (TIFFImage *) tiffImage{
    // TODO
}

/**
 * Populate the raster entry values with placeholder values for correct size
 * calculations
 *
 * @param fileDirectory
 *            file directory
 */
+(void) populateRasterEntriesWithFileDirectory: (TIFFFileDirectory *) fileDirectory{
    // TODO
}

/**
 * Populate the strip entries with placeholder values
 *
 * @param fileDirectory
 *            file directory
 * @param strips
 *            number of strips
 */
+(void) populateStripEntriesWithFileDirectory: (TIFFFileDirectory *) fileDirectory{
    // TODO
}

/**
 * Write the rasters as bytes
 *
 * @param byteOrder
 *            byte order
 * @param fileDirectory
 *            file directory
 * @param offset
 *            byte offset
 * @return rasters bytes
 */
+(NSData *) writeRastersWithByteOrder: (CFByteOrder) byteOrder andFileDirectory: (TIFFFileDirectory *) fileDirectory andOffset: (int) offset{
    return nil; // TODO
}

/**
 * Write the rasters as bytes
 *
 * @param writer
 *            byte writer
 * @param fileDirectory
 *            file directory
 * @param offset
 *            byte offset
 * @param sampleFieldTypes
 *            sample field types
 * @param encoder
 *            compression encoder
 */
+(void) writeStripRastersWithWriter: (TIFFByteWriter *) writer andFileDirectory: (TIFFFileDirectory *) fileDirectory andOffset: (int) offset andFieldTypes: (NSArray *) sampleFiledTypes andEncoder: (NSObject<TIFFCompressionEncoder> *) encoder{
    // TODO
}

/**
 * Get the compression encoder
 *
 * @param fileDirectory
 *            file directory
 * @return encoder
 */
+(NSObject<TIFFCompressionEncoder> *) encoderWithFileDirectory: (TIFFFileDirectory *) fileDirectory{
    return nil; // TODO
}

/**
 * Write the value according to the field type
 *
 * @param writer
 *            byte writer
 * @param fieldType
 *            field type
 */
+(void) writeValueWithWriter: (TIFFByteWriter *) writer andFieldType: (enum TIFFFieldType) fieldType andValue: (NSNumber *) value{
    // TODO
}

/**
 * Write filler 0 bytes
 *
 * @param writer
 *            byte writer
 * @param count
 *            number of 0 bytes to write
 */
+(void) writerFillerBytesWithWriter: (TIFFByteWriter *) writer andCount: (int) count{
    for (long i = 0; i < count; i++) {
        [writer writeUnsignedByte:0];
    }
}

/**
 * Write file directory entry values
 *
 * @param writer
 *            byte writer
 * @param entry
 *            file directory entry
 * @return bytes written
 */
+(int) writeValuesWithWriter: (TIFFByteWriter *) writer andFileDirectoryEntry: (TIFFFileDirectoryEntry *) entry{
    return 0; // TODO
}

@end
