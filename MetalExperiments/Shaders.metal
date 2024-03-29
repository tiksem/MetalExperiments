//
//  Shaders.metal
//  MetalExperiments
//
//  Created by Semyon Tikhonenko on 7/3/18.
//  Copyright © 2018 Neborosoft. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 basic_vertex(
                           const device packed_float3* vertex_array [[ buffer(0) ]],
                           unsigned int vid [[ vertex_id ]]) {
    return float4(vertex_array[vid] - float3(0.2, 0.2, 0), 1.0);
}

fragment half4 basic_fragment() {
    return half4(0.5, 0.5, 0.1, 1);
}


