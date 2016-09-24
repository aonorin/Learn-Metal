//
//  ASMetalView.m
//  MetalBase
//
//  Created by Artem Sherbachuk (UKRAINE) on 9/24/16.
//  Copyright © 2016 FSStudio. All rights reserved.
//

#import "ASMetalView.h"
#import <QuartzCore/QuartzCore.h>
@import Metal;

@interface ASMetalView()
@property(readonly) id<MTLDevice> device;
@end

@implementation ASMetalView

+ (Class)layerClass {
    return [CAMetalLayer class];
}

- (CAMetalLayer *)metalLayer {
    return (CAMetalLayer *)self.layer;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)setup {
    _device = MTLCreateSystemDefaultDevice();
    self.metalLayer.device = _device;
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
}
- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self redraw];
}

- (void)redraw {
    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    id<MTLTexture> texture = drawable.texture;
    MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    passDescriptor.colorAttachments[0].texture = texture;
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 1, 1);
    
    id<MTLCommandQueue> commandQueue = [self.device newCommandQueue];
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    [commandEncoder endEncoding];
    
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

@end
