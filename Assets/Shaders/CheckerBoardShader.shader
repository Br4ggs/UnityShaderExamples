//UNITY_SHADER_NO_UPGRADE

Shader "Custom/Checkerboard"
{
    Properties
    {
        _Density ("Density", Range(2,50)) = 30
    }

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float _Density;

            v2f vert (float4 pos : POSITION, float2 uv : TEXCOORD0)
            {
                v2f o;
                o.vertex    = mul(UNITY_MATRIX_MVP, pos);
                o.uv        = uv * _Density;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 c = i.uv;
                //here we floor and divide by 2. This makes all values "quantized"
                //to values of 0, 0.5, 1, 1.5, and so on...
                c = floor(c) / 2;
                //the frac function takes a number as input and returns only the fractional
                //part, so for 1.5 the return value would be 0.5.
                //we then multiply the value by 2, so that we get either values of 0.0 or 1:
                //0.5 * 2 = 1
                //0.0 * 2 = 0
                float checker = frac(c.x + c.y) * 2;
                return checker;
            }

            ENDCG
        }
    }
}