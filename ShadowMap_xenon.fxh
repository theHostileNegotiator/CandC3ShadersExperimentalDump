//////////////////////////////////////////////////////////////////////////////
// ©2006 Electronic Arts Inc
//
// Shadow functions for Xenon
//////////////////////////////////////////////////////////////////////////////

static const float shadowZBias = 0.0015; // Can use 0.001 with post processing pass

float4 CalculateShadowMapTexCoord(float4x4 WorldToShadow, float3 worldPosition)
{
	float4 shadowTexCoord = mul(float4(worldPosition, 1), WorldToShadow);

	shadowTexCoord.xyz /= shadowTexCoord.w;
	shadowTexCoord.z -= shadowZBias;

	return shadowTexCoord;
}

float4 CalculateShadowMapTexCoord_PerspectiveCorrect(float4x4 WorldToShadow, float3 worldPosition)
{
	float4 shadowTexCoord = mul(float4(worldPosition, 1), WorldToShadow);
	return shadowTexCoord;
}

//
// Shadow mapping look-up function. Similar to DXSAS prototype.
//
#define XENON_USE_PCF_16 // Note (WSK): Comment this out to disable using 16 PCF samples on xenon  

float g_fShadowSampleScale = 2.0;
float shadow(sampler2D shadowSampler, float4 shadowTexCoord, float4 Zero_Zero_OneOverMapSize_OneOverMapSize)
{
	float2 t = shadowTexCoord.xy;

#if defined( XENON_USE_PCF_16 )

	float scale = Zero_Zero_OneOverMapSize_OneOverMapSize.z / g_fShadowSampleScale;
	float sum = 0.0;

	float4 samples;
	samples = float4(
		tex2D(shadowSampler, t + scale * float2(-1.5, -1.5)).x,
		tex2D(shadowSampler, t + scale * float2(-1.5, -0.5)).x,
		tex2D(shadowSampler, t + scale * float2(-1.5,  0.5)).x,
		tex2D(shadowSampler, t + scale * float2(-1.5,  1.5)).x);

    sum += dot(1.0, step( shadowTexCoord.z, samples ));

	samples = float4(
		tex2D(shadowSampler, t + scale * float2(-0.5, -1.5)).x,
		tex2D(shadowSampler, t + scale * float2(-0.5, -0.5)).x,
		tex2D(shadowSampler, t + scale * float2(-0.5,  0.5)).x,
		tex2D(shadowSampler, t + scale * float2(-0.5,  1.5)).x);

    sum += dot(1.0, step( shadowTexCoord.z, samples ));

	samples = float4(
		tex2D(shadowSampler, t + scale * float2( 0.5, -1.5)).x,
		tex2D(shadowSampler, t + scale * float2( 0.5, -0.5)).x,
		tex2D(shadowSampler, t + scale * float2( 0.5,  0.5)).x,
		tex2D(shadowSampler, t + scale * float2( 0.5,  1.5)).x);

    sum += dot(1.0, step( shadowTexCoord.z, samples ));

	samples = float4(
		tex2D(shadowSampler, t + scale * float2( 1.5, -1.5)).x,
		tex2D(shadowSampler, t + scale * float2( 1.5, -0.5)).x,
		tex2D(shadowSampler, t + scale * float2( 1.5,  0.5)).x,
		tex2D(shadowSampler, t + scale * float2( 1.5,  1.5)).x);

    sum += dot(1.0, step( shadowTexCoord.z, samples ));

	return (sum / 16.0);

#else
	float4 samples = float4(
		tex2D(shadowSampler, t).x,
		tex2D(shadowSampler, t + Zero_Zero_OneOverMapSize_OneOverMapSize.zx).x,
		tex2D(shadowSampler, t + Zero_Zero_OneOverMapSize_OneOverMapSize.yz).x,
		tex2D(shadowSampler, t + Zero_Zero_OneOverMapSize_OneOverMapSize.wz).x);
		
	bool4 bits = (samples - shadowTexCoord.z >= 0);

	//if (any(t <= 0.0 || t >= 1.0))
	//	bits = 1;
	
	return dot(1.0, bits) / 4.0;
#endif
}


float shadow_PerspectiveCorrect(sampler2D shadowSampler, float4 shadowTexCoord, float4 Zero_Zero_OneOverMapSize_OneOverMapSize)
{
	shadowTexCoord.xyz /= shadowTexCoord.w;
	shadowTexCoord.z -= shadowZBias;

    return shadow(shadowSampler, shadowTexCoord, Zero_Zero_OneOverMapSize_OneOverMapSize);
}

float shadowSimple(sampler2D shadowSampler, float4 shadowTexCoord, float4 Zero_Zero_OneOverMapSize_OneOverMapSize)
{
	float2 t = shadowTexCoord.xy;
	float depth = shadowTexCoord.z;
	return tex2D(shadowSampler, t).x - depth >= 0;
}

#define shadow_sampler(ShadowMap) \
	sampler_state \
	{ \
		Texture = <ShadowMap>; \
		MinFilter = Point; \
		MagFilter = Point; \
		MipFilter = None; \
		AddressU = Clamp; \
		AddressV = Clamp; \
	}
	
#define SAMPLER_2D_SHADOW( shadowMapName ) \
	SAMPLER_2D_BEGIN( shadowMapName, \
		string UIWidget = "None"; \
		string SasBindAddress = "Sas.Shadow[0].ShadowMap"; \
		) \
		MinFilter = Point; \
		MagFilter = Point; \
		MipFilter = None; \
		AddressU = Clamp; \
		AddressV = Clamp; \
	SAMPLER_2D_END
