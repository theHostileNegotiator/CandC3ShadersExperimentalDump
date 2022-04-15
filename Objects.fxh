//////////////////////////////////////////////////////////////////////////////
// ©2006 Electronic Arts Inc
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
	sampler2D samplerName##Sampler \
	< \
		string Texture = ("%s", #samplerName); \
		annotations \
	> = sampler_state \
	{ \
		Texture = < samplerName >;
		
#define SAMPLER_2D_END	};

#define SAMPLER( samplerName )	samplerName##Sampler

#define SAMPLER_CUBE_BEGIN(samplerName, annotations) \
	texture samplerName \
	< \
		annotations \
	>; \
	samplerCUBE samplerName##Sampler \
	< \
		string Texture = ("%s", #samplerName); \
		annotations \
	> = sampler_state \
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

static const bool HasRecolorColors = false;
static const float3 RecolorColor = float3(0, 0, 0);

float3 RecolorColorDummy
<
	bool unmanaged = 1;
>;

#endif // defined(SUPPORT_RECOLORING)

float4x4 ShadowMapWorldToShadow
<
	bool unmanaged = 1;
>;

float OpacityOverride
<
	bool unmanaged = 1;
> = 1.0;

float3 TintColor
<
	bool unmanaged = 1;
> = float3(1, 1, 1);

float3 EyePosition
<
	bool unmanaged = 1;
>;

// ----------------------------------------------------------------------------
// Transformations (world transformations are in skinning header)
// ----------------------------------------------------------------------------

#if defined(_WW3D_)
float4x4 ViewProjection
<
	bool unmanaged = 1;
>;

float4x4 GetViewProjection()
{
	return ViewProjection;
}
#else
float4x4 View : View;
float4x3 ViewI : ViewInverse;

float4x4 Projection : Projection;

float4x4 GetViewProjection()
{
	return mul(View, Projection);
}
#endif

// ----------------------------------------------------------------------------
// Skinning
// ----------------------------------------------------------------------------
static const int MaxSkinningBonesPerVertex = 1;

#include "Skinning.fxh"

// ----------------------------------------------------------------------------
// Shadow mapping
// ----------------------------------------------------------------------------
bool HasShadow
<
	string UIWidget = "None";
	string SasBindAddress = "Sas.HasShadow";
>;

SAMPLER_2D_SHADOW( ShadowMap )

float4 Shadowmap_Zero_Zero_OneOverMapSize_OneOverMapSize
<
	string UIWidget = "None";
	string SasBindAddress = "Sas.Shadow[0].Zero_Zero_OneOverMapSize_OneOverMapSize";
>;

// ----------------

float2 MapCellSize
<
	string UIWidget = "None";
	string SasBindAddress = "Terrain.Map.CellSize";
> = float2(10, 10);

SAMPLER_2D_BEGIN( MacroSampler,
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

// MAPS

//
// Global uploaded constants
//

int NumJointsPerVertex
<
	string UIWidget = "None";
	string SasBindAddress = "Sas.Skeleton.NumJointsPerVertex";
> = 0;

#if defined(USE_NON_SKINNING_WORLD_MATRIX)

float4x3 World : World;

#endif

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
// Fixed material parameters for Allies
static const float BumpScale = 1.5;
static const float3 AmbientColor = float3(0.1, 0.1, 0.1);
static const float4 DiffuseColor = float4(1.0, 1.0, 1.0, 0);
static const float3 SpecularColor = float3(0.8, 0.8, 0.8);
static const float SpecularExponent = 50.0;

#elif defined(MATERIAL_PARAMS_NOD)
// Fixed material parameters for Soviets
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
struct VSOutput_H {

	float4 Position : POSITION; //Correct
	float4 TexCoord0_TexCoord1 : TEXCOORD0; //Correct
	float3 LightVector[NumDirectionalLightsPerPixel] : TEXCOORD1_centroid;
	// float3 TexCoord2 : TEXCOORD2;
	float3 HalfEyeLightVector : TEXCOORD3_centroid;
	float3 ReflectVector : TEXCOORD4; //Correct
	float4 ShadowMapTexCoord : TEXCOORD5; //Correct
	float4 ShroudTexCoord : TEXCOORD6; //Correct
	float4 Color : COLOR0; //Correct

#ifdef PER_PIXEL_POINT_LIGHT
	float3 WorldPosition : TEXCOORD7;
#endif
};

// ----------------------------------------------------------------------------
// SHADER: VS_H
// ----------------------------------------------------------------------------
VSOutput_H VS_H(VSInputSkinningOneBoneTangentFrame InSkin, 
		float2 TexCoord : TEXCOORD0,
		float4 VertexColor : COLOR0,
		uniform int numJointsPerVertex)
{
	USE_DIRECTIONAL_LIGHT_INTERACTIVE(DirectionalLight, 0);

	VSOutput_H Out;

	float3 worldPosition = 0;
	float3 worldNormal = 0;
	float3 worldTangent = 0;
	float3 worldBinormal = 0;

	CalculatePositionAndTangentFrame(InSkin, numJointsPerVertex, World,
		worldPosition, worldNormal, worldTangent, worldBinormal);
	
	// transform position to projection space
	Out.Position = mul(float4(worldPosition, 1), GetViewProjection());
	
	// Compute view direction in world space
	float3 worldEyeDir = normalize(EyePosition - worldPosition);

	// Build 3x3 tranform from object to tangent space
	float3x3 worldToTangentSpace = transpose(float3x3(-worldBinormal, -worldTangent, worldNormal));

	for (int i = 0; i < NumDirectionalLightsPerPixel; i++)
	{
		// Compute lighting direction in tangent space
		Out.LightVector[i] = float3(mul(DirectionalLight[i].Direction, worldToTangentSpace));
	}

	// Compute half direction between view and light direction in tangent space
	Out.HalfEyeLightVector = normalize(mul(DirectionalLight[0].Direction + worldEyeDir, worldToTangentSpace));
	Out.ReflectVector = worldPosition;

	// Compute remaining directional lights per vertex, others will be done in pixel shader
	float3 diffuseLight = 0;
	for (int i = NumDirectionalLightsPerPixel; i < NumDirectionalLights; i++)
	{
		diffuseLight += DirectionalLight[i].Color * max(0, dot(worldNormal, DirectionalLight[i].Direction));
	}

	Out.Color = float4(AmbientLightColor * AmbientColor, OpacityOverride);
	Out.Color.xyz += diffuseLight * DiffuseColor;
	VertexColor.w *= GetFirstBonePosition(InSkin.BlendIndices, numJointsPerVertex, World).w;
	Out.Color *= VertexColor;
	// pass texture coordinates for fetching the diffuse and normal maps
	Out.TexCoord0_TexCoord1.xyzw = TexCoord.xyyx;
	Out.ShadowMapTexCoord = CalculateShadowMapTexCoord(ShadowMapWorldToShadow, worldPosition);
	Out.ShroudTexCoord.xy = CalculateShroudTexCoord(Shroud, worldPosition);
	Out.ShroudTexCoord.zw = CalculateCloudTexCoord(Cloud, worldPosition, Time);
	
	return Out;
}

// ----------------------------------------------------------------------------
// SHADER: VS_Xenon
// ----------------------------------------------------------------------------
VSOutput_H VS_Xenon(VSInputSkinningOneBoneTangentFrame InSkin, 
		float2 TexCoord : TEXCOORD0,
		float4 VertexColor : COLOR
		)
{
	return VS_H( InSkin,
		TexCoord,
		VertexColor,
		min(NumJointsPerVertex, 1) );
}

// ----------------------------------------------------------------------------
// SHADER: PS_H
// ----------------------------------------------------------------------------
float4 PS_H(VSOutput_H In, uniform int HasShadow, uniform bool applyShroud,
	uniform bool fogEnabled, uniform bool recolorEnabled) : COLOR
{
	float2 texCoord0 = In.TexCoord0_TexCoord1.xy;
	float2 texCoord1 = In.TexCoord0_TexCoord1.wz;

	// Get diffuse color
	float4 baseTexture = tex2D( SAMPLER(DiffuseTexture), texCoord0);	

	baseTexture.xyz = exp2(log2(baseTexture.xyz) * 2.2);
	
#if defined(SUPPORT_SPECMAP)
	// Read spec map
	float4 specTexture = tex2D( SAMPLER(SpecMap), texCoord0);
	float specularStrength = specTexture.x;  // Specular lighting mask
	float reflectionStrength = specTexture.y; // Reflection/env map mask
#if defined(SUPPORT_RECOLORING)
	if (recolorEnabled)
	{
		float HouseColorStrength = specTexture.z;
		baseTexture.xyz += HouseColorStrength * (baseTexture.xyz * RecolorColor * 2 - baseTexture.xyz);
	}
#endif //defined(SUPPORT_RECOLORING)
#endif // SUPPORT_SPECMAP
	
	float3 diffuse = baseTexture.xyz * DiffuseColor;

	// Get bump map normal
	float3 bumpNormal = (float3)tex2D( SAMPLER(NormalMap), texCoord0) * 2.0 - 1.0;

	// Scale normal to increase/decrease bump effect
	bumpNormal.xy *= BumpScale;
	bumpNormal = float3(dot(bumpNormal.xyz, In.LightVector[0]), dot(bumpNormal.xyz, In.LightVector[1]), dot(bumpNormal.xyz, In.HalfEyeLightVector));
	bumpNormal = normalize(bumpNormal);
	
	float4 color;
	color.xyz = In.Color.xyz * baseTexture.xyz;

	float3 specularColor = SpecularColor;

#if defined(SUPPORT_SPECMAP)
	// Envmap calculations
	float3 Nn = bumpNormal;
	float3 Vn = normalize(EyePosition.xyz - In.ReflectVector);
	float3 reflVect = -reflect(Vn,Nn);
	float3 envcolor = texCUBE( SAMPLER(EnvironmentTexture), reflVect).xyz;
	
	// specularColor = SpecularColor * specularStrength;

#endif // SUPPORT_SPECMAP

	float2 cloudTexCoord = In.ShroudTexCoord.zw;
	
	color.xyz += DirectionalLight[0].Color * envcolor * specularStrength;
	
	for (int i = 0; i < NumDirectionalLightsPerPixel; i++)
	{
		// Compute lighting
        float3 lightVec = In.LightVector[i].xyz;
        float3 halfVec  = In.HalfEyeLightVector.xyz;

        float4 diffuseTerm = dot( bumpNormal, lightVec );
        float4 specularTerm = dot( bumpNormal, halfVec );

		float4 lighting = lit( diffuseTerm, specularTerm, SpecularExponent );
		
		float directionlight = max(dot(DirectionalLight[i].Direction, bumpNormal), 0);
		
		if (i == 0)
		{
			if (HasShadow)
			{
				lighting.yz *= shadow( SAMPLER(ShadowMap), In.ShadowMapTexCoord, Shadowmap_Zero_Zero_OneOverMapSize_OneOverMapSize);
			}
			
			float3 cloud = float3(1, 1, 1);			
#if defined(_WW3D_) && !defined(_W3DVIEW_)
			cloud = tex2D( SAMPLER(CloudTexture), cloudTexCoord);
			cloud.xyz = exp2(log2(cloud.xyz) * 2.2);
#endif

			color.xyz += DirectionalLight[0].Color * cloud * diffuse * directionlight;
		}
		else 
		{
			
	    	color.xyz += DirectionalLight[i].Color * diffuse * directionlight;
		}
	}

#if defined(SUPPORT_POINT_LIGHTS)
	// Compute point lights
	float3 temp;
	for (int i = 0; i < NumPointLights; i++)
	{
		float3 direction = PointLight[i].Position - In.ReflectVector;
		float lightDistance = length(direction);
		direction /= lightDistance;
		
		float attenuation = CalculatePointLightAttenuation(PointLight[i], lightDistance);
		
		// diffuseLight += PointLight[i].Color * attenuation * max(0, dot(worldNormal, direction));
		temp.xyz += PointLight[i].Color * attenuation * direction;
	}
	color.xyz += temp * diffuse;
#endif

	color.w = baseTexture.w * In.Color.w;

	color.xyz *= TintColor;

	color.xyz *= tex2D( SAMPLER(ShroudTexture), In.ShroudTexCoord.xy );

	return color;
}


// ----------------------------------------------------------------------------
// SHADER: PS_Xenon
// ----------------------------------------------------------------------------
float4 PS_Xenon( VSOutput_H In ) : COLOR
{
	return PS_H( In, min(HasShadow, 1), 0, 0, (HasRecolorColors > 0) );
}

// ----------------------------------------------------------------------------
// Arrays: Default
// ----------------------------------------------------------------------------
DEFINE_ARRAY_MULTIPLIER( VS_Multiplier_Final = 2 );

#define VS_NumJointsPerVertex \
	compile vs_3_0 VS_H(0), \
	compile vs_3_0 VS_H(1)

#if SUPPORTS_SHADER_ARRAYS
vertexshader VS_H_Array[VS_Multiplier_Final] =
{
	VS_NumJointsPerVertex
};
#endif

DEFINE_ARRAY_MULTIPLIER( PS_Multiplier_HasShadow = 1 );

#define PS_NumShadows(recolorEnabled) \
	compile ps_3_0 PS_H(false, false, false, recolorEnabled), \
	compile ps_3_0 PS_H(true, false, false, recolorEnabled)

DEFINE_ARRAY_MULTIPLIER( PS_Multiplier_RecolorEnabled = PS_Multiplier_HasShadow * 2 );
	
#define PS_RecolorEnabled \
	PS_NumShadows(false), \
	PS_NumShadows(true)

DEFINE_ARRAY_MULTIPLIER( PS_Multiplier_Final = PS_Multiplier_RecolorEnabled * 2 );

#if SUPPORTS_SHADER_ARRAYS
pixelshader PS_H_Array[PS_Multiplier_Final] =
{
	PS_RecolorEnabled
};
#endif

// ----------------------------------------------------------------------------
// Technique: Default
// ----------------------------------------------------------------------------
technique Default
{
	pass p0
	<
		USE_EXPRESSION_EVALUATOR("Objects")
	>
	{
		VertexShader = VS_H_Array[min(NumJointsPerVertex, 1)];
			
		PixelShader = PS_H_Array[HasRecolorColors * PS_Multiplier_RecolorEnabled + HasShadow * PS_Multiplier_HasShadow];

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
	float4 TexCoord0 : TEXCOORD0;
	float4 LightVector : TEXCOORD1_centroid;
	float3 HalfEyeLightVector : TEXCOORD2_centroid;
	float4 ShroudTexCoord : TEXCOORD3;
	float4 ShadowMapTexCoord : TEXCOORD4;
	float2 MapCellTexCoord : TEXCOORD5;
	float4 Color : COLOR;
};

VSOutput_M VS_M(VSInputSkinningOneBoneTangentFrame InSkin,
		float2 TexCoord : TEXCOORD0,
		float4 VertexColor : COLOR,
		uniform int numJointsPerVertex)
{
	USE_DIRECTIONAL_LIGHT_INTERACTIVE(DirectionalLight, 0);

	VSOutput_M Out;

	float3 worldPosition = 0;
	float3 worldNormal = 0;
	float3 worldTangent = 0;
	float3 worldBinormal = 0;

	CalculatePositionAndTangentFrame(InSkin, numJointsPerVertex, World, worldPosition, worldNormal, worldTangent, worldBinormal);

	// transform position to projection space
	Out.Position = mul(float4(worldPosition, 1), GetViewProjection());

	// Compute view direction in world space
	float3 worldEyeDir = normalize(EyePosition - worldPosition);
	
	// Build 3x3 tranform from object to tangent space
	float3x3 worldToTangentSpace = transpose(float3x3(-worldBinormal, -worldTangent, worldNormal));

	// Compute lighting direction in tangent space
	Out.LightVector = float4(mul(DirectionalLight[0].Direction, worldToTangentSpace), 0);

	// Compute half angle direction between light and view direction in tangent space
	Out.HalfEyeLightVector = normalize(mul(DirectionalLight[0].Direction + worldEyeDir, worldToTangentSpace));

	float3 diffuseLight = 0;
	// Compute light 1 and up diffuse per vertex, light 0 will be done in pixel shader
	for (int i = 1; i < NumDirectionalLights; i++)
	{
		diffuseLight += DirectionalLight[i].Color * max(0, dot(worldNormal, DirectionalLight[i].Direction));
	}

	Out.Color.xyz = AmbientLightColor * AmbientColor + diffuseLight * DiffuseColor;
	VertexColor.w *= GetFirstBonePosition(InSkin.BlendIndices, numJointsPerVertex, World).w;
	Out.Color.w = OpacityOverride;
	Out.Color *= VertexColor;
	Out.TexCoord0 = TexCoord.xyyx;
	Out.ShroudTexCoord.xy = CalculateShroudTexCoord(Shroud, worldPosition);
	Out.ShroudTexCoord.zw = CalculateCloudTexCoord(Cloud, worldPosition, Time);
	Out.ShadowMapTexCoord = CalculateShadowMapTexCoord(ShadowMapWorldToShadow, worldPosition);
	Out.MapCellTexCoord = float2(1, -1) * (worldPosition.xy / (MapCellSize.x * 66));
	
	return Out;
}

// ----------------------------------------------------------------------------
// Shader: PS_M
// ----------------------------------------------------------------------------
float4 PS_M(VSOutput_M In, uniform bool HasShadow, uniform bool recolorEnabled) : COLOR
{
	// Get diffuse color
	half4 baseTexture = tex2D( SAMPLER(DiffuseTexture), In.TexCoord0);
	
	half4 color;
	color.w = baseTexture.w * In.Color.w;

	half3 specularColor = SpecularColor;

#if defined(SUPPORT_SPECMAP)
	half4 specTexture = tex2D(SAMPLER(SpecMap), In.TexCoord0);
	half specularStrength = specTexture.x;  // Specular lighting mask
	
#if defined(SUPPORT_RECOLORING)
	if (recolorEnabled)
	{
		half HouseColorStrength = specTexture.z;
		baseTexture.xyz += HouseColorStrength * (baseTexture.xyz * RecolorColor * 2 - baseTexture.xyz);
	}
#endif
	specularColor *= specularStrength;
#endif

	color.xyz = baseTexture.xyz * In.Color.xyz;

	half3 diffuse = baseTexture.xyz * DiffuseColor;

	// Get bump map normal
	half3 bumpNormal = (half3)tex2D(SAMPLER(NormalMap), In.TexCoord0) * 2.0 - 1.0;
	// Scale normal to increase/decrease bump effect
	bumpNormal.xy *= BumpScale;
	bumpNormal = normalize(bumpNormal);

	// Compute lighting

	half3 lightVec = In.LightVector.xyz;
	half3 halfVec  = In.HalfEyeLightVector.xyz;

	half4 diffuseTerm = dot( bumpNormal, lightVec );
	half4 specularTerm = dot( bumpNormal, halfVec );

	half4 lighting = lit( diffuseTerm, specularTerm, SpecularExponent );

	if (HasShadow)
	{
		lighting.yz *= shadow( SAMPLER(ShadowMap), In.ShadowMapTexCoord, Shadowmap_Zero_Zero_OneOverMapSize_OneOverMapSize);
	}
	
	// Sample cloud texture
	half3 cloud = half3(1, 1, 1);			
#if defined(_WW3D_) && !defined(_W3DVIEW_)
	cloud = tex2D( SAMPLER(CloudTexture), In.ShroudTexCoord.zw);
#endif

	color.xyz += DirectionalLight[0].Color * cloud * (diffuse * lighting.y + specularColor * lighting.z);

	color.xyz *= TintColor;

	color.xyz *= tex2D( SAMPLER(ShroudTexture), In.ShroudTexCoord.xy);
	
	return color;
}

// ----------------------------------------------------------------------------
// Arrays: Default_M
// ----------------------------------------------------------------------------
#define VS_M_Multiplier_Final 2

#define VS_M_NumJointsPerVertex \
	compile VS_VERSION_HIGH VS_M(0), \
	compile VS_VERSION_HIGH VS_M(1)

#if SUPPORTS_SHADER_ARRAYS
vertexshader VS_M_Array[VS_M_Multiplier_Final] =
{
	VS_M_NumJointsPerVertex
};
#endif

#define PS_M_Multiplier_HasShadow 1

#define PS_M_HasShadows(recolorEnabled) \
	compile PS_VERSION_HIGH PS_M(false, recolorEnabled), \
	compile PS_VERSION_HIGH PS_M(true, recolorEnabled)

#define PS_M_Multiplier_RecolorEnabled (2*PS_M_Multiplier_HasShadow)

#define PS_M_RecolorEnabled \
	PS_M_HasShadows(false), \
	PS_M_HasShadows(true)

#define PS_M_Multiplier_Final (2*PS_M_Multiplier_RecolorEnabled)

#if SUPPORTS_SHADER_ARRAYS
pixelshader PS_M_Array[PS_M_Multiplier_Final] =
{
	PS_M_RecolorEnabled
};
#endif


// ----------------------------------------------------------------------------
// Technique: Default_M
// ----------------------------------------------------------------------------
technique Default_M
{
	pass p0
	<
		USE_EXPRESSION_EVALUATOR("Objects")
	>
	{
		VertexShader = VS_M_Array[min(NumJointsPerVertex, 1)];
			
		PixelShader = PS_M_Array[HasRecolorColors * PS_M_Multiplier_RecolorEnabled + HasShadow * PS_M_Multiplier_HasShadow];

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

	CalculatePositionAndTangentFrame(InSkin, numJointsPerVertex, World, worldPosition, worldNormal, worldTangent, worldBinormal);

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
	VertexColor.w *= GetFirstBonePosition(InSkin.BlendIndices, numJointsPerVertex, World).w;
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

#define VS_L_Multiplier_Final 2

#define VS_L_NumJointsPerVertex \
	compile VS_VERSION_LOW VS_L(0), \
	compile VS_VERSION_LOW VS_L(1)

#if SUPPORTS_SHADER_ARRAYS
vertexshader VS_L_Array[VS_L_Multiplier_Final] =
{
	VS_L_NumJointsPerVertex
};
#endif

#define PS_L_Multiplier_RecolorEnabled 1

#define PS_L_RecolorEnabled \
	compile PS_VERSION_LOW PS_L(0), \
	compile PS_VERSION_LOW PS_L(1)

#define PS_L_Multiplier_Final (2*PS_L_Multiplier_RecolorEnabled)

#if SUPPORTS_SHADER_ARRAYS
pixelshader PS_L_Array[PS_L_Multiplier_Final] =
{
	PS_L_RecolorEnabled
};
#endif


// ----------------------------------------------------------------------------
technique Default_L
{
	pass p0
	<
		USE_EXPRESSION_EVALUATOR("Objects")
	>
	{
		VertexShader = VS_L_Array[min(NumJointsPerVertex, 1)];
			
		PixelShader = PS_L_Array[HasRecolorColors * PS_L_Multiplier_RecolorEnabled];
			
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

	CalculatePositionAndTangentFrame(InSkin, numJointsPerVertex, World,
		worldPosition, worldNormal, worldTangent, worldBinormal);

	// Transform position to projection space
	Out.Position = mul(float4(worldPosition, 1), GetViewProjection());	
	Out.Depth = Out.Position.z / Out.Position.w;	
	Out.TexCoord0 = TexCoord;	

	VertexColor.w *= GetFirstBonePosition(InSkin.BlendIndices, numJointsPerVertex, World).w;
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

#define VSCreateShadowMap_Multiplier_Final 2

#define VSCreateShadowMap_NumJointsPerVertex \
	compile vs_2_0 CreateShadowMapVS(0), \
	compile vs_2_0 CreateShadowMapVS(1)

#if SUPPORTS_SHADER_ARRAYS
vertexshader VSCreateShadowMap_Array[VS_L_Multiplier_Final] =
{
	VSCreateShadowMap_NumJointsPerVertex
};
#endif

#define PSCreateShadowMap_Multiplier_AlphaTestEnable 1

#define PSCreateShadowMap_AlphaTestEnable \
	compile ps_2_0 CreateShadowMapPS(false), \
	compile ps_2_0 CreateShadowMapPS(true)

#define PSCreateShadowMap_Multiplier_Final (2*PSCreateShadowMap_Multiplier_AlphaTestEnable)

#if SUPPORTS_SHADER_ARRAYS
pixelshader PSCreateShadowMap_Array[PSCreateShadowMap_Multiplier_Final] =
{
	PSCreateShadowMap_AlphaTestEnable
};
#endif

// ----------------------------------------------------------------------------
technique _CreateShadowMap
{
	pass p0
	{
		VertexShader = VSCreateShadowMap_Array[min(NumJointsPerVertex, 1)];
			
		PixelShader = PSCreateShadowMap_Array[AlphaTestEnable];

		ZEnable = true;
		ZFunc = ZFUNC_INFRONT;
		ZWriteEnable = true;
		CullMode = CW;
		
		AlphaBlendEnable = false;
		AlphaTestEnable = false;
	}
}

