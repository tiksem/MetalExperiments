//
//  ViewController.m
//  MetalExperiments
//
//  Created by Semyon Tikhonenko on 7/3/18.
//  Copyright © 2018 Neborosoft. All rights reserved.
//

#import "ViewController.h"
#import <Metal/MTLBuffer.h>
#import <QuartzCore/QuartzCore.h>
#import <Metal/Metal.h>

@implementation ViewController {
    MTLRenderPipelineDescriptor* _pipelineStateDescriptor;
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLCommandQueue> _queue;
    id <MTLDevice> _device;
    CAMetalLayer* _layer;
    CVDisplayLinkRef _displayLink;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _device = MTLCreateSystemDefaultDevice();

    id <MTLLibrary> library = [_device newDefaultLibrary];
    id <MTLFunction> fragmentShader = [library newFunctionWithName:@"basic_fragment"];
    id <MTLFunction> vertexShader = [library newFunctionWithName:@"basic_vertex"];

    _pipelineStateDescriptor = [MTLRenderPipelineDescriptor new];
    _pipelineStateDescriptor.vertexFunction = vertexShader;
    _pipelineStateDescriptor.fragmentFunction = fragmentShader;
    _pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;

    NSError *error = nil;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:_pipelineStateDescriptor error:&error];

    if (error) {
        NSLog(@"Error = %@", error.localizedDescription);
    }

    _queue = [_device newCommandQueue];

    _layer = [CAMetalLayer new];
    _layer.device = _device;
    _layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    _layer.framebufferOnly = true;
    _layer.frame = self.view.layer.frame;
    [self.view.layer addSublayer:_layer];

    CGDirectDisplayID   displayID = CGMainDisplayID();
    CVReturn            error2 = kCVReturnSuccess;
    error2 = CVDisplayLinkCreateWithCGDisplay(displayID, &_displayLink);
    if (error2)
    {
        NSLog(@"DisplayLink created with error:%d", error2);
    }
    CVDisplayLinkSetOutputCallback(_displayLink, renderCallback, (__bridge void *)self);
    CVDisplayLinkStart(_displayLink);
}

static CVReturn renderCallback(CVDisplayLinkRef displayLink,
        const CVTimeStamp *inNow,
        const CVTimeStamp *inOutputTime,
        CVOptionFlags flagsIn,
        CVOptionFlags *flagsOut,
        void *displayLinkContext)
{
    [(__bridge ViewController *)displayLinkContext render];
    return kCVReturnSuccess;
}

- (void)render {
    auto* renderPassDescriptor = [MTLRenderPassDescriptor new];
    id <CAMetalDrawable> drawable = _layer.nextDrawable;
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

    id <MTLBuffer> buffer = [_device newBufferWithBytes:vertexes
            length:sizeof(vertexes) options:MTLResourceStorageModeManaged];
    [renderEncoder setVertexBuffer:buffer offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
    [renderEncoder endEncoding];

    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

- (void)dealloc {
    CVDisplayLinkStop(_displayLink);
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}


@end
