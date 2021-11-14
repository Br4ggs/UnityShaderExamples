//UNITY_NO_UPGRADE
Shader "Custom/Vertex id"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5 //needed for SV_VertexID

            struct v2f
            {
                fixed4 color    : TEXCOORD0;
                float4 pos      : SV_POSITION;
            };

            v2f vert
                (float4 vertex : POSITION       //vertex position input
                ,uint vid       : SV_VertexID)  //vertex id input
            {
                v2f o;
                o.pos   = UnityObjectToClipPos(vertex);
                float f = (float)vid;
                o.color = half4(sin(f/10), sin(f/100), sin(f/1000), 0) * 0.5 + 0.5;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
            }

            ENDCG
        }
    }
}