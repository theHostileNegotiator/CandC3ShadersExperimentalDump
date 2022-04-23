//////////////////////////////////////////////////////////////////////////////
// ©2005 Electronic Arts Inc
//
// Definitions of functions and global variables for skinning
//
// Before including this header, define the number of bone matrices the shader
// is to support. This is limited by the number of free vertex shader constant
// registers.
//
// Declare this:
//
// static const int MaxSkinningBonesPerVertex = 2;	// Number of bones per vertex supported (1 or 2)
// static const int MaxSkinningBones = 80;			// Number of bones supported on >= VS2.0 hardware
// static const int MaxSkinningBones_L = 32;		// Number of bones supported on VS1.1 hardware
//
//////////////////////////////////////////////////////////////////////////////

#ifndef _SKINNING_FXH_
#define _SKINNING_FXH_

//
// Global uploaded constants
//

int _SasGlobal : SasGlobal 
<
	string UIWidget = "None";
	int3 SasVersion = int3(1, 0, 0);
	int MaxLocalLights = 8;
	int MaxSupportedInstancingMode = 1;
>;

int NumJointsPerVertex
<
	string UIWidget = "None";
	string SasBindAddress = "Sas.Skeleton.NumJointsPerVertex";
> = 0;

#if defined(USE_NON_SKINNING_WORLD_MATRIX)

float4x3 World : World : register(c124);

#endif

//
// Functions/structs for calculating the skinning with multiple bones, but without tangent frame
//

struct VSInputSkinningMultipleBones
{
	float3 Position0 : POSITION0;
	float3 Position1 : POSITION1;
	float3 Normal0 : NORMAL0;
	float3 Normal1 : NORMAL1;
	float4 BlendIndices : BLENDINDICES;
	float2 BlendWeights : BLENDWEIGHT;
};


void CalculatePositionAndNormal(VSInputSkinningMultipleBones InSkin, int NumJointsPerVertex, float4x3 World,
	out float3 WorldPosition, out float3 WorldNormal)
{
	if (NumJointsPerVertex > 1)
	{
		float2 blendIndices = D3DCOLORtoUBYTE4(InSkin.BlendIndices).xy;
		int index = blendIndices.x * 2;

		WorldPosition = BoneTransformPosition(WorldBones[index], WorldBones[index+1], InSkin.Position0) * InSkin.BlendWeights.x;
		WorldNormal = BoneTransformDirection(WorldBones[index], InSkin.Normal0) * InSkin.BlendWeights.x;
		index = blendIndices.y * 2;
		WorldPosition += BoneTransformPosition(WorldBones[index], WorldBones[index+1], InSkin.Position1) * InSkin.BlendWeights.y;
		WorldNormal += BoneTransformDirection(WorldBones[index], InSkin.Normal1) * InSkin.BlendWeights.y;
		WorldNormal = normalize(WorldNormal);
	}
	else if (NumJointsPerVertex > 0)
	{
		float boneIndex = D3DCOLORtoUBYTE4(InSkin.BlendIndices).x;
	
		int index = (int)boneIndex;

		index *= 2;

		WorldPosition = BoneTransformPosition(WorldBones[index], WorldBones[index+1], InSkin.Position0);
		WorldNormal = normalize(BoneTransformDirection(WorldBones[index], InSkin.Normal0));
	}
	else
	{
#if defined(USE_NON_SKINNING_WORLD_MATRIX)
		WorldPosition = mul(float4(InSkin.Position0, 1), World);
		WorldNormal = normalize(mul(InSkin.Normal0, (float3x3)World));
#else
		WorldPosition = BoneTransformPosition(WorldBones[0], InSkin.Position0);
		WorldNormal = normalize(BoneTransformDirection(WorldBones[0], InSkin.Normal0));
#endif
	}
}

// Low profile version of function above, copy-and-pasted then replaced WorldBones by WorldBones_L. Sorry has to be ugly.
// void CalculatePositionAndNormal_L(VSInputSkinningMultipleBones InSkin, int NumJointsPerVertex,
	// out float3 WorldPosition, out float3 WorldNormal)
// {
	// if (NumJointsPerVertex > 1)
	// {
		// float2 blendIndices = D3DCOLORtoUBYTE4(InSkin.BlendIndices).xy;

		// int index = (int)blendIndices.x * 2;
		// WorldPosition = BoneTransformPosition(WorldBones_L[index], WorldBones_L[index+1], InSkin.Position0) * InSkin.BlendWeights.x;
		// WorldNormal = BoneTransformDirection(WorldBones_L[index], InSkin.Normal0) * InSkin.BlendWeights.x;
		// index = (int)blendIndices.y * 2;
		// WorldPosition += BoneTransformPosition(WorldBones_L[index], WorldBones_L[index+1], InSkin.Position1) * InSkin.BlendWeights.y;
		// WorldNormal += BoneTransformDirection(WorldBones_L[index], InSkin.Normal1) * InSkin.BlendWeights.y;
		// WorldNormal = normalize(WorldNormal);
	// }
	// else if (NumJointsPerVertex > 0)
	// {
		// float boneIndex = D3DCOLORtoUBYTE4(InSkin.BlendIndices).x;
	
		// int index = (int)boneIndex;

		// index *= 2;

		// WorldPosition = BoneTransformPosition(WorldBones_L[index], WorldBones_L[index+1], InSkin.Position0);
		// WorldNormal = normalize(BoneTransformDirection(WorldBones_L[index], InSkin.Normal0));
	// }
	// else
	// {
