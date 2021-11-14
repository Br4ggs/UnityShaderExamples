//UNITY_SHADER_NO_UPGRADE

//https://docs.unity3d.com/Manual/SL-ShaderSemantics.html
//when writing HLSL shader programs, input and output variables
//need to have their "intent" indicated. This is done via
//semantics

Shader "Custom/Basic Vertex"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            //interpolators such as TEXCOORDn,
            //are used for interpolating the values between vertices
            //(in this case), there are limits to how many interpolators
            //can be used in total in a shader. This depends on the platform
            //and GPU, the minimum is up to 8 and the maximum is up to 32.
            //it is good practice to use as little interpolators
            //as possible for performance reasons.

            struct v2f
            {
                float2 uv   : TEXCOORD0;
                float4 pos  : SV_POSITION; //indicates that a vertex is to be outputted in clip space position
            };

            struct fragOutput
            {
                fixed4 color : SV_Target; //you can also specify the target semantic in a returned structure
            };

            v2f vert
                (float4 vertex :  POSITION   //POSITION semantic indicates vertex position
                ,float2 uv      : TEXCOORD0) //TEXCOORD0 semantix indicates texture coordinate
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, vertex);
                o.uv  = uv;

                return o;
            }

            fragOutput frag(v2f i) //SV_Target SV_Target semantic indicates this needs to be rendered to the screen
            {
                fragOutput o;
                o.color = fixed4(i.uv, 0, 0);
                return o;
            }

            //we can also indicate SV_Target1, SV_Target2, etc
            //as outputs

            //by using the SV_Depth semantic, we can override
            //the Z buffer value for that fragment, the output
            //for which needs to be a single float

            ENDCG
        }
    }
}
