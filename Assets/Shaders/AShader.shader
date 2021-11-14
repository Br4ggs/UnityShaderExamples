//this prevents unity from auto upgrading your shader
//UNITY_SHADER_NO_UPGRADE

//https://www.youtube.com/watch?v=3penhrrKCYg <-- source

Shader "Custom/AShader" //define a shader names AShader
{
	Properties //variables used by shader
	{
		//https://docs.unity3d.com/Manual/SL-Properties.html
		//variable name, in-editor name, type, default value
		_MainTexture("Main Texture", 2D) = "white" {}
		_Color("Main Color", Color) = (1,1,1,1)

		_DissolveTexture("Cheese Texture", 2D) = "white" {}
		_DissolveAmount("Cheese cutout amount", float) = 1

		_ExtrudeAmount("Extrude amount", float) = 1
	}

	SubShader //you can have multiple shaders divided up in separate subshaders!
	{
		Pass
		{
			CGPROGRAM //start writing CG code

			#pragma vertex vertexFunction //defining the vertex Function
			#pragma fragment fragmentFunction //defining the fragment Function

			#include "UnityCG.cginc" //defines a lot Of usefull helper functions

			struct appdata
			{
				float4 vertex 	: POSITION;
				float2 uv 		: TEXCOORD0;
				float3 normal 	: NORMAL;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				float2 uv 		: TEXCOORD0;
			};

			//the uv map of an object is a 2D image wrapped around the 3d object
			//the TEXCOORD0 uv you see above are the coordinates on this image for each vertex

			//Question: if specific uv coordinates are only specified for vertexes,
			//how are these then supplied to the fragment shader for a pixel inbetween 2 vertices?

			//here we import the properties defined in the shaderlab code earlier
			sampler2D	_MainTexture;
			sampler2D 	_DissolveTexture;
			float4 		_Color;
			float		_DissolveAmount;
			float		_ExtrudeAmount;

			//Vertex
			//building the object
			v2f vertexFunction (appdata IN) //what is appdata?
			{
				v2f OUT;

				//Tme = xyzw
				//x = 1/20 speed
				//y = 1/1 speed
				//z = 2/1 speed (?)
				IN.vertex.xyz += IN.normal.xyz * _ExtrudeAmount * sin(_Time.y);

				//UNITY_MATRIX_MVP = model, view and projection matrix:
				//https://stackoverflow.com/questions/5550620/the-purpose-of-model-view-projection-matrix
				//https://learnopengl.com/Getting-started/Coordinate-Systems
				//basically we take the input vertex
				//multiply it by the model matrix, putting the vertex into world space
				//multiply that by the view matrix, putting the vertex into camera space
				//multiply that by the projection matrix, putting the vertex into projection space
				//(either perspective or orthographic)
				//or like in this case, use the UnityObjectToClipPos function
				OUT.position = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.uv = IN.uv;

				return OUT;
			}

			//Fragment
			//coloring/drawing said object

			//Fragment (or texture) shaders define RGBA (red, green, blue, alpha) colors for each pixel being processed
			//a single fragment shader is called once per pixel.
			fixed4 fragmentFunction (v2f IN) : SV_Target //SV_Target indicates that the target is the screen basically
			{
				//tex2D gets the color on the specified coordinate on the provided texture
				float4 textureColor = tex2D(_MainTexture, IN.uv);
				float4 dissolveColor = tex2D(_DissolveTexture, IN.uv);

				clip(dissolveColor.rgb - _DissolveAmount * sin(_Time.y));

				return textureColor * _Color;
			}

			ENDCG
		}
	}
}
