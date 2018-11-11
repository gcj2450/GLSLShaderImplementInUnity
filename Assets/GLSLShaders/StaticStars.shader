//http://glslsandbox.com/e#38910.0
Shader "Unlit/StaticStars"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
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

            //#extension GL_OES_standard_derivatives : enable

            uniform vec2 _Mouse;
            uniform vec2 _Resolution;

            #define M_PI 3.141592

            vec2 rand2(vec2 p)
            {
                p = vec2(dot(p, vec2(12.9898,78.233)), dot(p, vec2(26.65125, 83.054543))); 
                return fract(sin(p) * 43758.5453);
            }

            float rand(vec2 p)
            {
                return fract(sin(dot(p.xy ,vec2(54.90898,18.233))) * 4337.5453);
            }

            // Thanks to David Hoskins https://www.shadertoy.com/view/4djGRh
            float stars(in vec2 x, float numCells, float size, float br)
            {
                vec2 n = x * numCells;
                vec2 f = floor(n);

                float d = 1.0e10;
                for (int i = -1; i <= 1; ++i)
                {
                    for (int j = -1; j <= 1; ++j)
                    {
                        vec2 g = f + vec2(float(i), float(j));
                        g = n - g - rand2(fmod(g, numCells)) + rand(g);
                        // Control size
                        g *= 1. / (numCells * size*sin(rand(1)*time));
                        d = min(d, dot(g, g));
                    }
                }

                return br * (smoothstep(.95, 1., (1. - sqrt(d))));
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
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f input) : SV_Target
			{
				float resolution = max(_Resolution.y, _Resolution.y);
                
                vec2 coord = input.uv.xy / resolution;

                vec3 result = vec3(0,0,0);
                
                result += stars(coord + _Mouse.xy * 0.1, 4., 0.1, 2.) * vec3(.74, .74, .74);
                result += stars(coord + _Mouse.xy * 0.05, 8., 0.05, 1.) * vec3(.97, .74, .74);
                result += stars(coord + _Mouse.xy * 0.025, 10., 0.05, 0.8) * vec3(.9, .9, .95);
                result += stars(coord, 50., 0.025, 0.5) * vec3(.9, .9, .95);
                
                return vec4(result, 1.);
			}
			ENDCG
		}
	}
}
