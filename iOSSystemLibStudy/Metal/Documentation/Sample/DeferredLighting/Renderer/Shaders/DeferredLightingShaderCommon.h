/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header containing structure shared between .metal shader files
*/

#if TARGET_OS_IPHONE

#ifndef DeferredLightingShaderCommon_h
#define DeferredLightingShaderCommon_h

// Raster order group definitions
#define AAPLLightingROG  0
#define DeferredLightingBufferROG   1

// G-buffer outputs using Raster Order Groups
struct GBufferData
{
    half4 lighting        [[color(AAPLRenderTargetLighting), raster_order_group(AAPLLightingROG)]];
    half4 albedo_specular [[color(AAPLRenderTargetAlbedo),   raster_order_group(DeferredLightingBufferROG)]];
    half4 normal_shadow   [[color(AAPLRenderTargetNormal),   raster_order_group(DeferredLightingBufferROG)]];
    float depth           [[color(AAPLRenderTargetDepth),    raster_order_group(DeferredLightingBufferROG)]];
};

// Final buffer outputs using Raster Order Groups
struct AccumLightBuffer
{
    half4 lighting [[color(AAPLRenderTargetLighting), raster_order_group(AAPLLightingROG)]];
};

// Per-vertex inputs fed by vertex buffer laid out with MTLVertexDescriptor in Metal API
typedef struct
{
    float3 position  [[attribute(AAPLVertexAttributePosition)]];
    float2 tex_coord [[attribute(AAPLVertexAttributeTexcoord)]];
    half3 normal     [[attribute(AAPLVertexAttributeNormal)]];
    half3 tangent    [[attribute(AAPLVertexAttributeTangent)]];
    half3 bitangent  [[attribute(AAPLVertexAttributeBitangent)]];
} Vertex;

#endif // DeferredLightingShaderCommon_h

#endif
