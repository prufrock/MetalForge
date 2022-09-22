//
//  Lighting.h
//  MetalRampageContd
//
//  Created by David Kanenwisher on 9/20/22.
//

#ifndef Lighting_h
#define Lighting_h

#import "ShaderTypes.h"

/**
 Lights the color with the Phong Lighting model.
 normal - the surface normal from the polygon.
 position - where the vertex is located in world space.
 fragmentUniforms - are *uniform* values across all the calls of the callling fragment function.
 lights - the array lights to consider when lighting the color.
 color - lighting target
 */
float3 phongLighting(
    float3 normal,
    float3 position,
    constant FragmentUniforms &fragmentUniforms,
    constant Light *lights,
    float3 baseColor
);

#endif /* Lighting_h */
