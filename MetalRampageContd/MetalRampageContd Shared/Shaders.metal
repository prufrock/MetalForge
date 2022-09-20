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

struct Vertex
{
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texcoord [[attribute(VertexAttributeUvcoord)]];
    float3 normal [[attribute(VertexAttributeNormal)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texcoord;
    float point_size [[point_size]];
    uint textureId;
};

/*
A simple struct for simple times.
I both understand things better and don't understand things enough so using
 something simpler to avoid confusion about uneeded parameters.
 */
struct VertexOutOnlyPositionAndUv {
    float4 position [[position]]; // the x,y,z,w coordinates of the vertex
    float2 uv; // texture coordinates
};

/*
 A struct to get starting figuring out lighting.
 */
struct VertexOutSimpleLighting {
    float4 position [[position]];
    float2 uv;
    //TODO make this a float3 - need to convert the model matrix to a 3x3
    float4 normal;
};

float2 select_sprite(float2 uv, SpriteSheet spriteSheet, uint spriteIndex);

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
                             constant SpriteSheet &spriteSheet [[buffer(6)]],
                             uint vid [[vertex_id]],
                             uint iid [[instance_id]]
                             ) {
    VertexOut vertex_out {
        .position = matrix * indexedModelMatrix[iid] * float4(in.position, 1),
        .texcoord = select_sprite(in.texcoord, spriteSheet, textureId[iid]),
        .point_size = point_size,
        .textureId = 0
    };

    return vertex_out;
}

vertex VertexOut vertex_indexed_sprite_sheet(Vertex in [[stage_in]],
                             constant matrix_float4x4 &matrix [[buffer(2)]],
                             constant float &point_size [[buffer(3)]],
                             constant matrix_float4x4 *indexedModelMatrix [[buffer(4)]],
                             constant uint *textureId [[buffer(5)]],
                             constant SpriteSheet &spriteSheet [[buffer(6)]],
                             constant uint &spriteIndex [[buffer(7)]],
                             constant uint *indexedFontSpriteIndex [[buffer(8)]],
                             uint vid [[vertex_id]],
                             uint iid [[instance_id]]
                             ) {

    float2 uv = in.texcoord;
    // get it working with the font texture
    if (textureId[iid] == 3) {
        uint selectedSpriteIndex = indexedFontSpriteIndex[iid];
        uv = select_sprite(in.texcoord, spriteSheet, selectedSpriteIndex);
    }

    VertexOut vertex_out {
        .position = matrix * indexedModelMatrix[iid] * float4(in.position, 1),
        .texcoord = uv,
        .point_size = point_size,
        .textureId = textureId[iid]
    };

    return vertex_out;
}

/*
 A simple vertex shader that uses a single transformation matrix to transform the input.
 Also passes texture information to fragment shader.
 - Vertex in: Data about the vertex to be transformed
 - finalTransform: A single matrix that transforms the data in **in**.
 - point_size: The size of the points to be rendered. Useful when only drawing points.
 - id: the index of the current vertex being processed. Do I need this?
 */
vertex VertexOut vertex_with_texcoords(Vertex in [[stage_in]],
                             constant matrix_float4x4 &finalTransform [[buffer(3)]],
                             constant float &point_size [[buffer(4)]],
                             constant uint &textureId [[buffer(5)]],
                             uint id [[vertex_id]]
                             ) {
    VertexOut vertex_out {
        .position = finalTransform * float4(in.position, 1),
        .texcoord = float2(in.texcoord.x, in.texcoord.y),
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


    // replace white with the color
    if (colorSample.r == 1.0 && colorSample.g == 1.0 && colorSample.b == 1.0) {
        return color;
    }

    //return float4(in.texcoord.x, in.texcoord.y, 0, 1);
    return float4(colorSample);
}

/*
 A simpler version of **vertex_with_texcoords**.
 Can the additional texture information be passed to the fragment texture when marshalling
 data for the pipeline?
 - Vertex in: Data about the vertex to be transformed
 - finalTransform: A single matrix that transforms the data in **in**.
 - uint textureId: The id of the texture to use in the spritesheet.
 - SpriteSheet spriteSheet: Describes the spritesheet.
 */
vertex VertexOutOnlyPositionAndUv vertex_only_transform(Vertex in [[stage_in]],
                                                        constant matrix_float4x4 &finalTransform [[buffer(3)]],
                                                        constant uint &textureId [[buffer(4)]],
                                                        constant SpriteSheet &spriteSheet [[buffer(5)]]
                                                        ) {
    VertexOutOnlyPositionAndUv vertex_out {
        .position = finalTransform * float4(in.position, 1),
        .uv = select_sprite(in.texcoord, spriteSheet, textureId)
    };

    return vertex_out;
}

/*
 Renders indexed vertices with lighting.
 - Vertex in: Position of the vertex in model space.
 - matrix_float4x4 camera: Get a good look at the vertices.
 - matrix_float4x4 worldTransform: Bring the vertices into the world.
 - uint textureId: Used to select the texture in the sprite sheet.
 - SpriteSheet spriteSheet: The dimensions of the sprite sheet, used to adjust the uv coordinates to select the sprite.
 - uint vid: The id of the vertex currenly being processed, used to select the correct normal to use.
 - uint instance_id: The id of the instance currently being processed, used to select the texureId.
 */
vertex VertexOutSimpleLighting vertex_indexed_lighting(Vertex in [[stage_in]],
                                                  constant matrix_float4x4 &camera [[buffer(3)]],
                                                  constant matrix_float4x4 *worldTransform [[buffer(4)]],
                                                  constant uint *textureId [[buffer(5)]],
                                                  constant SpriteSheet &spriteSheet [[buffer(6)]],
                                                  uint vid [[vertex_id]],
                                                  uint iid [[instance_id]]
                                                  ) {
    VertexOutSimpleLighting vertex_out {
        .position = camera * worldTransform[iid] * float4(in.position, 1),
        .uv = select_sprite(in.texcoord, spriteSheet, textureId[iid]),
        .normal = float4(in.normal, 1)
    };

    return vertex_out;
}

/*
 Mixes textures with a light for basic lighting.
 */
fragment float4 fragment_simple_light(VertexOutSimpleLighting in [[stage_in]],
                                      texture2d<half> texture [[ texture(0) ]],
                                      constant float4 &color [[buffer(0)]]
                                      ) {

    // need a color sample to extract color from the texture
    constexpr sampler colorSampler(coord::normalized, address::repeat, filter::nearest);

    half4 colorSample;

    // get the color for the current position
    colorSample = texture.sample(colorSampler, in.uv);

    // if alpha is below the threshold don't render this fragment
    if (colorSample.a < 0.1) {
        discard_fragment();
    }

    // replace white with the provided color
    if (colorSample.r == 1.0 && colorSample.g == 1.0 && colorSample.b == 1.0) {
        return color;
    }

    float4 sky = float4(0.34, 0.9, 1.0, 1.0);
    float4 earth = float4(0.29, 0.58, 0.2, 1.0);
    float4 black = float4(0.0, 0.0, 0.0, 1.0);

    float intensity = in.normal.y * 0.5 + 0.5;
    return mix(mix(sky, earth, intensity), float4(colorSample), in.normal.y * 0.5 + 0.5);

    // Lets take a look at the values to understand if the right normal is coming in.
    // return float4(in.normal.x, in.normal.y, in.normal.z, 1);
}

/*
 A fragment shader will eventually be able to sample from a spritesheet.
 - VertexOutOnlyPositionAndUv in: The vertex data needed to determine the colors.
 - texture2d<half> texture: The texture to sample from, eventall a sprite sheet.
 - float4 color: Replaces white with this color, useful for troubleshooting.
 */
fragment float4 fragment_sprite_sheet(
                                      VertexOutOnlyPositionAndUv in [[stage_in]],
                                      texture2d<half> texture [[ texture(0) ]],
                                      constant float4 &color [[buffer(0)]]
                                      ) {

    // need a color sample to extract color from the texture
    constexpr sampler colorSampler(coord::normalized, address::repeat, filter::nearest);

    half4 colorSample;

    // get the color for the current position
    colorSample = texture.sample(colorSampler, in.uv);

    // if alpha is below the threshold don't render this fragment
    if (colorSample.a < 0.1) {
        discard_fragment();
    }

    // replace white with the provided color
    if (colorSample.r == 1.0 && colorSample.g == 1.0 && colorSample.b == 1.0) {
        return color;
    }

    return float4(colorSample);
}

fragment float4 fragment_effect(constant float4 &color [[buffer(0)]]) {
    return float4(color.x, color.y, color.z, color.w);
}

/*
 Adjusts the uv coordinates to show a region of a sprite sheet based on its dimensions and the index.
 */
float2 select_sprite(float2 uv, SpriteSheet spriteSheet, uint spriteIndex) {
    float txX = uv.x;
    float txY = uv.y;
    int spritesPerRow = int(spriteSheet.textureWidth / spriteSheet.spriteWidth);
    int spriteX = spriteIndex % spritesPerRow;
    int spriteY = spriteIndex / spritesPerRow;
    float txOffsetX = spriteSheet.spriteWidth / spriteSheet.textureWidth;
    float txOffsetY = spriteSheet.spriteHeight / spriteSheet.textureHeight;
    if (txX == 1.0) {
        txX = txOffsetX + txOffsetX * spriteX;
    } else if (txX == 0.0) {
        txX = txOffsetX * spriteX;
    }
    if (txY == 1.0) {
        txY = txOffsetY + txOffsetY * spriteY;
    } else if (txY == 0.0) {
        txY = txOffsetY * spriteY;
    }

    return float2(txX, txY);
}
