//
//  Shaders.metal
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
};

vertex VertexOut vertex_main(constant float3 *vertices [[buffer(0)]],
                             constant matrix_float4x4 &matrix [[buffer(1)]],
                             uint id [[vertex_id]]
                             ) {
    VertexOut vertex_out {
        .position = matrix * float4(vertices[id], 1),
        .point_size = 10.0
    };

    return vertex_out;
}

fragment float4 fragment_main(constant float4 &color [[buffer(0)]]) {
    return color;
}

