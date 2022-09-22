//
//  Lighting.metal
//  MetalRampageContd
//
//  Created by David Kanenwisher on 9/20/22.
//

#include <metal_stdlib>
using namespace metal;


#import "Lighting.h"

/*

 */
float3 phongLighting(
    float3 normal,
    float3 position,
    constant FragmentUniforms &fragmentUniforms,
    constant Light *lights,
    float3 baseColor
) {
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;
    for (uint i = 0; i < fragmentUniforms.lightCount; i++) {
        Light light = lights[i];
        switch (light.type) {
            case Sun: {
                // Convert to a unit vector.
                float3 lightDirection = normalize(-light.position);
                // Need to understand this better.
                float diffuseIntensity = saturate(-dot(lightDirection, normal));
                // mix the colors together with intensity
                diffuseColor += light.color * baseColor * diffuseIntensity;
                break;
            }
            case PointLight: {
                break;
            }
            case Spot: {
                break;
            }
            case Ambient: {
                break;
            }
            case unused: {
                break;
            }
        }
    }

    // mix the colors together
    return diffuseColor + specularColor + ambientColor;
}
