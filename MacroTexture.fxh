//////////////////////////////////////////////////////////////////////////////
// ©2006 Electronic Arts Inc
//
// 
//////////////////////////////////////////////////////////////////////////////

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
