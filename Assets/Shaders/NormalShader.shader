//UNITY_SHADER_NO_UPGRADE

Shader "Custom/Normal Shader"
{
    //what all those SV_ semantics mean:
    //https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-semantics

    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                half3 worldNormal   : TEXCOORD0;
                float4 pos          : SV_POSITION;
            };

            //TEXCOORD0 is a so-called interpolator
            //the vertex shader is only runs for each vertex
            //while the fragment shader runs for every pixel
            //these interpolators basically handle the interpolation between the vectors (?)

            v2f vert (float4 vertex : POSITION, float3 normal : NORMAL)
            {
                v2f o;
                o.pos           = UnityObjectToClipPos(vertex);
                o.worldNormal   = UnityObjectToWorldNormal(normal);
                return o;
            }

            fixed4 frag (v2f input) : SV_Target
            {
                fixed4 c    = 0;
                c.rgb       = input.worldNormal * 0.5 + 0.5;
                return c;
            }

            ENDCG
        }
    }
}