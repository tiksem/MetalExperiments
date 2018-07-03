//
// Created by Semyon Tikhonenko on 7/3/18.
// Copyright (c) 2018 Neborosoft. All rights reserved.
//

#import "MainView.h"


@implementation MainView {
    MTLRenderPipelineDescriptor* _pipelineStateDescriptor;
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLCommandQueue> _queue;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.delegate = self;
        [self onInit];
    }

    return self;
}

- (void)onInit {
    self.device = MTLCreateSystemDefaultDevice();

    id <MTLLibrary> library = [self.device newDefaultLibrary];
    id <MTLFunction> fragmentShader = [library newFunctionWithName:@"basic_fragment"];
    id <MTLFunction> vertexShader = [library newFunctionWithName:@"basic_vertex"];

    _pipelineStateDescriptor = [MTLRenderPipelineDescriptor new];
    _pipelineStateDescriptor.vertexFunction = vertexShader;
    _pipelineStateDescriptor.fragmentFunction = fragmentShader;
    _pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;

    NSError *error = nil;
    _pipelineState = [self.device newRenderPipelineStateWithDescriptor:_pipelineStateDescriptor error:&error];

    if (error) {
            NSLog(@"Error = %@", error.localizedDescription);
        }

    _queue = [self.device newCommandQueue];
}


- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {

}

- (void)drawInMTKView:(nonnull MTKView *)view {
    auto* renderPassDescriptor = [MTLRenderPassDescriptor new];
    id <CAMetalDrawable> drawable = self.currentDrawable;
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].clearColor =
            MTLClearColorMake(221.0/255.0, 160.0/255.0, 221.0/255.0, 1.0);

    id <MTLCommandBuffer> commandBuffer = [_queue commandBuffer];

    id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderEncoder setRenderPipelineState:_pipelineState];

    static float vertexes[] = {
            0.0, 0.5, 0.0,
            -0.5f, -0.5f, 0.0,
            0.5, -0.5f, 0.0
    };

    id <MTLBuffer> buffer = [self.device newBufferWithBytes:vertexes
            length:sizeof(vertexes) options:MTLResourceStorageModeManaged];
    [renderEncoder setVertexBuffer:buffer offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
    [renderEncoder endEncoding];

    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

@end