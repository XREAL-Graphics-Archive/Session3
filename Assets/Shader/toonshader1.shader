Shader "session3/toonshader1" 
{

Properties {
    
_Ambientcolor("Ambient color",color)=(0,0,0,0)
_LightWidth("Light Width",Range(0,255))=1
_LightStep("Light Step",Range(0,20))=10

}


SubShader 
{
Tags 
{
"RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry"
} 

Pass
{
Name "Universal Forward"

Tags {"LightMode" = "UniversalForward"}

HLSLPROGRAM
#pragma prefer_hlslcc gles
#pragma exclude_renderers d3d11_9x
#pragma vertex vert
#pragma fragment frag

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct VertexInput 
{
float4 vertex : POSITION;
float3 normal : NORMAL; 
};


struct VertexOutput
{
float4 vertex : SV_POSITION; 
float3 normal : NORMAL;
};


float4 _Ambientcolor;
float  _LightWidth;
float _LightStep;


VertexOutput vert(VertexInput v)
{
VertexOutput o;
o.vertex = TransformObjectToHClip(v.vertex.xyz); 
o.normal = TransformObjectToWorldNormal(v.normal);
return o; 

}


half4 frag(VertexOutput i) : SV_Target 
{

float4 color = float4(1,1,1,1);
    
float3 LightColor = _MainLightColor.rgb; 
float3 Light = _MainLightPosition.xyz;

float3 NdotL = saturate(dot( i.normal,Light));
    

    //계단식말고, 그냥 반으로만?
  //  float3 toonlight=NdotL>0 ? _MainLightColor.rgb: 0;
  // color.rgb *= toonlight;
    
float3 toonlight = ceil((NdotL) * _LightWidth) / _LightStep;
    toonlight=NdotL>0? toonlight : _Ambientcolor.rgb;
//float3 ambient = NdotL > 0 ? 0 : _Ambientcolor.rgb;
color.rgb *= toonlight*LightColor;

return color;
} 

ENDHLSL
} 
}


}