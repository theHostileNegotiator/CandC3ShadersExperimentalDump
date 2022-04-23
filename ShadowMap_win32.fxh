//////////////////////////////////////////////////////////////////////////////
// ©2006 Electronic Arts Inc
//
// Shadow functions for PC
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

float shadow(sampler2D shadowSampler, float4 shadowTexCoord, float4 Zero_Zero_OneOverMapSize_OneOverMapSize)
{
	float2 t = shadowTexCoord.xy;
		
	float depth = shadowTexCoord.z;
	
	/*
	float ooSize = 1.0 /1024.0;
	
	float4 samples = float4(
		tex2D(shadowSampler, t).x,
		tex2D(shadowSampler, t + float2(0, ooSize)).x,
		tex2D(shadowSampler, t + float2(ooSize, 0)).x,
		tex2D(shadowSampler, t + float2(ooSize, ooSize)).x);
	*/

	float4 samples = float4(
		tex2D(shadowSampler, t).x,
		tex2D(shadowSampler, t + Zero_Zero_OneOverMapSize_OneOverMapSize.zx).x,
		tex2D(shadowSampler, t + Zero_Zero_OneOverMapSize_OneOverMapSize.yz).x,
		tex2D(shadowSampler, t + Zero_Zero_OneOverMapSize_OneOverMapSize.wz).x);
		
	bool4 bits = (samples - depth >= 0);

	//if (any(t <= 0.0 || t >= 1.0))
	//	bits = 1;
	
	return dot(1.0, bits) / 4.0;
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
