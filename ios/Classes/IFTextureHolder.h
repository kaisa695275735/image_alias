//
//  IFTextureHolder.h
//  ifeditor
//
//  Created by lujunchen on 2019/3/8.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface IFTextureHolder : NSObject<FlutterTexture>
- (void)onTextureAvaliable:(GLuint)glTexID;
- (void)onPixelBufferAvaliable:(CVPixelBufferRef)buffer;
- (void)updateTexture:(GLuint)glTexID;
- (instancetype)initWitRegistry:(id)registry;
- (void)releaseTexture;
@property(nonatomic,assign) int64_t                                  textureID;
@end

NS_ASSUME_NONNULL_END
