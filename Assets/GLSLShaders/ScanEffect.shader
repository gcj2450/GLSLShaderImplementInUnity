//http://glslsandbox.com/e#5145.1
Shader "Unlit/ScanEffect"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        Scale("Scale",float)=1
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


            #ifdef GL_ES
            precision mediump float;
            #endif

            uniform vec2 _Resolution;
            float _Scale;

            #define GRID_SIZE 1
            #define PI 3.1416

            vec3 color(float d) {
                return d * vec3(0, 1, 0);   
            }

            int mod(int a, int b) {
                return a - ((a / b) * b);
            }

            vec4 main(vec2 gl_FragCoord)
            {
                vec2 p = (-1.0 + 2.0 * ((gl_FragCoord.xy) / _Resolution.xy));
                //p -= (2.0 * mouse.xy) - vec2(1.0);
                p.x *= (_Resolution.x / _Resolution.y);
                vec2 uv;

                float a = (atan2(p.y,p.x) + time);
                float r = sqrt(dot(p,p));

                uv.x = 0.1/r;
                uv.y = a/(PI);
                
                float len = dot(p,p);
                
                vec3 col = color(pow(fract(uv.y / -3.0), 10.0));
                if (len > 0.7) col = vec3(0.8,0.8,0.8);
                if (len > 0.73) col = vec3(0,0,0);
                

                return vec4(col, 3.0);
            }

            vec4 main2(vec2 gl_FragCoord)
            {
                vec2 p = (-1.0 + 2.0 * ((gl_FragCoord.xy) / _Resolution.xy));
                //p -= (2.0 * mouse.xy) - vec2(1.0);
                p.x *= (_Resolution.x / _Resolution.y);
                vec2 uv;

                float a = (atan2(p.y,p.x) + time);
                float r = sqrt(dot(p,p));

                uv.x = 0.1/r;
                uv.y = a/(PI);
                
                float len = dot(p,p);
                
                vec3 col = color(pow(fract(uv.y / -2.0), 15.0));
                if (len > 0.7) col = vec3(0.8,0.8,0.8);
                if (len > 0.73) col = vec3(0,0,0);
                
                bool grid_x = mod(int(_Scale*gl_FragCoord.x) - int(_Resolution.x / 2.0), GRID_SIZE) == 0;
                bool grid_y = mod(int(_Scale*gl_FragCoord.y) - int(_Resolution.y / 2.0), GRID_SIZE) == 0;
                
                if (len < 0.7)
                {
                if (grid_x || grid_y)
                    col += color(0.1);
                
                if (grid_x && grid_y)
                    col += color(1.0);
                }
                return vec4(col, 1.0);
            }


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
				o.uv =v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return main(i.uv);
                //return main2(i.uv);
			}
			ENDCG
		}
	}
}
