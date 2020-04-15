//
//  IFGLUtil.m
//  ifcommon
//
//  Created by lujunchen on 2019/2/28.
//

#import "IFGLUtil.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@implementation IFGLUtil
+ (CVPixelBufferRef)createPixelBufferFromImage:(CGImageRef)image
{
    NSDictionary *options = @{
                              (NSString*)kCVPixelBufferIOSurfacePropertiesKey : @{}
                              };
    
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                                          CGImageGetHeight(image), kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status!=kCVReturnSuccess) {
        NSLog(@"Operation failed");
    }
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace,
                                                 kCGImageByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

+ (void)updateTextureWithWidth:(size_t)width andHeight:(size_t)height textureID:(GLuint)textureID
{
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
}

+ (GLuint)createTextureWithWidth:(size_t)width andHeight:(size_t)height
{
    GLuint textureID = -1;
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    return textureID;
}

+ (void)convertCGImage:(CGImageRef)image toTexture:(GLuint)textureID
{
    CGDataProviderRef dataProvider = CGImageGetDataProvider(image);
    CFDataRef rawDataRef = CGDataProviderCopyData(dataProvider);
    const UInt8 *imageData = CFDataGetBytePtr(rawDataRef);
    
    CGSize displaySize = [self imageDiaplaySize:image];
    
    CGFloat width = displaySize.width;
    CGFloat height = displaySize.height;
    
    [self updateTextureWithWidth:width andHeight:height textureID:textureID];
    
    glEnable(GL_TEXTURE_2D);
    
    glBindTexture(GL_TEXTURE_2D, textureID);
    /**
     *  纹理过滤函数
     *  图象从纹理图象空间映射到帧缓冲图象空间(映射需要重新构造纹理图像,这样就会造成应用到多边形上的图像失真),
     *  这时就可用glTexParmeteri()函数来确定如何把纹理象素映射成像素.
     *  如何把图像从纹理图像空间映射到帧缓冲图像空间（即如何把纹理像素映射成像素）
     */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); // S方向上的贴图模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); // T方向上的贴图模式
    // 线性过滤：使用距离当前渲染像素中心最近的4个纹理像素加权平均值
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    /**
     *  将图像数据传递给到GL_TEXTURE_2D中, 因其于textureID纹理对象已经绑定，所以即传递给了textureID纹理对象中。
     *  glTexImage2d会将图像数据从CPU内存通过PCIE上传到GPU内存。
     *  不使用PBO时它是一个阻塞CPU的函数，数据量大会卡。
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    // 结束后要做清理
    glBindTexture(GL_TEXTURE_2D, 0); //解绑
    CFRelease(rawDataRef);
    //    CGContextRelease(context);
    //    free(imageData);
}

+ (CGSize)imageDiaplaySize:(CGImageRef)image{
    GLuint cgheight =(GLuint) CGImageGetHeight(image);
    GLuint cgbyteperrow =(GLuint)  CGImageGetBytesPerRow(image);
    GLuint cgbitperpixel =(GLuint)  CGImageGetBitsPerPixel(image);
    GLuint cgbitpercomponnet =(GLuint)  CGImageGetBitsPerComponent(image);
    
    GLuint stride = cgbyteperrow /(cgbitperpixel / cgbitpercomponnet);
    return CGSizeMake(stride, cgheight);
}

+ (void)convertCGImage:(CGImageRef)image toTexture:(GLuint)textureID inSize:(CGSize)size
{
    CGImageRef cgImageRef = image;
    GLuint width = size.width;
    GLuint height = size.height;
    CGRect rect = CGRectMake(0, 0, width, height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (context == NULL) {
        free(imageData);
        CGColorSpaceRelease(colorSpace);
        return;
    }
    CGContextTranslateCTM(context, 0, 0);
    CGContextScaleCTM(context, 1.0f, 1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImageRef);
    glEnable(GL_TEXTURE_2D);
    
    glBindTexture(GL_TEXTURE_2D, textureID);
    /**
     *  纹理过滤函数
     *  图象从纹理图象空间映射到帧缓冲图象空间(映射需要重新构造纹理图像,这样就会造成应用到多边形上的图像失真),
     *  这时就可用glTexParmeteri()函数来确定如何把纹理象素映射成像素.
     *  如何把图像从纹理图像空间映射到帧缓冲图像空间（即如何把纹理像素映射成像素）
     */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); // S方向上的贴图模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); // T方向上的贴图模式
    // 线性过滤：使用距离当前渲染像素中心最近的4个纹理像素加权平均值
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    /**
     *  将图像数据传递给到GL_TEXTURE_2D中, 因其于textureID纹理对象已经绑定，所以即传递给了textureID纹理对象中。
     *  glTexImage2d会将图像数据从CPU内存通过PCIE上传到GPU内存。
     *  不使用PBO时它是一个阻塞CPU的函数，数据量大会卡。
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    // 结束后要做清理
    glBindTexture(GL_TEXTURE_2D, 0); //解绑
    CGContextRelease(context);
    free(imageData);
}

+ (GLuint)createFrameBuffer
{
    GLuint frameBuffer = -1;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    return frameBuffer;
}

+ (CVOpenGLESTextureCacheRef)createVideoTextureCache:(EAGLContext *)context
{
    CVOpenGLESTextureCacheRef videoTextureCache = nil;
    CVReturn ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, context, NULL, &videoTextureCache);
    if (ret)
    {
        //monitor error!
    }
    return videoTextureCache;
}
@end
