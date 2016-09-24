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
@import simd;

typedef struct {
    vector_float4 position;
    vector_float4 color;
}ASVertex;

@interface ASMetalView()
@property(readonly) id<MTLDevice> device;
@property(nonatomic) id<MTLBuffer> vertexBuffer;
@property(nonatomic) id<MTLRenderPipelineState> pipelineState;
@property(nonatomic) id<MTLCommandQueue> commandQueue;
@property(nonatomic) CADisplayLink *displayLink;
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
    [self setupDevice];
    [self makeBuffers];
    [self makePipeline];
}
- (void)setupDevice {
    _device = MTLCreateSystemDefaultDevice();
    self.metalLayer.device = _device;
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
}
- (void)makeBuffers {
    static const ASVertex vertices[] = {
        { .position = { 0.0, 0.5, 0, 1 }, .color = {1,0,0,1} },
        {.position = { -0.5, -0.5, 0, 1 }, .color = {0,1,0,1} },
        {.position = { 0.5, -0.5, 0, 1 }, .color = {0,0,1,1} }
    };
    self.vertexBuffer = [_device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceOptionCPUCacheModeDefault];
}
- (void)makePipeline {
    id<MTLLibrary> library = [_device newDefaultLibrary];
    id<MTLFunction> vertexFunc = [library newFunctionWithName:@"vertex_main"];
    id<MTLFunction> fragmentFunc = [library newFunctionWithName:@"fragment_main"];
    
    MTLRenderPipelineDescriptor *pipelineDescr = [MTLRenderPipelineDescriptor new];
    pipelineDescr.vertexFunction = vertexFunc;
    pipelineDescr.fragmentFunction = fragmentFunc;
    pipelineDescr.colorAttachments[0].pixelFormat = self.metalLayer.pixelFormat;
    
    self.pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescr error:NULL];
    self.commandQueue = [_device newCommandQueue];
}


- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self redraw];
    if (self.superview) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkFire:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)redraw {
    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    id<MTLTexture> texture = drawable.texture;
    
    if (drawable) {
        MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
        passDescriptor.colorAttachments[0].texture = texture;
        passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.8, 0.8, 0.8, 1);
        
        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        
        id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
        [commandEncoder setRenderPipelineState:self.pipelineState];
        [commandEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
        [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
        [commandEncoder endEncoding];
        
        [commandBuffer presentDrawable:drawable];
        [commandBuffer commit];
    }
}

- (void)displayLinkFire:(CADisplayLink *)link {
    [self redraw];
}

@end