// #if defined(USE_NON_SKINNING_WORLD_MATRIX)
		// WorldPosition = mul(float4(InSkin.Position0, 1), World);
		// WorldNormal = normalize(mul(InSkin.Normal0, (float3x3)World));
// #else
		// WorldPosition = BoneTransformPosition(WorldBones_L[0], InSkin.Position0);
		// WorldNormal = normalize(BoneTransformDirection(WorldBones_L[0], InSkin.Normal0));
// #endif
	// }
// }




//
// Functions/structs for calculating the skinning with just one, but with a tangent frame
//

struct VSInputSkinningOneBoneTangentFrame
{
	float3 Position : POSITION;
	float3 Normal : NORMAL;
	float3 Tangent : TANGENT;
	float3 Binormal : BINORMAL;
	float4 BlendIndices : BLENDINDICES;
};


void CalculatePositionAndTangentFrame(VSInputSkinningOneBoneTangentFrame InSkin, int NumJointsPerVertex, float4x3 World,
	out float3 WorldPosition, out float3 WorldNormal, out float3 WorldTangent, out float3 WorldBinormal)
{
	if (NumJointsPerVertex > 0)
	{
		int index = InSkin.BlendIndices.x * 2;

		WorldPosition = BoneTransformPosition(WorldBones[index], WorldBones[index+1], InSkin.Position);
		WorldNormal = BoneTransformDirection(WorldBones[index], InSkin.Normal);
		WorldTangent = BoneTransformDirection(WorldBones[index], InSkin.Tangent);
		WorldBinormal = BoneTransformDirection(WorldBones[index], InSkin.Binormal);
		// Note: re-normalization skipped as quaternion-based BoneTransform can't do scaling anyway
	}
	else
	{
#if defined(USE_NON_SKINNING_WORLD_MATRIX)
		WorldPosition = mul(float4(InSkin.Position, 1), World);
		WorldNormal = mul(InSkin.Normal, (float3x3)World);
		WorldTangent = mul(InSkin.Tangent, (float3x3)World);
		WorldBinormal = mul(InSkin.Binormal, (float3x3)World);
#else
		WorldPosition = BoneTransformPosition(WorldBones[0], WorldBones[0+1], InSkin.Position);
		WorldNormal = BoneTransformDirection(WorldBones[0], InSkin.Normal);
		WorldTangent = BoneTransformDirection(WorldBones[0], InSkin.Tangent);
		WorldBinormal = BoneTransformDirection(WorldBones[0], InSkin.Binormal);
		// Note: re-normalization skipped as quaternion-based BoneTransform can't do scaling anyway
#endif
	}
}




// void CalculatePositionAndTangentFrame_L(VSInputSkinningOneBoneTangentFrame InSkin, uniform int NumJointsPerVertex,
	// out float3 WorldPosition, out float3 WorldNormal, out float3 WorldTangent, out float3 WorldBinormal)
// {
	// if (NumJointsPerVertex > 0)
	// {
		// int index = InSkin.BlendIndices.x * 2;

		// WorldPosition = BoneTransformPosition(WorldBones_L[index], WorldBones_L[index+1], InSkin.Position);
		// WorldNormal = BoneTransformDirection(WorldBones_L[index], InSkin.Normal);
		// WorldTangent = BoneTransformDirection(WorldBones_L[index], InSkin.Tangent);
		// WorldBinormal = BoneTransformDirection(WorldBones_L[index], InSkin.Binormal);

		// // Note: re-normalization skipped as quaternion-based BoneTransform can't do scaling anyway
	// }
	// else
	// {
// #if defined(USE_NON_SKINNING_WORLD_MATRIX)
		// WorldPosition = mul(float4(InSkin.Position, 1), World);
		// WorldNormal = mul(InSkin.Normal, (float3x3)World);
		// WorldTangent = mul(InSkin.Tangent, (float3x3)World);
		// WorldBinormal = mul(InSkin.Binormal, (float3x3)World);
// #else
		// WorldPosition = BoneTransformPosition(WorldBones_L[0], WorldBones_L[0+1], InSkin.Position);
		// WorldNormal = BoneTransformDirection(WorldBones_L[0], InSkin.Normal);
		// WorldTangent = BoneTransformDirection(WorldBones_L[0], InSkin.Tangent);
		// WorldBinormal = BoneTransformDirection(WorldBones_L[0], InSkin.Binormal);
		// // Note: re-normalization skipped as quaternion-based BoneTransform can't do scaling anyway
// #endif
	// }
// }


float4 GetFirstBonePosition(float4 BlendIndices, int NumJointsPerVertex, float4x3 World)
{
	if (NumJointsPerVertex > 0)
	{
		int index = BlendIndices.x;

		return WorldBones[index*2+1];
	}
	else
	{
#if defined(USE_NON_SKINNING_WORLD_MATRIX)
		return float4(World[3], 1);
#else
		return WorldBones[0+1];
#endif
	}
}

// float4 GetFirstBonePosition_L(float4 BlendIndices, int NumJointsPerVertex)
// {
	// if (NumJointsPerVertex > 0)
	// {
		// int index = BlendIndices.x;

		// return WorldBones_L[index*2+1];
	// }
	// else
	// {
// #if defined(USE_NON_SKINNING_WORLD_MATRIX)
		// return float4(World[3], 1);
// #else
		// return WorldBones_L[0+1];
// #endif
	// }
// }


#endif // Include guard
