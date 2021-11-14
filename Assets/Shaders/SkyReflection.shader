//UNITY_SHADER_NO_UPGRADE

Shader "Custom/Sky Reflection"
{
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
                half3 worldRefl : TEXCOORD0;
                float4 pos      : SV_POSITION;
            };

            v2f vert (float4 vertex : POSITION, float3 normal : NORMAL)
            {
                v2f o;
                o.pos               = UnityObjectToClipPos(vertex);
                float3 worldPos     = mul(unity_ObjectToWorld, vertex).xyz;
                //the function UnityWorldSpaceViewDir gets the world space view direction.
                //That is: A vector going from the camera's center to the specified point. This gives
                //a different vector for each fragment or pixel on screen.
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                //more info on transpose and inverses: https://www.math.hmc.edu/~dk/math40/math40-lect07.pdf

                //this function transforms the normal from object space to world space
                //the reason this is done with a separate function is to make sure
                //the normal isn't squashed due to any scaling transformations for example
                //source: https://paroj.github.io/gltut/Illumination/Tut09%20Normal%20Transformation.html#ftn.idp7907
                float3 worldNormal  = UnityObjectToWorldNormal(normal);
                //here we negate worldViewDir to get the correct angle, this is because reflect
                //calculates the reflection from the origin point, so in order to get the right
                //reflection we negate worldViewDir, which gives us the same line only with
                //the origin now in the correct position.
                //source: https://slidetodoc.com/presentation_image_h/04814022fd7cd3da49196f1bf1f7b765/image-21.jpg
                o.worldRefl         = reflect(-worldViewDir, worldNormal); // -worldViewDir?
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 skyData   = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.worldRefl);
                half3 skyColor  = DecodeHDR(skyData, unity_SpecCube0_HDR);
                fixed4 c        = 0;
                c.rgb           = skyColor;
                return c;
            }

            ENDCG
        }
    }
}