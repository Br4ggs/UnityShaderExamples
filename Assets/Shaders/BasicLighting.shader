Shader "Custom/Basic lighting"
{
    Properties
    {
        //the [NoScaleOffset] disalows tiling offset and scale
        [NoScaleOffset] _MainTex("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Pass
        { 
            //here we indicate that this pass is the "base" pass in the forward
            //rendering pipeline: It gets ambient and main directional light data set up:
            //light direction in _WorldSpaceLightPos0 and color in _LightColor0
            //this will make directional light data be passed into our shader via some
            //build-in variables
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc" //required for UnityObjectToWorldNormal
            #include "UnityLightingCommon.cginc" //required for _LightColor0

            struct v2f
            {
                float2 uv       : TEXCOORD0;
                float4 diff     : COLOR0; //diffuse lighting color
                float4 vertex   : SV_POSITION;
            };

            sampler2D _MainTex;

            v2f vert (appdata_base v) //what is appdata_base?
            {
                v2f o;
                o.vertex            = UnityObjectToClipPos(v.vertex);
                o.uv                = v.texcoord;
                //get the vertex's normal in world space, for this we multiply by the inverse
                //transpose of the transformation matrix
                half3 worldNormal   = UnityObjectToWorldNormal(v.normal);
                //we use the dot product between the normal and the light direction to
                //get starndard diffuse (Lambert) lighting: https://en.wikipedia.org/wiki/Lambertian_reflectance
                //sidenote: in math the dot product is often denoted as a · b, where the dot refers to the
                //dot product: https://www.mathsisfun.com/algebra/vectors-dot-product.html
                //also useful to know: https://en.wikipedia.org/wiki/Law_of_cosines
                half nl             = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                //for a fun trick:  = abs(dot(worldNormal, _WorldSpaceLightPos0.xyz));
                //this will create a ring of shadow around the object, giving it some backlight!

                //factor in the light's color
                o.diff              = nl * _LightColor0;

                //in addition to the diffuse lighting from the main light,
                //add illumination from ambient or light probes
                //the ShadeSH9 function from UnityCG.cginc evaluates the ambient or light
                //probe light using our worldspace normal
                o.diff.rgb          += ShadeSH9(half4(worldNormal, 1));

                return o;   
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //sample texture
                fixed4 col  = tex2D(_MainTex, i.uv);
                //multiply by lighting
                col         *= i.diff;
                return col;
            }

            ENDCG
        }

        //tells shaderlab to use the legacy shadowcaster shader
        //as a separate
        //UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

        //heres a manual implementation
        Pass
        {
            Tags {"LightMode"="ShadowCaster"} //?

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            //multi_compile_shadowcaster tells the shader to be
            //compiled into several variants with different
            //preprocessor macros defined for each:
            //https://docs.unity3d.com/Manual/SL-MultipleProgramVariants.html
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }

            ENDCG
        }
    }
}