//
//  CrystalPlasma.metal
//  DreamInterpreter
//
//  Created by John Martino on 6/19/26.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// MARK: - Noise primitives

// Cheap 2D hash -> [0, 1)
static float hash(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// Value noise with smooth (quintic) interpolation.
static float valueNoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    float a = hash(i + float2(0.0, 0.0));
    float b = hash(i + float2(1.0, 0.0));
    float c = hash(i + float2(0.0, 1.0));
    float d = hash(i + float2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Fractal Brownian motion: stacked octaves of noise. This is what gives
// the plasma its self-similar, fractal character.
static float fbm(float2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float2x2 rot = float2x2(0.80, 0.60, -0.60, 0.80); // rotate each octave to hide grid
    for (int i = 0; i < 6; i++) {
        value += amplitude * valueNoise(p);
        p = rot * p * 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// MARK: - Crystal ball plasma

// A color effect: returns the (premultiplied) color for each pixel.
// Pixels outside the sphere are returned fully transparent.
[[ stitchable ]] half4 crystalPlasma(float2 position, half4 color, float2 size, float time, half4 coolColor, half4 hotColor) {
    // Centered, normalized coordinates where the sphere has radius 1.
    float radius = 0.5 * min(size.x, size.y);
    float2 uv = (position - 0.5 * size) / radius;
    float r = length(uv);

    // Discard anything beyond the sphere.
    if (r > 1.0) {
        return half4(0.0);
    }

    // Reconstruct the sphere's surface: z is the height of the hemisphere.
    float z = sqrt(max(0.0, 1.0 - r * r));
    float3 normal = float3(uv, z);

    // Project onto the sphere with a slight "fish-eye" so the plasma appears
    // to wrap over a glass surface rather than lying flat.
    float2 p = normal.xy / (normal.z * 0.7 + 0.5);

    // Vortex: rotate the sample field by an angle that grows toward the rim,
    // and drift it over time so the plasma seems to swirl inside the ball.
    float t = time * 0.32;
    float angle = r * 2.0 + t;
    float ca = cos(angle);
    float sa = sin(angle);
    p = float2x2(ca, -sa, sa, ca) * p;

    // Liquid domain warping: feed fbm into itself several times, advecting the
    // coordinates along the previous layer so the field flows and folds like
    // a swirling fluid rather than static smoke.
    float2 flow = float2(cos(t * 0.7), sin(t * 0.9)) * 0.5;
    float2 q = float2(fbm(p + flow),
                      fbm(p + float2(5.2, 1.3) - flow));
    float2 warp = float2(fbm(p + 3.0 * q + float2(1.7, 9.2) + t * 0.8),
                         fbm(p + 3.0 * q + float2(8.3, 2.8) - t * 0.7));
    // A second advected warp adds the curling, liquid-folding motion.
    warp += 0.6 * float2(fbm(p + 4.0 * warp + flow * 2.0),
                         fbm(p + 4.0 * warp.yx - flow * 2.0));
    float f = fbm(p + 4.0 * warp);

    // Shape the field so the orb reads as mostly bright white plasma with
    // softer silver currents swirling through it (rather than dark voids).
    float plasma = smoothstep(0.15, 0.85, f);
    float filament = pow(saturate(f), 3.0);

    // Palette derived from the two passed-in colors.
    half3 low = coolColor.rgb;
    half3 mid = mix(coolColor.rgb, hotColor.rgb, half(0.5));
    half3 hot = hotColor.rgb;
    half3 col = mix(low, mid, half(smoothstep(0.0, 0.55, plasma)));
    col = mix(col, hot, half(smoothstep(0.45, 1.0, plasma)));

    // Self-illumination: bright filaments glow at the hot color.
    col += hot * half(filament) * 1.2;

    // Fresnel rim glow — the energy gathers and brightens at the edge.
    float fres = pow(1.0 - z, 3.0);
    col += mid * half(fres) * 0.9;

    // Specular highlight: a soft glass reflection up and to the left.
    float2 hl = uv - float2(-0.32, -0.38);
    float highlight = smoothstep(0.45, 0.0, length(hl));
    col += half3(1.0) * half(highlight * highlight) * 0.6;

    // A subtle darkening toward the very bottom grounds it as a glass orb.
    col *= half(mix(1.0, 0.85, smoothstep(-0.2, 1.0, uv.y)));

    // Antialiased edge.
    float alpha = smoothstep(1.0, 0.985, r);

    // Premultiplied output.
    return half4(col * half(alpha), half(alpha));
}

