//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
// Parameters:
//
//   struct
//   {
//       float3 Color;
//       float3 Direction;
//
//   } DirectionalLight[3];
//   
//   float3 NoCloudMultiplier;
//   float Time;
//
//
// Registers:
//
//   Name              Reg   Size
//   ----------------- ----- ----
//   DirectionalLight  c0       1
//   NoCloudMultiplier c1       1
//   Time              c2       1
//
//
// Default values:
//
//   DirectionalLight
//     c0   = { 1.247, 1.207, 1.043, 0 };
//
//   NoCloudMultiplier
//     c1   = { 1, 1, 1, 0 };
//
//   Time
//     c2   = { 0, 0, 0, 0 };
//

    preshader
    mul c20.xyz, c0.xyz, c1.xyz
    mul c21.x, c2.x, (0.03)

// approximately 2 instructions used
//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
// Parameters:
//
//   float3 AmbientLightColor;
//   
//   struct
//   {
//       float3 Color;
//       float3 Direction;
//
//   } DirectionalLight[3];
//   
//   struct
//   {
//       float IsEnabled;
//       float4 Color;
//       float RangeStart;
//       float OneOverRangeDelta;
//
//   } Fog;
//   
//   float4x3 ViewI;
//   float4x3 World;
//   float4x4 WorldViewProjection;
//
//
// Registers:
//
//   Name                Reg   Size
//   ------------------- ----- ----
//   DirectionalLight    c0       6
//   Fog                 c6       4
//   WorldViewProjection c10      4
//   World               c14      3
//   ViewI               c17      3
//   AmbientLightColor   c22      1
//
//
// Default values:
//
//   DirectionalLight
//     c0   = { 1.247, 1.207, 1.043, 0 };
//     c1   = { 0.62914, -0.34874, 0.69465, 0 };
//     c2   = { 0.745, 0.831, 0.894, 0 };
//     c3   = { -0.32877, 0.90329, 0.27563, 0 };
//     c4   = { 0.69, 0.667, 0.69, 0 };
//     c5   = { -0.80704, -0.58635, 0.06975, 0 };
//
//   Fog
//     c6   = { 0, 0, 0, 0 };
//     c7   = { 1, 1, 1, 1 };
//     c8   = { 0, 0, 0, 0 };
//     c9   = { 0.001, 0, 0, 0 };
//
//   WorldViewProjection
//     c10  = { 0, 0, 0, 0 };
//     c11  = { 0, 0, 0, 0 };
//     c12  = { 0, 0, 0, 0 };
//     c13  = { 0, 0, 0, 0 };
//
//   World
//     c14  = { 0, 0, 0, 0 };
//     c15  = { 0, 0, 0, 0 };
//     c16  = { 0, 0, 0, 0 };
//
//   ViewI
//     c17  = { 0, 0, 0, 0 };
//     c18  = { 0, 0, 0, 0 };
//     c19  = { 0, 0, 0, 0 };
//
//   AmbientLightColor
//     c22  = { 0.3, 0.3, 0.3, 0 };
//

    vs_1_1
    def c23, 1, 0, 25, -0.5
    def c24, 0.337500006, 0.75, 0.524999976, 0.180141002
    def c25, 0.0208350997, -0.0851330012, -0.330299497, 0.999866009
    def c26, -2, 1.57079637, -3.14159274, 0.159155071
    dcl_position v0
    dcl_texcoord v1
    dcl_color v2
    mad r0, v0.xyzx, c23.xxxy, c23.yyyx
    dp4 r3.x, r0, c14
    dp4 r3.y, r0, c15
    dp4 r3.z, r0, c16
    mov r4.x, c17.w
    mov r4.y, c18.w
    mov r4.z, c19.w
    add r6.xyz, -r3, r4
    dp4 oPos.x, r0, c10
    dp3 r1.x, r6, r6
    dp4 oPos.y, r0, c11
    rsq r1.w, r1.x
    dp4 oPos.z, r0, c12
    mad r1.xyz, r6, r1.w, c3
    dp4 oPos.w, r0, c13
    dp3 r1.x, r1, r1
    mov r2.xyz, c23
    mad r0.xzw, c3.z, r2.xyyy, r2.yyzz
    rsq r2.w, r1.x
    add r3.xyz, r3, -r4
    mul r0.y, r1.z, r2.w
    lit r0, r0
    mad r1.xyz, r6, r1.w, c1
    mul r5.xyz, r0.y, c2
    dp3 r0.x, r1, r1
    mul r4.xyz, r0.z, c2
    rsq r0.w, r0.x
    mad r6.xyz, r6, r1.w, c5
    mul r0.y, r1.z, r0.w
    mad r0.xzw, c1.z, r2.xyyy, r2.yyzz
    dp3 r6.x, r6, r6
    lit r1, r0
    rsq r0.w, r6.x
    mul r0.y, r6.z, r0.w
    mad r0.xzw, c5.z, r2.xyyy, r2.yyzz
    mad r5.xyz, c20, r1.y, r5
    lit r0, r0
    mad r4.xyz, c20, r1.z, r4
    mad r1.xyz, c4, r0.y, r5
    mad r0.xyz, c4, r0.z, r4
    add r1.xyz, r1, c22
    mad r0.xyz, r0, c24, r1
    add r1.xy, v1, c23.w
    mul oD0.xyz, r0, v2
    max r0.xy, -r1, r1
    dp3 r3.x, r3, r3
    max r0.w, r0.y, r0.x
    rcp r2.w, r0.w
    min r0.w, r0.y, r0.x
    rsq r1.w, r3.x
    mul r0.w, r2.w, r0.w
    rcp r2.w, r1.w
    mul r1.w, r0.w, r0.w
    add r2.w, r2.w, -c8.x
    mad r3.w, r1.w, c25.x, c25.y
    mul r2.w, r2.w, c9.x
    mad r3.w, r1.w, r3.w, c24.w
    max r2.w, r2.w, c23.y
    mad r3.w, r1.w, r3.w, c25.z
    min r2.w, r2.w, c23.x
    mad r1.w, r1.w, r3.w, c25.w
    mad oD1.x, c6.x, -r2.w, r2.x
    mul r2.w, r0.w, r1.w
    slt r1.w, r0.y, r0.x
    mad r0.w, r2.w, c26.x, c26.y
    mad r1.w, r0.w, r1.w, r2.w
    slt r0.w, r1.y, -r1.y
    mad r3.w, r0.w, c26.z, r1.w
    min r0.w, r1.y, r1.x
    add r2.w, r3.w, r3.w
    slt r1.w, r0.w, -r0.w
    max r0.w, r1.y, r1.x
    mul r0.xy, r1, r1
    sge r4.w, r0.w, -r0.w
    add r0.w, r0.y, r0.x
    mul r1.w, r1.w, r4.w
    rsq r0.w, r0.w
    mad r1.w, r1.w, -r2.w, r3.w
    rcp r0.w, r0.w
    mul oT1.x, r1.w, c26.w
    add oT1.y, r0.w, -c21.x
    mov oD0.w, v2.w
    mov oT0.xy, v1

// approximately 83 instruction slots used

//
// Generated by Microsoft (R) D3DX9 Shader Compiler 9.08.299.0000
//
// Parameters:
//
//   struct
//   {
//       float IsEnabled;
//       float4 Color;
//       float RangeStart;
//       float OneOverRangeDelta;
//
//   } Fog;
//   
//   sampler2D GlowSamplerSampler;
//   sampler2D MaskSamplerSampler;
//
//
// Registers:
//
//   Name               Reg   Size
//   ------------------ ----- ----
//   Fog                c0       2
//   MaskSamplerSampler s0       1
//   GlowSamplerSampler s1       1
//
//
// Default values:
//
//   Fog
//     c0   = { 0, 0, 0, 0 };
//     c1   = { 1, 1, 1, 1 };
//

    ps_1_1
    def c2, 1, 0, 0, 0
    tex t0
    tex t1
    mul r0, t0, v0
    add r1.xyz, t1, r0
  + add r0.w, r0.w, r0.w
    dp3 t0.xyz, c2, v1
    lrp r0.xyz, t0, r1, c1

// approximately 6 instruction slots used (2 texture, 4 arithmetic)
