//
// Created by David Kanenwisher on 7/6/21.
//

/**
 I thought I was going to do this with a float4 but then I thought, "Why not try this with a float3?". I don't think
 I need to add a W to individual points. I will need a way to convert them to float4s with a W when I pass them to the
 shader but I can make that happen when I pass that in right? Gonna see how it goes.

 I went with a struct because I figure it doesn't need to "referenced" in different places, especially since it's
 immutable. It can be immutable because if the Point does change it can simply be updated. Maybe at some point I should
 add all the math bits to make the possible, might be fun.

 Should this be a 3D Point? Maybe a Point3D? I'll think about it.
 */
struct Point: RawRepresentable {
    let rawValue: float3
    
    init(rawValue: float3) {
        self.rawValue = rawValue
    }

    init(_ x: Float, _ y: Float, _ z: Float) {
        rawValue = [x, y, z]
    }
}
