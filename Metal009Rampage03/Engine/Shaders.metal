//
//  Shaders.metal
//  Engine
//
//  Created by David Kanenwisher on 12/13/21.
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
                             constant float &point_size [[buffer(2)]],
                             uint id [[vertex_id]]
                             ) {
    VertexOut vertex_out {
        .position = matrix * float4(vertices[id], 1),
        .point_size = point_size
    };

    return vertex_out;
}

fragment float4 fragment_main(constant float4 &color [[buffer(0)]]) {
    return color;
}
