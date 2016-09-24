//
//  Function.metal
//  MetalBase
//
//  Created by Artem Sherbachuk (UKRAINE) on 9/24/16.
//  Copyright © 2016 FSStudio. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

vertex Vertex vertex_main(device Vertex *vertices [[buffer(0)]], uint vid [[vertex_id]]) {
    return vertices[vid];
};

fragment float4 fragment_main(Vertex inVertex[[stage_in]]) {
    return inVertex.color;
};


