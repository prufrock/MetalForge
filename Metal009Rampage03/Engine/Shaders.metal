//
//  Shaders.metal
//  Engine
//
//  Created by David Kanenwisher on 12/13/21.
//

#include <metal_stdlib>
#include <simd/simd.h>
// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texcoord [[attribute(VertexAttributeTexcoord)]];
} Vertex;

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
};

vertex VertexOut vertex_main(Vertex in [[stage_in]],
                             constant matrix_float4x4 &matrix [[buffer(1)]],
                             constant float &point_size [[buffer(2)]],
                             uint id [[vertex_id]]
                             ) {
    VertexOut vertex_out {
        .position = matrix * float4(in.position, 1),
        .point_size = point_size
    };

    return vertex_out;
}

fragment float4 fragment_main(constant float4 &color [[buffer(0)]]) {
    return color;
}
