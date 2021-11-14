//UNITY_SHADER_NO_UPGRADE

Shader "Custom/Custom Lighting Ramp"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Ramp ("Ramp", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        CGPROGRAM
        #pragma surface surf Ramp
        
        //when defining your own light model, order of declaration is important
        //err... at least it is a little buggy

        sampler2D _MainTex;
        sampler2D _Ramp;

        //half4 is a shortened version of float4
        half4 LightingRamp (SurfaceOutput s, half3 lightDir, half atten)
        {
            half NdotL = dot(s.Normal, lightDir);
            half diff = NdotL * 0.5 + 0.5; // Is always between 0 And 1?
            half3 ramp = tex2D(_Ramp, float2(diff, 1.0)).rgb;
            half4 c;
            c.rgb = s.Albedo * ramp * atten;
            c.a = s.Alpha;

            return c;
        }

        struct Input
        {
            float2 uv_MainTex;
        };


        //inout basically means passing o through this function
        void surf (Input IN, inout SurfaceOutput o) 
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
        }

        ENDCG
    }
}
