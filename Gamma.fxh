//////////////////////////////////////////////////////////////////////////////
// ©2006 Electronic Arts Inc
//
// Code for Gamma Correction
//////////////////////////////////////////////////////////////////////////////

static const float gamma = 2.2;
static const float invgamma = 1/gamma;

float3 GammatoLinear(float3 colorgamma)
{
	return exp2(log2(colorgamma) * gamma);
}

float3 LineartoGamma(float3 colorlinear)
{
	return exp2(log2(colorlinear) * invgamma);
}

float3 FrameBuffertoGamma(float3 color)
{
	color = color * 6 * (color * 0.1666667 + 1);
	color /= (color * 6 + 1);
	return color;
}
