//UNITY_SHADER_NO_UPGRADE

Shader "Custom/Face orientation"
{
    Properties
    {
        _ColorFront("Front color", Color) = (1, 0.7, 0.7, 1)
        _ColorBack("Back color", Color) = (0.7, 1, 0.7, 1)
    }

    SubShader
    {
        Pass
        {
            Cull Off //turn off backface culling
            //https://en.wikipedia.org/wiki/Back-face_culling

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0 //minimum version for VFACE semantic

            fixed4 _ColorFront;
            fixed4 _ColorBack;

            float4 vert(float4 vertex : POSITION) : SV_POSITION
            {
                return UnityObjectToClipPos(vertex);
            }

            fixed4 frag(fixed facing : VFACE) : SV_Target
            {
                //VFACE input positive for frontfaces
                //and negative for backfaces.
                return facing > 0 ? _ColorFront : _ColorBack;
            }

            ENDCG
        }
    }
}