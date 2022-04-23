//////////////////////////////////////////////////////////////////////////////
// ©2006 Electronic Arts Inc
//
// Shadow Parameters
//////////////////////////////////////////////////////////////////////////////

// Include platform specific
#if defined( EA_PLATFORM_XENON )
#include "ShadowMap_xenon.fxh"
#else
#include "ShadowMap_win32.fxh"
#endif

bool HasShadow
<
	string UIWidget = "None";
	string SasBindAddress = "Sas.HasShadow";
>;

SAMPLER_2D_SHADOW( ShadowMap )

float4 Shadowmap_Zero_Zero_OneOverMapSize_OneOverMapSize : register(c11)
<
	string UIWidget = "None";
	string SasBindAddress = "Sas.Shadow[0].Zero_Zero_OneOverMapSize_OneOverMapSize";
>;
