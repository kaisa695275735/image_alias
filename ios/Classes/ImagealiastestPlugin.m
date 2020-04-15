#import "ImagealiastestPlugin.h"
#import "IFGLUtil.h"
#import "IFTextureHolder.h"

@interface ImagealiastestPlugin()
@property(nonatomic,strong) IFTextureHolder                         * holder;
@property(nonatomic,strong) NSObject<FlutterTextureRegistry>        * registry;
@end

@implementation ImagealiastestPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"imagealiastest"
              binaryMessenger:[registrar messenger]];
    ImagealiastestPlugin* instance = [[ImagealiastestPlugin alloc] init];
    instance.registry = registrar.textures;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
      result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  
  }
  else if ([@"create" isEqualToString:call.method]) {
      UIImage * image = [UIImage imageNamed:@"test.png"];
      CVPixelBufferRef pixelBufr = [IFGLUtil createPixelBufferFromImage:image.CGImage];
      self.holder = [[IFTextureHolder alloc] initWitRegistry:self.registry];
      [self.holder onPixelBufferAvaliable:pixelBufr];
      int64_t textureid = [self.registry registerTexture:self.holder];
      result(@{ @"textureId" : @(textureid) });
  }
  else {
      result(FlutterMethodNotImplemented);
  }
}

@end
