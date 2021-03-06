//
//  ImageReader.mm
//  VidChaserSample
//
//  Created by 이상훈 on 2017. 3. 14..
//  Copyright © 2017년 Ray. All rights reserved.
//

#import "ImageReader.h"
#import "Utils.h"

@interface ImageReader()
{
    NSString *fileFolderPath;
    NSArray *fileList;
    int currentIndex;
    int nextIndex;
    bool isRewind;
}
@end

@implementation ImageReader

- (id) init
{
    self = [super init];
    if(self)
    {
        currentIndex = 0;
        nextIndex = 0;
        isRewind = false;
    }
    return self;
}

- (void) setPath:(NSString *)path
{
    fileFolderPath = path;
    fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
}

- (bool) hasNext
{
    if(isRewind)
    {
        return (nextIndex >= 0);
    }
    else
    {
        return (nextIndex < fileList.count);
    }
}

- (unsigned char *) readFrame:(bool)isStopped
{
    currentIndex = nextIndex;
    
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@", fileFolderPath, fileList[currentIndex]];
    NSData *imageFullData = [NSData dataWithContentsOfFile:fileFullPath];
    NSData *imageRawData = [imageFullData subdataWithRange:NSMakeRange(16, imageFullData.length - 16)];
    
    [NSThread sleepForTimeInterval:0.066];
    
    if(isRewind)
    {
        nextIndex--;
    }
    else
    {
        if(isStopped == false)
        {
            nextIndex++;
        }
    }
    
    return (unsigned char *) [imageRawData bytes];
}

- (void) readImageInfo : (int&) width : (int&) height : (int&) pixelFormat : (int&) stride
{
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@", fileFolderPath, fileList[0]];
    NSData *imageFullData = [NSData dataWithContentsOfFile:fileFullPath];
    
    NSData *widthData  = [imageFullData subdataWithRange:NSMakeRange(0, 4)];
    NSData *heightData  = [imageFullData subdataWithRange:NSMakeRange(4, 4)];
    NSData *pixelFormatData  = [imageFullData subdataWithRange:NSMakeRange(8, 4)];
    NSData *strideData  = [imageFullData subdataWithRange:NSMakeRange(12, 4)];
    
    width = [Utils DataToInt:widthData];
    height = [Utils DataToInt:heightData];
    pixelFormat = [Utils DataToInt:pixelFormatData];
    stride = [Utils DataToInt:strideData];
}

- (int) getCurrentIndex
{
    return currentIndex;
}

- (int) getLastIndex
{
    return (int) fileList.count - 1;
}

- (void) rewind
{
    isRewind = true;
    nextIndex -= 1;
}

- (void) reset
{
    if(isRewind)
    {
        isRewind = false;
    }
    currentIndex = 0;
    nextIndex = 0;
}

@end


