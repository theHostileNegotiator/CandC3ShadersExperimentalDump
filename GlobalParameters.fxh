//////////////////////////////////////////////////////////////////////////////
// ©2006 Electronic Arts Inc
//
// Globals used in all shaders
//////////////////////////////////////////////////////////////////////////////

#include "RegisterMap.fxh"

string DefaultParameterScopeBlock = "material";

// ----------------------------------------------------------------------------
// Light sources
// ----------------------------------------------------------------------------
static const int NumDirectionalLights = 3;
static const int NumDirectionalLightsPerPixel = 2;

float3 AmbientLightColor : register(c4)
<
	bool unmanaged = 1;
> = float3(0.3, 0.3, 0.3);

SasDirectionalLight DirectionalLight[NumDirectionalLights] : register(c5)
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
#endif

SasPointLight PointLight[8] : register(c89)
<
	bool unmanaged = 1;
>;

// ----------------------------------------------------------------------------
// Cloud layer
// ----------------------------------------------------------------------------
CloudSetup Cloud : register(c117)
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

float3 RecolorColor : register(c0)
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

float4x4 ShadowMapWorldToShadow : register(c113)
<
	bool unmanaged = 1;
>;

float OpacityOverride : register(c1)
<
	bool unmanaged = 1;
> = 1.0;

float3 TintColor : register(c2)
<
	bool unmanaged = 1;
> = float3(1, 1, 1);

float3 EyePosition : register(c123)
<
	bool unmanaged = 1;
>;

// ----------------------------------------------------------------------------
// Transformations (world transformations are in skinning header)
// ----------------------------------------------------------------------------
#if defined(_WW3D_)
float4x4 ViewProjection : register(c119)
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
// World Bones
// ----------------------------------------------------------------------------
static const int MaxSkinningBones = 64;

//
// Defines
//

// Define the bone representation to use:
#define BONES_AS_QUATERNION_TRANSLATION	// Lowest per-bone data, but cannot represent scaling
//#define BONES_AS_FLOAT4X3				// Medium per-bone data, but still incompatible with DXSAS
//#define BONES_AS_MATRIX				// Highest per-bone data, but compatible with DXSAS

#if defined(BONES_AS_QUATERNION_TRANSLATION)
	// Define this to allow non-skinned objects to use full world matrices.
	// Useful if quaternion-translation mode is used for skinning,
	// as otherwise no object can have scaling
	#define USE_NON_SKINNING_WORLD_MATRIX
#endif

//
// Helper functions/structures
//

float3 Quaternion_RotateVector(float4 rotation, float3 position)
{
	float4 a;
	a = rotation.wwwx * position.xyzx + rotation.yzxy * position.zxyy;
	a.w = -a.w;
	a -= rotation.zxyz * position.yzxz;

	return rotation.www * a.xyz - rotation.xyz * a.www + rotation.yzx * a.zxy - rotation.zxy * a.yzx;
}


//
// Definition of the BoneTransform struct with accessor functions
//
#if defined(BONES_AS_QUATERNION_TRANSLATION)

	#define BoneTransform float4

//	struct BoneTransform;
//	{
//		float4 Rotation;
//		float4 Translation_Zero;
//	};
	
	float3 BoneTransformPosition(BoneTransform r, BoneTransform t, float3 position)
	{	
		return Quaternion_RotateVector(r, position) + t.xyz;
	}
	
	float3 BoneTransformDirection(BoneTransform r, float3 direction)
	{
		return Quaternion_RotateVector(r, direction);
	}

#else

	#if defined(BONES_AS_MATRIX)
	
		#define BoneTransform float4x3
		
		float4x3 GetBoneMatrix(BoneTransform b)
		{
			return b;
		}
	
	#else // defined(BONES_AS_FLOAT4X3)
	
		struct BoneTransform
		{
			float4 Rows[3];
		};
		
		float4x3 GetBoneMatrix(BoneTransform b)
		{
			return transpose(float3x4(b));
		}
	
	#endif
	
	float3 BoneTransformPosition(BoneTransform b, float3 position)
	{
		return mul(float4(position, 1), GetBoneMatrix(b));
	}
	
	float3 BoneTransformDirection(BoneTransform b, float3 direction)
	{
		return mul(direction, GetBoneMatrix(b));
	}

#endif

#if !defined(EA_PLATFORM_XENON)
BoneTransform WorldBones[MaxSkinningBones*2] : register(c128)
<
	bool unmanaged = 1;
>;
#else

shared BoneTransform WorldBones[MaxSkinningBones*2] : register(c0)
<
	string UIWidget = "None";
	string SasBindAddress = "Sas.Skeleton.MeshToJointToWorld[*]";
>;

shared BoneTransform WorldBones_L[MaxSkinningBones_L*2] : register(c0)
<
	string UIWidget = "None";
	string SasBindAddress = "Sas.Skeleton.MeshToJointToWorld[*]";
>;
#endif
