//
//  ShaderTypes.h
//  MetalRampageContd Shared
//
//  Created by David Kanenwisher on 3/5/22.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//
#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

typedef NS_ENUM(NSInteger, BufferIndex)
{
    BufferIndexMeshPositions = 0,
    BufferIndexMeshGenerics  = 1,
    BufferIndexUniforms      = 2,
    BufferIndexLights        = 3 // the buffer that holds Light structs - fragment buffer
};

typedef NS_ENUM(NSInteger, VertexAttribute)
{
    VertexAttributePosition = 0,
    VertexAttributeUvcoord  = 1,
    VertexAttributeNormal   = 2,
};

typedef NS_ENUM(NSInteger, TextureIndex)
{
    TextureIndexColor = 0,
};

typedef struct
{
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
} Uniforms;

typedef struct
{
    float textureWidth;
    float textureHeight;
    float spriteWidth;
    float spriteHeight;
} SpriteSheet;

// For some reason when I defined this with NS_ENUM(...) the second level passed 0 for the LightType.
typedef enum
{
    unused     = 0,
    Sun        = 1,
    Spot       = 2,
    PointLight = 3,
    Ambient    = 4
} LightType;

typedef struct {
    vector_float3 position;
    vector_float3 color;
    vector_float3 specularColor;
    float radius;
    vector_float3 attenuation;
    float coneAngle;
    vector_float3 coneDirection;
    float coneAttentuation;
    LightType type;
} Light;

typedef struct {
    // Can't get the size of an array in a shader so it has to be passed in.
    uint lightCount;
    vector_float3 cameraPosition;
} FragmentUniforms;

#endif /* ShaderTypes_h */

