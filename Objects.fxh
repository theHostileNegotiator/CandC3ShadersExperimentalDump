//////////////////////////////////////////////////////////////////////////////
// �2006 Electronic Arts Inc
//
// FX Shader for vehicles and structures. Infantry should use Infantry.fx
//////////////////////////////////////////////////////////////////////////////

//#define SUPPORT_RECOLORING 1 // Defined only in faction specific versions
//#define SCROLL_HOUSECOLOR 1 // Define for NOD scroll effect
//#define SUPPORT_SPECMAP 1 // Define for objects shader with specularity/envmap/self illumination map
//#define OBJECTS_ALIEN 1 // Define for alien shader variation
//#define SUPPORT_IONHULL 1 // Define for alien shader with ion hull texture
//#define SPECIFY_CUSTOM_ENVMAP 1 // Define to allow environment cube map to be specified in art tool instead of taken from code binding

#define USE_INTERACTIVE_LIGHTS 1
//#define PER_PIXEL_POINT_LIGHT
//#define SUPPORT_POINT_LIGHTS
#include "Common.fxh"


#if defined(EA_PLATFORM_WINDOWS)
// ----------------------------------------------------------------------------
// SAMPLER : nhendricks@ea.com : had to pull these in here for MAX to compile
// ----------------------------------------------------------------------------
#define SAMPLER_2D_BEGIN(samplerName, annotations) \
	texture samplerName \
	< \
		annotations \
	>; \
	sampler2D samplerName##Sampler = sampler_state \
	{ \
		Texture = < samplerName >;
		
#define SAMPLER_2D_END	};

#define SAMPLER( samplerName )	samplerName##Sampler

#define SAMPLER_CUBE_BEGIN(samplerName, annotations) \
	texture samplerName \
	< \
		annotations \
	>; \
	samplerCUBE samplerName##Sampler = sampler_state \
	{ \
		Texture = < samplerName >;
		
#define SAMPLER_CUBE_END };
#endif

string DefaultParameterScopeBlock = "material";

// ----------------------------------------------------------------------------
// Light sources
// ----------------------------------------------------------------------------
static const int NumDirectionalLights = 3;
static const int NumDirectionalLightsPerPixel = 2;
// static const int NumPointLights = 8;
float3 AmbientLightColor
<
	bool unmanaged = 1;
> = float3(0.3, 0.3, 0.3);

SasDirectionalLight DirectionalLight[NumDirectionalLights]
<
	bool unmanaged = 1;
> =
{
	DEFAULT_DIRECTIONAL_LIGHT_1,
	DEFAULT_DIRECTIONAL_LIGHT_2,
	DEFAULT_DIRECTIONAL_LIGHT_3
};

DECLARE_DIRECTIONAL_LIGHT_INTERACTIVE(DirectionalLight, 0);

#if defined(SUPPORT_POINT_LIGHTS)
int NumPointLights
<
	string SasBindAddress = "Sas.NumPointLights";
	string UIWidget = "None";
>;

SasPointLight PointLight[8]
<
	bool unmanaged = 1;
>;
#endif

// ----------------------------------------------------------------------------
// Cloud layer
// ----------------------------------------------------------------------------
CloudSetup Cloud
<
	bool unmanaged = 1;
>;

float3 NoCloudMultiplier
<
	bool unmanaged = 1;
> = float3(1, 1, 1);

// ----------------------------------------------------------------------------
// House coloring
// ----------------------------------------------------------------------------

#if defined(SUPPORT_RECOLORING)

#if defined(_3DSMAX_)

bool NumRecolorColors
<
	string UIName = "Preview House Color Enable";
	bool ExportValue = false;
> = false;

float3 RecolorColor
<
	string UIName = "Preview House Color";
	string UIWidget = "Color";
	bool ExportValue = false;
> = float3(.7, .05, .05);

#else

bool HasRecolorColors
<
	string UIWidget = "None";
	string SasBindAddress = "WW3D.HasRecolorColors";
	bool ExportValue = 0;
>;

float3 RecolorColor
<
	bool unmanaged = 1;
>;
#endif

#else // defined(SUPPORT_RECOLORING)

static const bool HasRecolorColors = 0;
static const float3 RecolorColor = float3(0, 0, 0);

#endif // defined(SUPPORT_RECOLORING)

float OpacityOverride
<
	bool unmanaged = 1;
> = 1.0;

float3 TintColor
<
	string UIName = "Tint Color"; 
    string UIWidget = "Color";
> = float3(1, 1, 1);

float3 EyePosition
<
	string UIName = "Tint Color"; 
    string UIWidget = "Color";
>;

// ----------------------------------------------------------------------------
// Transformations (world transformations are in skinning header)
// ----------------------------------------------------------------------------
float4x4 View : View;
float4x3 ViewI : ViewInverse;

#if defined(_WW3D_)
float4x4 ViewProjection
<
	string UIWidget = "None";
	string SasBindAddress = "Sas.Camera.WorldToProjection";
>;

float4x4 GetViewProjection()
{
	return ViewProjection;
}
#else
float4x4 Projection : Projection;

float4x4 GetViewProjection()
{
	return mul(View, Projection);
}
#endif

//---

// float4 WorldBones[128]
// <
// 	bool unmanaged = 1;
// >;

// ----------------------------------------------------------------------------
// Shadow mapping
// ----------------------------------------------------------------------------
int HasShadow
<
	string UIWidget = "None";
	string SasBindAddress = "Sas.HasShadow";
>;

// DELETE THIS
ShadowSetup ShadowInfo
<
	string UIWidget = "None";
	string SasBindAddress = "Sas.Shadow[0]";
>;

SAMPLER_2D_SHADOW( ShadowMap )

// ----------------

float4 Shadowmap_Zero_Zero_OneOverMapSize_OneOverMapSize
<
	string UIWidget = "None";
	string SasBindAddress = "Sas.Shadow[0].Zero_Zero_OneOverMapSize_OneOverMapSize";
>;

float2 MapCellSize
<
	string UIWidget = "None";
	string SasBindAddress = "Terrain.Map.CellSize";
> = float2(10, 10);

SAMPLER_2D_BEGIN( MacroSampler,
	string Texture = "MacroSampler";
	string UIWidget = "None";
	string SasBindAddress = "Terrain.MacroTexture";
	string ResourceName = "ShaderPreviewMacro.dds";
	)
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
SAMPLER_2D_END

int _SasGlobal : SasGlobal 
<
	string UIWidget = "None";
	int3 SasVersion = int3(1, 0, 0);
	int MaxLocalLights = 8;
	int MaxSupportedInstancingMode = 1;
>;

// ----------------------------------------------------------------------------
// Skinning
// ----------------------------------------------------------------------------
static const int MaxSkinningBonesPerVertex = 1;

#include "Skinning.fxh"

// MAPS

SAMPLER_2D_BEGIN( CloudTexture,
	string UIWidget = "None";
	string SasBindAddress = "Terrain.Cloud.Texture";
	string ResourceName = "ShaderPreviewCloud.dds";
	)
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
SAMPLER_2D_END

// ----------------------------------------------------------------------------
// Environment map
// ----------------------------------------------------------------------------
#if defined(SPECIFY_CUSTOM_ENVMAP)
SAMPLER_CUBE_BEGIN( EnvironmentTexture,
	string UIName = "Reflection Texture";
	)
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Clamp;
	AddressV = Clamp;
	AddressW = Clamp;
SAMPLER_CUBE_END
#else
SAMPLER_CUBE_BEGIN( EnvironmentTexture,
	string Texture = "EnvironmentTexture";
	string UIWidget = "None";
	string SasBindAddress = "Objects.LightSpaceEnvironmentMap";
	string ResourceType = "Cube";
	)
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Clamp;
	AddressV = Clamp;
	AddressW = Clamp;
SAMPLER_CUBE_END
#endif

// ----------------------------------------------------------------------------
// Editable parameters
// ----------------------------------------------------------------------------
SAMPLER_2D_BEGIN( DiffuseTexture,
	string Texture = "DiffuseTexture";
	string UIName = "Diffuse Texture";
	)
	MinFilter = MinFilterBest;
	MagFilter = MagFilterBest;
	MipFilter = MipFilterBest;
	MaxAnisotropy = 8;
    AddressU = Wrap;
    AddressV = Wrap;
SAMPLER_2D_END

SAMPLER_2D_BEGIN( NormalMap,
	string Texture = "NormalMap";
	string UIName = "Normal Texture";
	)
	MinFilter = MinFilterBest;
	MagFilter = MagFilterBest;
	MipFilter = MipFilterBest;
	MaxAnisotropy = 8;
    AddressU = Wrap;
    AddressV = Wrap;
SAMPLER_2D_END

#if defined(SUPPORT_SPECMAP)
SAMPLER_2D_BEGIN( SpecMap,
	string Texture = "SpecMap";
	string UIName = "Specular Map";
	)
	MinFilter = MinFilterBest;
	MagFilter = MagFilterBest;
	MipFilter = MipFilterBest;
	MaxAnisotropy = 8;
    AddressU = Wrap;
    AddressV = Wrap;
SAMPLER_2D_END
#endif

#if defined(SUPPORT_RECOLORING)

#endif // if defined(SUPPORT_RECOLORING) && !defined(SCROLL_HOUSECOLOR)

#if defined(OBJECTS_ALIEN)
// Fixed material parameters for Aliens
static const float BumpScale = 1.5;
static const float3 AmbientColor = float3(1.0, 1.0, 1.0);
static const float4 DiffuseColor = float4(1.0, 1.0, 1.0, 1.0);
static const float3 SpecularColor = float3(0.788, 0.761, 1.0);
static const float SpecularExponent = 15.0;

#elif defined(MATERIAL_PARAMS_GDI)
// Fixed material parameters for GDI
static const float BumpScale = 1.5;
static const float3 AmbientColor = float3(0.1, 0.1, 0.1);
static const float4 DiffuseColor = float4(1.0, 1.0, 1.0, 0);
static const float3 SpecularColor = float3(1.0, 1.0, 1.0);
static const float SpecularExponent = 50.0;

#elif defined(MATERIAL_PARAMS_NOD)
// Fixed material parameters for NOD
static const float BumpScale = 1.5;
static const float3 AmbientColor = float3(0.3, 0.3, 0.3);
static const float4 DiffuseColor = float4(0.584, 0.624, 0.733, 1.0);
static const float3 SpecularColor = float3(1.0, 1.0, 1.0);
static const float SpecularExponent = 50.0;

#else
// Material parameters defined by UI
float BumpScale
<
	string UIName = "Bump Height"; 
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 10.0;
    float UIStep = 0.1;
> = 1.0;

float3 AmbientColor
<
	string UIName = "Ambient Color"; 
    string UIWidget = "Color";
> = float3(0.4, 0.4, 0.4);

float4 DiffuseColor
<
	string UIName = "Diffuse Color"; 
    string UIWidget = "Color";
> = float4(1.0, 1.0, 1.0, 1.0);

float3 SpecularColor
<
	string UIName = "Specular Color"; 
    string UIWidget = "Color";
> = float3(0.8, 0.8, 0.8);

float SpecularExponent
<
	string UIName = "Specular Exponent"; 
    string UIWidget = "Slider";
	float UIMax = 200.0f;
	float UIMin = 0;
	float UIStep = 1.0f;
> = 50.0;

#endif // Material parameters defined by UI

#if defined(SUPPORT_SPECMAP)

float EnvMult
<
	string UIName = "Reflection Multiplier"; 
    string UIWidget = "Slider";
	float UIMax = 1.0f;
	float UIMin = 0;
	float UIStep = 0.01f;
> = 1.0;
#endif

bool AlphaTestEnable
<
	string UIName = "Alpha Test Enable";
> = false;

// ----------------------------------------------------------------------------
// Shroud
// ----------------------------------------------------------------------------
ShroudSetup Shroud
<
	string UIWidget = "None";
	string SasBindAddress = "Terrain.Shroud";
> = DEFAULT_SHROUD;

// DELETE THIS
int ObjectShroudStatus
<
	string UIWidget = "None";
	string SasBindAddress = "Terrain.Shroud.ObjectShroudStatus";
> = OBJECTSHROUD_INVALID;

SAMPLER_2D_BEGIN( ShroudTexture,
	string UIWidget = "None";
	string SasBindAddress = "Terrain.Shroud.Texture";
	)
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
SAMPLER_2D_END

// ----------------------------------------------------------------------------
// Utility functions
// ----------------------------------------------------------------------------

float Time : Time;

// ----------------------------------------------------------------------------
// SHADER: DEFAULT
// ----------------------------------------------------------------------------
struct VSOutput {

	float4 Position : POSITION;
	float4 TexCoord0_TexCoord1 : TEXCOORD0;
	float4 LightVector[NumDirectionalLightsPerPixel] : TEXCOORD1_centroid;
	float4 HalfEyeLightVector : TEXCOORD4_centroid;
	float4 ReflectVector : TEXCOORD5_centroid;
	float4 ShadowMapTexCoord : TEXCOORD6;
	float4 Color : COLOR0;

#if defined(SUPPORT_BUILDUP)
	float2 BuildupWarpTexCoord : TEXCOORD3;
#endif

#ifdef PER_PIXEL_POINT_LIGHT
	float3 WorldPosition : TEXCOORD7;
#endif
};

// ----------------------------------------------------------------------------
// SHADER: VS
// ----------------------------------------------------------------------------
VSOutput VS(VSInputSkinningOneBoneTangentFrame InSkin, 
		float2 TexCoord : TEXCOORD0,
		uniform int numJointsPerVertex)
{
	USE_DIRECTIONAL_LIGHT_INTERACTIVE(DirectionalLight, 0);

	VSOutput Out;

	float3 worldPosition = 0;
	float3 worldNormal = 0;
	float3 worldTangent = 0;
	float3 worldBinormal = 0;

	CalculatePositionAndTangentFrame(InSkin, numJointsPerVertex,
		worldPosition, worldNormal, worldTangent, worldBinormal);
	
	// transform position to projection space
	Out.Position = mul(float4(worldPosition, 1), GetViewProjection());
	
	// Compute view direction in world space
	float3 worldEyeDir = normalize(ViewI[3] - worldPosition);

	// Build 3x3 tranform from object to tangent space
	float3x3 worldToTangentSpace = transpose(float3x3(-worldBinormal, -worldTangent, worldNormal));

	for (int i = 0; i < NumDirectionalLightsPerPixel; i++)
	{
		// Compute lighting direction in tangent space
		Out.LightVector[i] = float4(mul(DirectionalLight[i].Direction, worldToTangentSpace), 0);
	}

	// Compute half direction between view and light direction in tangent space
	Out.HalfEyeLightVector.xyz = normalize(mul(DirectionalLight[0].Direction + worldEyeDir, worldToTangentSpace));
	Out.ReflectVector.xyz = worldEyeDir;

	Out.Color = float4(AmbientLightColor * AmbientColor, OpacityOverride);


	// Compute remaining directional lights per vertex, others will be done in pixel shader
	float3 diffuseLight = 0;
	for (int i = NumDirectionalLightsPerPixel; i < NumDirectionalLights; i++)
	{
		diffuseLight += DirectionalLight[i].Color * max(0, dot(worldNormal, DirectionalLight[i].Direction));
	}

#if defined(SUPPORT_POINT_LIGHTS)
	// Compute point lights
	for (int i = 0; i < NumPointLights; i++)
	{
		float3 direction = PointLight[i].Position - worldPosition;
		float lightDistance = length(direction);
		direction /= lightDistance;
		
		float attenuation = CalculatePointLightAttenuation(PointLight[i], lightDistance);
		
		diffuseLight += PointLight[i].Color * attenuation * max(0, dot(worldNormal, direction));
	}
#endif

	Out.Color.xyz += diffuseLight * DiffuseColor;

	Out.Color /= 2; // Prevent clamping in interpolator

	// pass texture coordinates for fetching the diffuse and normal maps
	Out.TexCoord0_TexCoord1.xy = TexCoord.xy;

	// Hack cloud tex coord into final components of light vectors
	float2 cloudTexCoord = CalculateCloudTexCoord(Cloud, worldPosition, Time);
	Out.LightVector[0].w = cloudTexCoord.x;
	Out.LightVector[1].w = cloudTexCoord.y;

	float2 texCoord1 = TexCoord;

	Out.TexCoord0_TexCoord1.zw = texCoord1.yx;
	
	Out.ShadowMapTexCoord = CalculateShadowMapTexCoord(ShadowInfo, worldPosition);
	
	float2 shroudTexCoord = CalculateShroudTexCoord(Shroud, worldPosition);
	Out.HalfEyeLightVector.w = shroudTexCoord.x;
	Out.ReflectVector.w = shroudTexCoord.y;
	
	// Calculate fog
	// Out.Fog = CalculateFog(Fog, worldPosition, ViewI[3]);

	return Out;
}

// ----------------------------------------------------------------------------
// SHADER: VS_Xenon
// ----------------------------------------------------------------------------
VSOutput VS_Xenon(VSInputSkinningOneBoneTangentFrame InSkin, 
		float2 TexCoord : TEXCOORD0
#if defined(SUPPORT_BUILDUP)
		, float2 BuildupTexCoord : TEXCOORD1
#endif
		)
{
	return VS( InSkin,
		TexCoord,
#if defined(SUPPORT_BUILDUP)
		BuildupTexCoord,
#endif
		min(NumJointsPerVertex, 1) );
}

// ----------------------------------------------------------------------------
// SHADER: PS
// ----------------------------------------------------------------------------
float4 PS(VSOutput In, uniform int HasShadow, uniform bool applyShroud,
	uniform bool fogEnabled, uniform bool recolorEnabled) : COLOR
{
	float2 texCoord0 = In.TexCoord0_TexCoord1.xy;
	float2 texCoord1 = In.TexCoord0_TexCoord1.wz;
	float2 cloudTexCoord = float2(In.LightVector[0].w, In.LightVector[1].w);

	// Get diffuse color
	float4 baseTexture = tex2D( SAMPLER(DiffuseTexture), texCoord0);
	float3 diffuse = baseTexture.xyz * DiffuseColor;


#if defined(OBJECTS_ALIEN)
	float time = Time * 0.2;
#endif

	// Get bump map normal
	float3 bumpNormal = (float3)tex2D( SAMPLER(NormalMap), texCoord0) * 2.0 - 1.0;

	// Scale normal to increase/decrease bump effect
	bumpNormal.xy *= BumpScale;
	bumpNormal = normalize(bumpNormal);
	
	float4 color = In.Color * baseTexture * 2;

	float3 specularColor = SpecularColor;

#if defined(SUPPORT_SPECMAP)
	// Read spec map
	float4 specTexture = tex2D( SAMPLER(SpecMap), texCoord0);
	float specularStrength = specTexture.x;  // Specular lighting mask
	float reflectionStrength = specTexture.y; // Reflection/env map mask
	float selfIlluminationStrength = specTexture.z; 

#if defined(OBJECTS_ALIEN)
	// Envmap calculations
	float3 Nn = normalize(worldNormal + bumpNormal);
	float3 Vn = /*normalize*/(In.ReflectVector);
	float3 reflVect = -reflect(Vn,Nn);
	float3 envcolor = tex2D( SAMPLER(EnvironmentTexture), reflVect.y + time);

#if defined(SUPPORT_IONHULL)
	envcolor *= reflectionStrength * SpecularColor * 12;
#else
	envcolor *= EnvMult * reflectionStrength * SpecularColor * 6;

	specularColor = 3.0 * SpecularColor * specularStrength;
#endif // ION_HULL

#else // !OBJECTS_ALIEN
	// Envmap calculations
	float3 Nn = normalize(bumpNormal * 0.5);
	float3 Vn = /*normalize*/(In.ReflectVector);
	float3 reflVect = -reflect(Vn,Nn);
	float3 envcolor = EnvMult * texCUBE( SAMPLER(EnvironmentTexture), reflVect).xyz;
	
	color.xyz += envcolor * reflectionStrength * SpecularColor;

	specularColor = 3.0 * SpecularColor * specularStrength;
#endif // !OBJECTS_ALIEN

#endif // SUPPORT_SPECMAP

	for (int i = 0; i < NumDirectionalLightsPerPixel; i++)
	{
		// Compute lighting
        float3 lightVec = In.LightVector[i].xyz;
        float3 halfVec  = In.HalfEyeLightVector.xyz;

        float4 diffuseTerm = dot( bumpNormal, lightVec );
        float4 specularTerm = dot( bumpNormal, halfVec );

		float4 lighting = lit( diffuseTerm, specularTerm, SpecularExponent );
			
		if (i == 0)
		{
			if (HasShadow >= 1)
			{
				lighting.yz *= shadow( SAMPLER(ShadowMap), In.ShadowMapTexCoord, ShadowInfo);
			}
			
			float3 cloud = float3(1, 1, 1);			
#if defined(_WW3D_) && !defined(_W3DVIEW_)
			cloud = tex2D( SAMPLER(CloudTexture), cloudTexCoord);
#endif

			color.xyz += DirectionalLight[0].Color * cloud
#if defined(OBJECTS_ALIEN)
				* envcolor
#endif
				* (diffuse * lighting.y + specularColor * lighting.z);
		}
		else 
		{
	    	color.xyz += DirectionalLight[i].Color * (diffuse * lighting.y);
		}
	}

#if defined(SUPPORT_IONHULL)
	float3 ionTexture1 = tex2D( SAMPLER(IonHullTexture), texCoord0 + time);
	float3 ionTexture2 = tex2D( SAMPLER(IonHullTexture), (texCoord0 * 2) + time);
	color.xyz += ionTexture1.xyz * ionTexture2.xyz * 3;
#endif
	
#if defined(SCROLL_HOUSECOLOR)
	float4 scrollTexture = tex2D( SAMPLER(ScrollingMaskTexture), texCoord1);
	selfIlluminationStrength *= scrollTexture.x;

	color.xyz += selfIlluminationStrength * RecolorColor * RecolorMultiplier * recolorEnabled;
#else // defined(SCROLL_HOUSECOLOR)

#if defined(SUPPORT_SPECMAP) && !defined(OBJECTS_ALIEN)
	color.xyz = lerp(color, baseTexture, selfIlluminationStrength);
#endif

#if defined(SUPPORT_RECOLORING)
	if (recolorEnabled)
	{
		// float4 recolorColor = tex2D( SAMPLER(RecolorTexture), texCoord0);
		// recolorColor.xyz *= RecolorColor;
#if defined(OBJECTS_ALIEN)
		color.xyz += selfIlluminationStrength * RecolorColor * alienPulse;
#else
		color.xyz = lerp(color.xyz, RecolorColor, selfIlluminationStrength);
#endif
	}
#endif //defined(SUPPORT_RECOLORING)
#endif // defined(SCROLL_HOUSECOLOR)

#if defined(SUPPORT_BUILDUP)
	float3 warpTexture = tex2D( SAMPLER(BuildUpMap), In.BuildupWarpTexCoord);
	float fadeTexture = tex2D( SAMPLER(BuildUpMap), texCoord1).w;
	float alphaThreshold = fadeTexture * OpacityOverride;

	color.xyz += (alphaThreshold <= 0.25) * warpTexture;
	clip(alphaThreshold - 0.21);
#endif

	if (fogEnabled)
	{
		// color.xyz = lerp(Fog.Color, color.xyz, In.Fog);
	}

	if (applyShroud)
	{
		color.xyz *= tex2D( SAMPLER(ShroudTexture), float2( In.HalfEyeLightVector.w, In.ReflectVector.w ) );
	}

	return color;
}


// ----------------------------------------------------------------------------
// SHADER: PS_Xenon
// ----------------------------------------------------------------------------
float4 PS_Xenon( VSOutput In ) : COLOR
{
	return PS( In, min(HasShadow, 1), (ObjectShroudStatus == OBJECTSHROUD_PARTIAL_CLEAR), 0, (HasRecolorColors > 0) );
}

// ----------------------------------------------------------------------------
// Arrays: Default
// ----------------------------------------------------------------------------
DEFINE_ARRAY_MULTIPLIER( VS_Multiplier_Final = 2 );

#define VS_NumJointsPerVertex \
	compile vs_3_0 VS(0), \
	compile vs_3_0 VS(1)

#if SUPPORTS_SHADER_ARRAYS
vertexshader VS_Array[VS_Multiplier_Final] =
{
	VS_NumJointsPerVertex
};
#endif

DEFINE_ARRAY_MULTIPLIER( PS_Multiplier_NumShadows = 1 );

#define PS_NumShadows(recolorEnabled) \
	compile ps_3_0 PS(0, false, false, recolorEnabled), \
	compile ps_3_0 PS(1, false, false, recolorEnabled)

DEFINE_ARRAY_MULTIPLIER( PS_Multiplier_RecolorEnabled = PS_Multiplier_NumShadows * 2 );
	
#define PS_RecolorEnabled \
	PS_NumShadows(false), \
	PS_NumShadows(true)

DEFINE_ARRAY_MULTIPLIER( PS_Multiplier_Final = PS_Multiplier_RecolorEnabled * 2 );

#if SUPPORTS_SHADER_ARRAYS
pixelshader PS_Array[PS_Multiplier_Final] =
{
	PS_RecolorEnabled
};
#endif

// ----------------------------------------------------------------------------
// Technique: Default
// ----------------------------------------------------------------------------
technique Default
<
	int MaxSkinningBones = MaxSkinningBones;
>
{
	pass p0
	<
		USE_EXPRESSION_EVALUATOR("Objects")
	>
	{
		VertexShader = ARRAY_EXPRESSION_VS( VS_Array,
			min(NumJointsPerVertex, 1), 
			compile VS_VERSION VS_Xenon() );

		PixelShader = ARRAY_EXPRESSION_PS( PS_Array,
			min(HasShadow, 1) * PS_Multiplier_NumShadows
			+ (HasRecolorColors > 0) * PS_Multiplier_RecolorEnabled,
			compile PS_VERSION PS_Xenon() );

		ZEnable = true;
		ZFunc = ZFUNC_INFRONT;
		ZWriteEnable = true;
		CullMode = CW;

#if !EXPRESSION_EVALUATOR_ENABLED		
		AlphaBlendEnable = ( OpacityOverride < 0.99);
		AlphaTestEnable = ( AlphaTestEnable );
#endif

		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;

		AlphaFunc = GreaterEqual;
		AlphaRef = DEFAULT_ALPHATEST_THRESHOLD;

	}
}
#if ENABLE_LOD

// ----------------------------------------------------------------------------
// SHADER: VS_M
// ----------------------------------------------------------------------------
struct VSOutput_M
{
	float4 Position : POSITION;
	float3 Color : TEXCOORD1; // Allows strong overbrightness
	float2 TexCoord0 : TEXCOORD0;
	float3 LightVector : TEXCOORD2;
	float3 HalfEyeLightVector : TEXCOORD3;
	float2 ShroudTexCoord : TEXCOORD4;
	float2 CloudTexCoord : TEXCOORD5;
	float2 TexCoord1 : TEXCOORD6;
#if defined(OBJECTS_ALIEN)
	float AlienPulse : TEXCOORD7;
#endif
};

VSOutput_M VS_M(VSInputSkinningOneBoneTangentFrame InSkin,
		float2 TexCoord : TEXCOORD0,
#if defined(SUPPORT_BUILDUP)
		float2 BuildupTexCoord : TEXCOORD1,
#endif
		uniform int numJointsPerVertex)
{
	USE_DIRECTIONAL_LIGHT_INTERACTIVE(DirectionalLight, 0);

	VSOutput_M Out;

	float3 worldPosition = 0;
	float3 worldNormal = 0;
	float3 worldTangent = 0;
	float3 worldBinormal = 0;

	CalculatePositionAndTangentFrame(InSkin, numJointsPerVertex, worldPosition, worldNormal, worldTangent, worldBinormal);

	// transform position to projection space
	Out.Position = mul(float4(worldPosition, 1), GetViewProjection());

	// Compute view direction in world space
	float3 worldEyeDir = normalize(ViewI[3] - worldPosition);
	
	// Build 3x3 tranform from object to tangent space
	float3x3 worldToTangentSpace = transpose(float3x3(-worldBinormal, -worldTangent, worldNormal));

	// Compute lighting direction in tangent space
	Out.LightVector = mul(DirectionalLight[0].Direction, worldToTangentSpace);

	// Compute half angle direction between light and view direction in tangent space
	Out.HalfEyeLightVector = normalize(mul(DirectionalLight[0].Direction + worldEyeDir, worldToTangentSpace));

	float3 diffuseLight = 0;
	// Compute light 1 and up diffuse per vertex, light 0 will be done in pixel shader
	for (int i = 1; i < NumDirectionalLights; i++)
	{
		diffuseLight += DirectionalLight[i].Color * max(0, dot(worldNormal, DirectionalLight[i].Direction));
	}

#if defined(SUPPORT_POINT_LIGHTS)
	// Compute point lights
	for (int i = 0; i < NumPointLights; i++)
	{
		float3 direction = PointLight[i].Position - worldPosition;
		float lightDistance = length(direction);
		direction /= lightDistance;	
		float attenuation = CalculatePointLightAttenuation(PointLight[i], lightDistance);	
		diffuseLight += PointLight[i].Color * attenuation * max(0, dot(worldNormal, direction));
	}
#endif

	Out.Color = AmbientLightColor * AmbientColor + diffuseLight * DiffuseColor;
	Out.TexCoord0 = TexCoord.xy;
	Out.ShroudTexCoord = CalculateShroudTexCoord(Shroud, worldPosition);
	Out.CloudTexCoord = CalculateCloudTexCoord(Cloud, worldPosition, Time);
	
#if defined(SCROLL_HOUSECOLOR)
	Out.TexCoord1 = TexCoord * TexCoordTransform_0.xy + Time * TexCoordTransform_0.zw;
#elif defined(SUPPORT_BUILDUP)
	Out.TexCoord1 = BuildupTexCoord;
#else
	Out.TexCoord1 = TexCoord;
#endif

	// Alien pulse factor
#if defined(OBJECTS_ALIEN)
	Out.AlienPulse = CalculateAlienPulseFactor();
#endif
		
	// Out.Fog = CalculateFog(Fog, worldPosition, ViewI[3]);
	
	return Out;
}

// ----------------------------------------------------------------------------
// Shader: PS_M
// ----------------------------------------------------------------------------
float4 PS_M(VSOutput_M In, uniform bool applyShroud, uniform bool fogEnabled, uniform bool recolorEnabled) : COLOR
{
	// Get diffuse color
	float4 baseTexture = tex2D( SAMPLER(DiffuseTexture), In.TexCoord0);

	// Get bump map normal
	float3 bumpNormal = (float3)tex2D(SAMPLER(NormalMap), In.TexCoord0) * 2.0 - 1.0;
	// Scale normal to increase/decrease bump effect
	bumpNormal.xy *= BumpScale;
	bumpNormal = normalize(bumpNormal);
	//bumpNormal = float3(0, 0, 1);

	float3 specularColor = SpecularColor;

#if defined(SUPPORT_SPECMAP)
	float4 specTexture = tex2D(SAMPLER(SpecMap), In.TexCoord0);
	float specularStrength = specTexture.x;  // Specular lighting mask
	
#if defined(SUPPORT_RECOLORING)
	if (recolorEnabled)
	{
		float HouseColorStrength = specTexture.z;
		baseTexture.xyz += HouseColorStrength * (baseTexture.xyz * RecolorColor * 2 - baseTexture.xyz);
	}
#endif

	specularColor = 3.0 * SpecularColor * specularStrength;
#endif

	float3 diffuse = baseTexture.xyz;

	// Sample cloud texture
	float3 cloud = float3(1, 1, 1);			
#if defined(_WW3D_) && !defined(_W3DVIEW_)
	cloud = tex2D( SAMPLER(CloudTexture), In.CloudTexCoord);
#endif

	// Compute lighting
	float4 lighting = lit(dot(bumpNormal, In.LightVector), dot(bumpNormal, In.HalfEyeLightVector), SpecularExponent);
	
	float4 color;	
	color.xyz = In.Color * diffuse;
	color.xyz += DirectionalLight[0].Color * cloud * (diffuse * DiffuseColor * lighting.y + specularColor * lighting.z);

	if (fogEnabled)
	{
		// color.xyz = lerp(Fog.Color, color.xyz, In.Fog);
	}

	color.xyz *= tex2D( SAMPLER(ShroudTexture), In.ShroudTexCoord);

	color.a = baseTexture.w * OpacityOverride;
	
	return color;
}

// ----------------------------------------------------------------------------
// Arrays: Default_M
// ----------------------------------------------------------------------------
DEFINE_ARRAY_MULTIPLIER( VS_M_Multiplier_Final = 2 );

#define VS_M_NumJointsPerVertex \
	compile VS_VERSION_HIGH VS_M(0), \
	compile VS_VERSION_HIGH VS_M(1)

#if SUPPORTS_SHADER_ARRAYS
vertexshader VS_M_Array[VS_M_Multiplier_Final] =
{
	VS_M_NumJointsPerVertex
};
#endif

// ----------------------------------------------------------------------------
// Replace Shroud with Shadowmap
// ----------------------------------------------------------------------------

DEFINE_ARRAY_MULTIPLIER( PS_M_Multiplier_ApplyShroud = 1 );

#define PS_M_ApplyShroud(fogEnabled, recolorEnabled) \
	compile PS_VERSION_HIGH PS_M(true, fogEnabled, recolorEnabled)

DEFINE_ARRAY_MULTIPLIER( PS_M_Multiplier_FogEnabled = 1 * PS_M_Multiplier_ApplyShroud );

#define PS_M_FogEnabled(recolorEnabled) \
	PS_M_ApplyShroud(false, recolorEnabled), \
	PS_M_ApplyShroud(true, recolorEnabled)

DEFINE_ARRAY_MULTIPLIER( PS_M_Multiplier_RecolorEnabled = 2 * PS_M_Multiplier_FogEnabled );

#define PS_M_RecolorEnabled \
	PS_M_FogEnabled(false), \
	PS_M_FogEnabled(true)

DEFINE_ARRAY_MULTIPLIER( PS_M_Multiplier_Final = 2 * PS_M_Multiplier_RecolorEnabled );

#if SUPPORTS_SHADER_ARRAYS
pixelshader PS_M_Array[PS_M_Multiplier_Final] =
{
	PS_M_RecolorEnabled
};
#endif


// ----------------------------------------------------------------------------
// Technique: Default_M
// ----------------------------------------------------------------------------
technique _Default_M
<
	int MaxSkinningBones = MaxSkinningBones;
>
{
	pass p0
	<
		USE_EXPRESSION_EVALUATOR("Objects")
	>
	{
		VertexShader = ARRAY_EXPRESSION_VS( VS_M_Array,
			min(NumJointsPerVertex, 1),
			NO_ARRAY_ALTERNATIVE);
			
		PixelShader = ARRAY_EXPRESSION_PS( PS_M_Array,
			(ObjectShroudStatus == OBJECTSHROUD_PARTIAL_CLEAR) * PS_M_Multiplier_ApplyShroud
			+ Fog.IsEnabled * PS_M_Multiplier_FogEnabled
			+ (HasRecolorColors > 0) * PS_M_Multiplier_RecolorEnabled,
			NO_ARRAY_ALTERNATIVE);

		ZEnable = true;
		ZFunc = ZFUNC_INFRONT;
		ZWriteEnable = true;
		CullMode = CW;
		
		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;
				
		AlphaFunc = GreaterEqual;
		AlphaRef = DEFAULT_ALPHATEST_THRESHOLD;

#if !EXPRESSION_EVALUATOR_ENABLED				
		AlphaBlendEnable = ( OpacityOverride < 0.99);
		AlphaTestEnable = ( AlphaTestEnable );
#endif

	}
}

// ----------------------------------------------------------------------------
// SHADER: VS_L
// ----------------------------------------------------------------------------
struct VSOutput_L
{
	float4 Position : POSITION;
	float4 Color_Opacity : COLOR0;
	float4 BaseTexCoord : TEXCOORD0;
	float2 ShroudTexCoord : TEXCOORD1;
};

VSOutput_L VS_L(VSInputSkinningOneBoneTangentFrame InSkin, float2 TexCoord : TEXCOORD0, float4 VertexColor : COLOR0,
	uniform int numJointsPerVertex)
{
	USE_DIRECTIONAL_LIGHT_INTERACTIVE(DirectionalLight, 0);

	VSOutput_L Out;

	float3 worldPosition = 0;
	float3 worldNormal = 0;
	float3 worldTangent = 0;
	float3 worldBinormal = 0;

	CalculatePositionAndTangentFrame_L(InSkin, numJointsPerVertex, worldPosition, worldNormal, worldTangent, worldBinormal);

	// transform position to projection space
	Out.Position = mul(float4(worldPosition, 1), GetViewProjection());

	// Compute directional lights
	float3 diffuseLight = 0;
	for (int i = 0; i < NumDirectionalLights; i++)
	{
		float3 lightColor = DirectionalLight[i].Color;

		diffuseLight += lightColor * max(0, dot(worldNormal, DirectionalLight[i].Direction));
	}
	
	Out.Color_Opacity.xyz = AmbientLightColor * AmbientColor + diffuseLight * DiffuseColor;
	VertexColor.w *= GetFirstBonePosition(InSkin.BlendIndices, numJointsPerVertex).w;
	Out.Color_Opacity.w = OpacityOverride;
	Out.Color_Opacity *= VertexColor;
	Out.BaseTexCoord = TexCoord.xyyx;
	Out.ShroudTexCoord = CalculateShroudTexCoord(Shroud, worldPosition);

	return Out;
}

// ----------------------------------------------------------------------------
// SHADER: PS_L
// ----------------------------------------------------------------------------
float4 PS_L(VSOutput_L In, uniform bool recolorEnabled) : COLOR
{

	// Get diffuse color
	float4 baseTexture = tex2D(SAMPLER(DiffuseTexture), In.BaseTexCoord);

#if defined(SUPPORT_SPECMAP) && defined(SUPPORT_RECOLORING)
	if (recolorEnabled)
	{
		float4 specTexture = tex2D(SAMPLER(SpecMap), In.BaseTexCoord);
		float HouseColorStrength = specTexture.z;
		baseTexture.xyz += HouseColorStrength * (baseTexture.xyz * RecolorColor * 2 - baseTexture.xyz);
	}
#endif

	float3 color = baseTexture.xyz * In.Color_Opacity.xyz * TintColor;

	color.xyz *= tex2D(SAMPLER(ShroudTexture), In.ShroudTexCoord);

	return float4(color, baseTexture.w * In.Color_Opacity.w);
}

// ----------------------------------------------------------------------------
// Technique: Default_L
// Low LOD technique. Doesn't do any normal mapping.
// ----------------------------------------------------------------------------

#define VS_L_NumJointsPerVertex \
	compile VS_VERSION_LOW VS_L(0), \
	compile VS_VERSION_LOW VS_L(1)

#if SUPPORTS_SHADER_ARRAYS
vertexshader VS_L_Array[2] =
{
	VS_L_NumJointsPerVertex
};
#endif

#define PS_L_RecolorEnabled \
	compile PS_VERSION_LOW PS_L(0), \
	compile PS_VERSION_LOW PS_L(1)

#if SUPPORTS_SHADER_ARRAYS
pixelshader PS_L_Array[2] =
{
	PS_L_RecolorEnabled
};
#endif


// ----------------------------------------------------------------------------
technique _Default_L
<
	int MaxSkinningBones = MaxSkinningBones_L;
>
{
	pass p0
	<
		USE_EXPRESSION_EVALUATOR("Objects")
	>
	{
		VertexShader = ARRAY_EXPRESSION_VS( VS_L_Array,
			min(NumJointsPerVertex, 1),
			NO_ARRAY_ALTERNATIVE );
			
		PixelShader = ARRAY_EXPRESSION_PS( PS_L_Array,
			(ObjectShroudStatus == OBJECTSHROUD_PARTIAL_CLEAR) * PS_L_Multiplier_ApplyShroud
			+ (HasRecolorColors > 0) * PS_L_Multiplier_RecolorEnabled,
			NO_ARRAY_ALTERNATIVE );
			
		ZEnable = true;
		ZFunc = ZFUNC_INFRONT;
		ZWriteEnable = true;
		CullMode = CW;
		
		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;
		
		AlphaFunc = GreaterEqual;
		AlphaRef = DEFAULT_ALPHATEST_THRESHOLD;

#if !EXPRESSION_EVALUATOR_ENABLED	
		AlphaBlendEnable = ( OpacityOverride < 0.99);
		AlphaTestEnable = ( AlphaTestEnable );
#endif

	}
}

#endif // ENABLE_LOD

// ----------------------------------------------------------------------------
// SHADER: CreateShadowMapVS
// ----------------------------------------------------------------------------
struct VSOutput_CreateShadowMap
{
	float4 Position : POSITION;
	float2 TexCoord0 : TEXCOORD0;
#if defined(SUPPORT_BUILDUP)
	float2 TexCoord1 : TEXCOORD2;
#endif
	float Depth : TEXCOORD1;
	float Color : COLOR;
};

// ----------------------------------------------------------------------------
VSOutput_CreateShadowMap CreateShadowMapVS(VSInputSkinningOneBoneTangentFrame InSkin,
	float2 TexCoord : TEXCOORD0,
	float4 VertexColor : COLOR,
	uniform int numJointsPerVertex)
{
	VSOutput_CreateShadowMap Out;

	float3 worldPosition = 0;
	float3 worldNormal = 0;
	float3 worldTangent = 0;
	float3 worldBinormal = 0;

	CalculatePositionAndTangentFrame(InSkin, numJointsPerVertex,
		worldPosition, worldNormal, worldTangent, worldBinormal);

	// Transform position to projection space
	Out.Position = mul(float4(worldPosition, 1), GetViewProjection());	
	Out.Depth = Out.Position.z / Out.Position.w;	
	Out.TexCoord0 = TexCoord;	

	VertexColor.w *= GetFirstBonePosition(InSkin.BlendIndices, numJointsPerVertex).w;
	Out.Color = VertexColor.w * OpacityOverride;

	return Out;
}

// ----------------------------------------------------------------------------
float4 CreateShadowMapPS(VSOutput_CreateShadowMap In, uniform bool alphaTestEnable): COLOR
{

	float opacity = tex2D(SAMPLER(DiffuseTexture), In.TexCoord0).w * In.Color;	
	if (alphaTestEnable)
	{
		// Simulate alpha testing for floating point render target
		clip(opacity - ((float)DEFAULT_ALPHATEST_THRESHOLD / 255));
	}
	return In.Depth;
}

// ----------------------------------------------------------------------------
// SHADER: CreateShadowMapVS_Xenon
// ----------------------------------------------------------------------------
VSOutput_CreateShadowMap CreateShadowMapVS_Xenon(VSInputSkinningOneBoneTangentFrame InSkin,
		float2 TexCoord : TEXCOORD0,
		float VertexColor: COLOR
		)
{
	return CreateShadowMapVS( InSkin,
		TexCoord,
		VertexColor,
		min(NumJointsPerVertex, 1) );
}

// ----------------------------------------------------------------------------
float4 CreateShadowMapPS_Xenon(VSOutput_CreateShadowMap In) : COLOR
{
	return CreateShadowMapPS(In, AlphaTestEnable);
}

// ----------------------------------------------------------------------------
// Technique _CreateShadowMap
// ----------------------------------------------------------------------------
#define VSCreateShadowMap_NumJointsPerVertex \
	compile vs_2_0 CreateShadowMapVS(0), \
	compile vs_2_0 CreateShadowMapVS(1)

#if SUPPORTS_SHADER_ARRAYS
vertexshader VSCreateShadowMap_Array[2] =
{
	VSCreateShadowMap_NumJointsPerVertex
};
#endif

#define PSCreateShadowMap_AlphaTestEnable \
	compile ps_2_0 CreateShadowMapPS(false), \
	compile ps_2_0 CreateShadowMapPS(true)

#if SUPPORTS_SHADER_ARRAYS
pixelshader PSCreateShadowMap_Array[2] =
{
	PSCreateShadowMap_AlphaTestEnable
};
#endif

// ----------------------------------------------------------------------------
technique _CreateShadowMap
{
	pass p0
	<
		USE_EXPRESSION_EVALUATOR("Objects_CreateShadowMap")
	>
	{
		VertexShader = ARRAY_EXPRESSION_VS( VSCreateShadowMap_Array,
			min(NumJointsPerVertex, 1),
			compile VS_VERSION CreateShadowMapVS_Xenon() );
			
		PixelShader = ARRAY_EXPRESSION_PS( PSCreateShadowMap_Array,
			AlphaTestEnable,
			compile PS_VERSION CreateShadowMapPS_Xenon() );

		ZEnable = true;
		ZFunc = ZFUNC_INFRONT;
		ZWriteEnable = true;
		CullMode = CW;
		
		AlphaBlendEnable = false;
		AlphaTestEnable = false;
	}
}

