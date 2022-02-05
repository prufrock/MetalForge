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
    float3 position [[attribute(0)]];
    float2 texcoord [[attribute(1)]];
} Vertex;

struct VertexOut {
    float4 position [[position]];
    float2 texcoord;
    float point_size [[point_size]];
};

vertex VertexOut vertex_main(Vertex in [[stage_in]],
                             constant matrix_float4x4 &matrix [[buffer(3)]],
                             constant float &point_size [[buffer(4)]],
                             uint id [[vertex_id]]
                             ) {
    VertexOut vertex_out {
        .position = matrix * float4(in.position, 1),
        .texcoord = float2(5 * in.texcoord.x, 5 * in.texcoord.y), // I'm pretty sure the problem has something to do with texcoords not being passed to vertex_main correctly
        .point_size = point_size
    };

    return vertex_out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              texture2d<half> texture [[ texture(0) ]],
                              constant float4 &color [[buffer(0)]]
                              ) {
    constexpr sampler colorSampler(coord::normalized, address::repeat, filter::linear);

    half4 colorSample = texture.sample(colorSampler, in.texcoord);

    return float4(colorSample);
}
