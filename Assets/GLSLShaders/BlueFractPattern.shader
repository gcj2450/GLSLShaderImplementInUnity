//http://glslsandbox.com/e#33294.3
Shader "Unlit/BlueFractPattern"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
        _Scale("Scale",float)=20
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

            uniform vec2 _Mouse;
            uniform vec2 _Resolution;
            uniform float _Scale;

            float length2(vec2 p) { return dot(p, p); }

            float noise(vec2 p){
                return fract(sin(fract(sin(p.x) * (45.0)) + p.y) * 30.0);
            }

            float worley(vec2 p) {
                float d = 1e30;
                for (int xo = -1; xo <= 1; ++xo) {
                    for (int yo = -1; yo <= 1; ++yo) {
                        vec2 tp = floor(p) + vec2(xo, yo);
                        d = min(d, length2(p - tp - vec2(noise(tp),noise(tp))));
                    }
                }
                return 3.0*exp(-3.0*abs(2.0*d - 1.0));
            }

            float fworley(vec2 p) {
                return sqrt(sqrt(sqrt(
                    1.1 * // light
                    worley(p*5. + .3 + time*.0525) *
                    sqrt(worley(p * 50. + 0.3 + time * -0.15)) *
                    sqrt(sqrt(worley(p * -10. + 9.3))))));
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
				vec2 uv = input.uv.xy / _Resolution.xy;
                float t = fworley(uv * _Resolution.xy / _Scale);
                t *= exp(-length2(abs(0.7*uv - 1.0)));
                return vec4(t * vec3(0.1, 1.5*t, 1.2*t + pow(t, 0.5-t)), 1.0);
			}
			ENDCG
		}
	}
}
