//http://glslsandbox.com/e#48017.1
Shader "Unlit/SmokeCloud"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (0,1,0,1)
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
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
            #define vec2 float2
            #define vec3 float3
            #define vec4 float4
            #define time _Time.g
            #define fract frac
            #define mat2 float2x2
            #define mat3 float3x3
            #define mat4 float4x4

            #ifdef GL_ES
            precision mediump float;
            #endif

            //#extension GL_OES_standard_derivatives : enable

            #define NUM_OCTAVES 16

            uniform vec4 _Resolution;

             mat3 rotX(float a) {
                float c = cos(a);
                float s = sin(a);
                return mat3(
                    1, 0, 0,
                    0, c, -s,
                    0, s, c
                );
            }
            mat3 rotY(float a) {
                float c = cos(a);
                float s = sin(a);
                return mat3(
                    c, 0, -s,
                    0, 1, 0,
                    s, 0, c
                );
            }

            float random(vec2 pos) {
                return fract(sin(dot(pos.xy, vec2(12.9898, 78.233))) * 43758.5453123);
            }

            float noise(vec2 pos) {
                vec2 i = floor(pos);
                vec2 f = fract(pos);
                float a = random(i + vec2(0.0, 0.0));
                float b = random(i + vec2(1.0, 0.0));
                float c = random(i + vec2(0.0, 1.0));
                float d = random(i + vec2(1.0, 1.0));
                vec2 u = f * f * (3.0 - 2.0 * f);
                return lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
            }

            float fbm(vec2 pos) {
                float v = 0.0;
                float a = 0.5;
                vec2 shift = vec2(100.0,100);
                mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5));
                for (int i=0; i<NUM_OCTAVES; i++) {
                    v = (sin(v*1.07)) + ( a * noise(pos) );
                    pos = mul(rot , pos * 2.0) + shift;
                    a *= 0.5;
                }
                return v;
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
			
			fixed4 frag (v2f i) : SV_Target
			{
				vec2 p = (i.uv.xy * 2.0 - _Resolution.xy) / min(_Resolution.x, _Resolution.y);

                float t = 0.0, d;
                
                float time2 = 3.0 * time / 2.0;
                
                vec2 q = vec2(0.0,0);
                q.x = fbm(p + 0.00 * time2);
                q.y = fbm(p + vec2(1.0,1.0));
                vec2 r = vec2(0.0,0);
                r.x = fbm(p + 1.0 * q + vec2(1.7, 9.2) + 0.15 * time2);
                r.y = fbm(p + 1.0 * q + vec2(8.3, 2.8) + 0.126 * time2);
                float f = fbm(p + r);
                vec3 color = lerp(
                    vec3(sin(f*6.14)*0.5+0.5, 0.1, 0.1),
                    vec3(0.1, 0.1, cos(f*6.14)*0.5+0.5),
                    1./(f*f)
                );

                color = lerp(
                    color,
                    vec3(1., 0., 0.),
                    clamp(length(q), 0.0, 1.0)
                );


                color = lerp(
                    color,
                    vec3(1.17, 1.3, 1.3),
                    clamp(length(r.x), 0.0, 1.0)
                );

                color = (f *f * f + 0.6 * f * f + 0.5 * f) * color;
                
                return vec4(color, 0.0);
			}
			ENDCG
		}
	}
}
