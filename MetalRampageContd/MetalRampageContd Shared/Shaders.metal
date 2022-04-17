//
//  Shaders.metal
//  Engine
//
//  Created by David Kanenwisher on 12/13/21.
//

#include <metal_stdlib>
#include <simd/simd.h>
// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
//#import "ShaderTypes.h"

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
    uint textureId;
};

vertex VertexOut vertex_main(constant float3 *vertices [[buffer(0)]],
                             constant matrix_float4x4 &matrix [[buffer(1)]],
                             constant float &point_size [[buffer(2)]],
                             uint id [[vertex_id]]
                             ) {
    VertexOut vertex_out {
        .position = matrix * float4(vertices[id], 1),
        .texcoord = float2(),
        .point_size = point_size
    };

    return vertex_out;
}

fragment float4 fragment_main(constant float4 &color [[buffer(0)]]) {
    return color;
}

vertex VertexOut vertex_indexed(Vertex in [[stage_in]],
                             constant matrix_float4x4 &matrix [[buffer(2)]],
                             constant float &point_size [[buffer(3)]],
                             constant matrix_float4x4 *indexedModelMatrix [[buffer(4)]],
                             constant uint *textureId [[buffer(5)]],
                             uint vid [[vertex_id]],
                             uint iid [[instance_id]]
                             ) {
    VertexOut vertex_out {
        .position = matrix * indexedModelMatrix[iid] * float4(in.position, 1),
        .texcoord = float2(in.texcoord.x, in.texcoord.y),
        .point_size = point_size,
        .textureId = textureId[iid]
    };

    return vertex_out;
}

vertex VertexOut vertex_with_texcoords(Vertex in [[stage_in]],
                             constant matrix_float4x4 &matrix [[buffer(3)]],
                             constant float &point_size [[buffer(4)]],
                             constant uint &textureId [[buffer(5)]],
                             uint id [[vertex_id]]
                             ) {
    VertexOut vertex_out {
        .position = matrix * float4(in.position, 1),
        .texcoord = float2(in.texcoord.x, in.texcoord.y), // I'm pretty sure the problem has something to do with texcoords not being passed to vertex_main correctly
        .point_size = point_size,
        .textureId = textureId
    };

    return vertex_out;
}

fragment float4 fragment_with_texture(VertexOut in [[stage_in]],
                              texture2d<half> texture0 [[ texture(0) ]],
                              texture2d<half> texture1 [[ texture(1) ]],
                              texture2d<half> texture2 [[ texture(2) ]],
                              texture2d<half> texture3 [[ texture(3) ]],
                              texture2d<half> texture4 [[ texture(4) ]],
                              texture2d<half> texture5 [[ texture(5) ]],
                              texture2d<half> texture6 [[ texture(6) ]],
                              texture2d<half> texture7 [[ texture(7) ]],
                              texture2d<half> texture8 [[ texture(8) ]],
                              texture2d<half> texture9 [[ texture(9) ]],
                              texture2d<half> texture10 [[ texture(10) ]],
                              texture2d<half> texture11 [[ texture(11) ]],
                              texture2d<half> texture12 [[ texture(12) ]],
                              texture2d<half> texture13 [[ texture(13) ]],
                              texture2d<half> texture14 [[ texture(14) ]],
                              texture2d<half> texture15 [[ texture(15) ]],
                              texture2d<half> texture16 [[ texture(16) ]],
                              texture2d<half> texture17 [[ texture(17) ]],
                              texture2d<half> texture18 [[ texture(18) ]],
                              texture2d<half> texture19 [[ texture(19) ]],
                              texture2d<half> texture20 [[ texture(20) ]],
                              constant float4 &color [[buffer(0)]]
                              ) {
    constexpr sampler colorSampler(coord::normalized, address::repeat, filter::nearest);

    half4 colorSample;

    if (in.textureId == 0) {
        colorSample = texture0.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 1) {
        colorSample = texture1.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 2) {
        colorSample = texture2.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 3) {
        colorSample = texture3.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 4) {
        colorSample = texture4.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 5) {
        colorSample = texture5.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 6) {
        colorSample = texture6.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 7) {
        colorSample = texture7.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 8) {
        colorSample = texture8.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 9) {
        colorSample = texture9.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 10) {
        colorSample = texture10.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 11) {
        colorSample = texture11.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 12) {
        colorSample = texture12.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 13) {
        colorSample = texture13.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 14) {
        colorSample = texture14.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 15) {
        colorSample = texture15.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 16) {
        colorSample = texture16.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 17) {
        colorSample = texture17.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 18) {
        colorSample = texture18.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 19) {
        colorSample = texture19.sample(colorSampler, in.texcoord);
    } else if (in.textureId == 20) {
        colorSample = texture20.sample(colorSampler, in.texcoord);
    } else {
        return color;
    }

    if (colorSample.a < 0.1) {
        discard_fragment();
    }

    return float4(colorSample);
}

fragment float4 fragment_effect(constant float4 &color [[buffer(0)]]) {
    return float4(color.x, color.y, color.z, color.w);
}
