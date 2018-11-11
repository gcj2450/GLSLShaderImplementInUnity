//http://glslsandbox.com/e#48596.2
Shader "Unlit/OpenGLWater"
{
	Properties
	{
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
            #define time _Time.y
            // Forked (with flow and other knobs) (nvd)

            #ifdef GL_ES
            precision mediump float;
            #endif

            #define MAX_ITER 7

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
			  vec2 sp = input.uv;
              vec2 p = sp * 15.0 - vec2(20.0,20.0);
              vec2 i = p;
              float c = 1.0;        // brightness; larger -> darker
              float inten = 0.025;  // brightness; larger -> brighter
              float speed = 1.5;    // larger -> slower
              float speed2 = 3.0;   // larger -> slower
              float freq = 0.8;     // ripples
              float xflow = 1.5;    // flow speed in x direction
              float yflow = 0.0;    // flow speed in y direction

              for (int n = 0; n < MAX_ITER; n++) {
                float t = time * (1.0 - (3.0 / (float(n) + speed)));
                i = p + vec2(
                            cos(t - i.x * freq) + sin(t + i.y * freq) + (time * xflow), 
                            sin(t - i.y * freq) + cos(t + i.x * freq) + (time * yflow)
                            );
                c += 1.0 / length(vec2(p.x / (sin(i.x + t * speed2) / inten), p.y / (cos(i.y + t * speed2) / inten)));
              }
              
              c /= float(MAX_ITER);
              c = 1.5 - sqrt(c);
              float v = c * c * c * c;
              vec3 color = vec3(v, v + 0.4, v + 0.55);

              return vec4(color, 1.0);
			}
			ENDCG
		}
	}
}
