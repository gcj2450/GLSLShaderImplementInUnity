//http://glslsandbox.com/e#42518.0
Shader "Unlit/DrawDots"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
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
			
			#include "UnityCG.cginc"
            #define vec2 float2
            #define vec3 float3
            #define vec4 float4
            #define time _Time.g
            #define fract frac

            // Playing around with Lissajous curves.
            #ifdef GL_ES
            precision mediump float;
            #endif

            //what if you want to draw 22 million dots?

            uniform vec2 _Resolution;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f input) : SV_Target
			{
                vec3 finalColor;
                
                //Dot size
                float size = 0.01;

                // the middle of the screen 
                vec2 middle = _Resolution/2.0;
                vec2 coord = input.uv.xy;

                for (int i = 0; i < 15 + 1; ++i) {
                    vec2 position = middle;
                    position.y += float(i*0.1);
                    float distance_to_dot = length(coord - position);
                    finalColor+=vec3(0,0,size / distance_to_dot);
                }
                return vec4(finalColor, 1);
			}
			ENDCG
		}
	}
}
