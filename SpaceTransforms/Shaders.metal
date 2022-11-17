//
//  Shaders.metal
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/16/22.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;


struct Vertex
{
    float3 position [[attribute(0)]];
};

struct VertexOut {
    float4 position [[position]];
    // when rendering points you need to specify the point_size or else it grabs it from a random place.
    float point_size [[point_size]];
};

vertex VertexOut vertex_main(Vertex v [[stage_in]],
                             constant matrix_float4x4 &transform [[buffer(1)]]
                             ) {
    VertexOut vertex_out {
        .position = transform * float4(v.position, 1),
        .point_size = 20.0
    };

    return vertex_out;
}

fragment float4 fragment_main(constant float4 &color [[buffer(0)]]) {
    return color;
}
