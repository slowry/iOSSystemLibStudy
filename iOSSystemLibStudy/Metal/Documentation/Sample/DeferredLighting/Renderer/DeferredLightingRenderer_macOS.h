/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for renderer class which performs Metal setup and per frame rendering for macOS
*/

#if TARGET_OS_IPHONE

#import "DeferredLightingRenderer.h"

@interface DeferredLightingRenderer_macOS : DeferredLightingRenderer <MTKViewDelegate>

@end

#endif
