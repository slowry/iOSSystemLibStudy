/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Metal shaders used for rendering
*/

#if TARGET_OS_IPHONE

#include <metal_stdlib>
#include <simd/simd.h>

#include "ImageFilteringWithHeapsAndFencesShaderTypes.h"

using namespace metal;

typedef struct {
    float4 position [[position]];
    float2 texCoord;
} RasterizerData;

// Vertex shader function
vertex RasterizerData imageFilteringWithHeapsAndFencesTexturedQuadVertex(       uint         vertexID  [[ vertex_id ]],
                                      device AAPLVertex * vertices  [[ buffer(AAPLVertexBufferIndexVertices) ]],
                                      constant float2   & quadScale [[ buffer(AAPLVertexBufferIndexScale) ]])
{
    RasterizerData out;

    float2 position = vertices[vertexID].position * quadScale;

    out.position.xy = position;
    out.position.z  = 0.0;
    out.position.w  = 1.0;

    out.texCoord = vertices[vertexID].texCoord;

    return out;
}

// Fragment shader function
fragment half4 imageFilteringWithHeapsAndFencesTexturedQuadFragment(RasterizerData   in         [[ stage_in ]],
                                    texture2d<half>  texture    [[ texture(AAPLFragmentTextureIndexImage) ]],
                                    constant float & mipmapBias [[ buffer(AAPLFragmentBufferIndexMipBias) ]])
{
    constexpr sampler sampler(min_filter::linear,
                              mag_filter::linear,
                              mip_filter::linear);

    half4 color = texture.sample(sampler, in.texCoord, level(mipmapBias));

    return color;
}

#endif
