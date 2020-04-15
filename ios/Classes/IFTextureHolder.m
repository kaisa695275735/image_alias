//
//  IFTextureHolder.m
//  ifeditor
//
//  Created by lujunchen on 2019/3/8.
//

#import "IFTextureHolder.h"
#import <AVFoundation/AVFoundation.h>
@interface IFTextureHolder()
@property(nonatomic,assign)             GLuint                                  glTexID;
@property(nonatomic,assign)             CVPixelBufferRef                        pixelBuffer;
@property(readonly, nonatomic)          NSObject<FlutterTextureRegistry>        *registry;
@end

@implementation IFTextureHolder

- (instancetype)initWitRegistry:(id)registry{
    self = [super init];
    _registry = registry;
    return self;
}

- (void)onPixelBufferAvaliable:(CVPixelBufferRef)buffer{
    _pixelBuffer = buffer;
}

- (void)onTextureAvaliable:(GLuint)glTexID{
    _glTexID = glTexID;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.registry textureFrameAvailable:self.textureID];
    });
}

- (void)updateTexture:(GLuint)glTexID{
    _glTexID = glTexID;
}

- (GLuint)copyTextureID{
    return _glTexID;
}

- (CVPixelBufferRef)copyPixelBuffer
{
    return _pixelBuffer;
}

- (void)releaseTexture{
    _glTexID = 0;
    [self.registry unregisterTexture:self.textureID];
}
@end
