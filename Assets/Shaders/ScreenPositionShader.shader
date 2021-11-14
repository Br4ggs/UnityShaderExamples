//UNITY_SHADER_NO_UPGRADE

Shader "Custom/Screen position"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0 //minimum version requires for VPOS pixel position

            //note that we do not use the SV_POSITION semantic
            struct v2f 
            {
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;

            //the out keyword specifies that the value, like pass by reference
            //will be written to and returned to the caller of the function
            //in this case it is send to the SV_POSITION semantic
            v2f vert
                (float4 vertex      : POSITION //vertex position input
                ,float2 uv          : TEXCOORD0 //texture coordinate input
                ,out float4 outpos  : SV_POSITION) //output vertex clip space position as separate output
            {
                v2f o;
                o.uv    = uv;
                outpos  = UnityObjectToClipPos(vertex);
                return o;
            }

            //the screenPos variable here is taken from the VPOS semantic
            fixed4 frag (v2f i, UNITY_VPOS_TYPE screenPos : VPOS) : SV_Target
            {
                //screenPos.xy will contain pixel integer coordinates
                //we use them to implement a checkerboard pattern
                //rendering 4x4 blocks of pixels

                //here we create our value that indicates whether a
                //pixel is visible or not
                //if it is negative it is part of the checker and will
                //be clipped

                //the first part screenPos * 0.25 creates a stepper
                //which increments to a new integer every 4 numbers (because of the floor)
                // 1 = 0
                // 2 = 0
                // 3 = 0
                // 4 = 1
                // ...
                //we then multiply by 0.5 to add a fraction to it:
                // 1  = 0
                // 2  = 0
                // 3  = 0
                // 4  = 0.5
                // 8  = 1
                // 12 = 1.5
                // ...
                //finally we take the fractional part of the 2 coordinates added up
                //and make it negative, then if that is negative we clip it
                //this causes all tiles with a fractional part to be clipped
                
                //note you screenPos.rg == screenPos.xy
                //https://zims-en.kiwix.campusafrica.gos.orange.com/wikibooks_en_all_maxi/A/Cg_Programming/Vector_and_Matrix_Operations
                //we also use .xy since those are the only coordinates we're
                //interested in
                screenPos.xy    = floor(screenPos * 0.25) * 0.5;
                float checker   = -frac(screenPos.x + screenPos.y);

                //clip pixel if its a negative checker value
                clip(checker);

                //for the remaining pixel we look up the texture coordinate
                //and output it
                fixed4 c = tex2D(_MainTex, i.uv);

                return c;
            }

            ENDCG
        }
    }
}
