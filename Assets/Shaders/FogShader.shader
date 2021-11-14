//this one does not seem to be working...
//try this one out perhaps:
//https://halisavakis.com/my-take-on-shaders-vertical-fog/

Shader "Custom/Fog"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            //needed for fog variation to be compiled
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct vertexInput
            {
                float4 vertex   : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct fragmentInput
            {
                float4 position : SV_POSITION;
                float4 texcoord : TEXCOORD0;

                //used to pass fog amount using TEXCOORD1
                UNITY_FOG_COORDS(1)
            };


            sampler2D _MainTex;
            float4 _MainTex_ST;

            fragmentInput vert(vertexInput i)
            {
                fragmentInput o;
                o.position = UnityObjectToClipPos(i.vertex);
                o.texcoord = i.texcoord;

                //compute fox amount from clip space position
                UNITY_TRANSFER_FOG(o, o.position);
                return o;
            }

            fixed4 frag(fragmentInput i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.texcoord);

                //Apply fog (additive passes are automatically handled)
                UNITY_APPLY_FOG(i.fogCoord, color);
                UNITY_OPAQUE_ALPHA(color.a);

                return color;
            }

            ENDCG
        }
    }
}