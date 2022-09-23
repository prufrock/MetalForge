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
    // until we can get the values from the material
    float materialShininess = 32;
    float3 materialSpecularColor = float3(1, 1, 1);

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

                if (diffuseIntensity > 0) {
                    // Need to understand this better
                    float3 reflection = reflect(lightDirection, normal);
                    float3 viewDirection = normalize(fragmentUniforms.cameraPosition);
                    float specularIntensity = pow(saturate(dot(reflection, viewDirection)), materialShininess);
                    specularColor += light.specularColor * materialSpecularColor * specularIntensity;
                }
                break;
            }
            case PointLight: {
                float d = distance(light.position, position);
                float3 lightDirection = normalize(light.position - position);
                float attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * d * d);
                float diffuseIntensity = saturate(dot(lightDirection, normal));
                float3 color = light.color * baseColor * diffuseIntensity;
                color *= attenuation;
                diffuseColor += color;
                break;
            }
            case Spot: {
                // Need to understand this better
                float d = distance(light.position, position);
                float3 lightDirection = normalize(light.position - position);
                float3 coneDirection = normalize(light.coneDirection);
                float spotResult = dot(lightDirection, -coneDirection);
                if (spotResult > cos(light.coneAngle)) {
                  float attenuation = 1.0 / (light.attenuation.x +
                      light.attenuation.y * d + light.attenuation.z * d * d);
                  attenuation *= pow(spotResult, light.coneAttenuation);
                  // I shouldn't need to abs this!
                  float lightNormal = abs(dot(lightDirection, normal));
//                  float lightNormal = dot(lightDirection, normal);
                  float diffuseIntensity = saturate(lightNormal);
                  float3 color = light.color * baseColor * diffuseIntensity;
                  color *= attenuation;
                  diffuseColor += color;
//                    if (lightNormal < 0) {
//                        diffuseColor = float3(1, 0, 0);
//                    } else {
//                        diffuseColor = float3(0, 1, 0);
//                    }
                }
                break;
            }
            case Ambient: {
                ambientColor += light.color;
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
