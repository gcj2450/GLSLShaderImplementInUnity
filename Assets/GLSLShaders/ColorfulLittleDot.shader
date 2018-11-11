//http://glslsandbox.com/e#49712.0
Shader "Unlit/ColorfulLittleDot"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,1,1)
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
            #define time  _Time.g
            #define fract  frac

            #ifdef GL_ES
            precision mediump float;
            #endif

            //#extension GL_OES_standard_derivatives : enable

            uniform float4 _Resolution;

            float hash(vec2 uv) {
                return fract(74455.45 * sin(dot(vec2(78.54, 14.45), uv)));
            }

            vec2 hash2(vec2 uv) {
                float  k = hash(uv);
                return vec2(k, hash(uv + k));
            }

            // IQ
            vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d)
            {
                return a + b*cos( 6.28318*(c*t+d) );
            }
            //

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				vec2 uv = (2. * i.uv - _Resolution) / _Resolution.y;
                vec3 col = vec3(0,0,0);
                for (int i = 0; i < 120; i++) {
                    vec2 p = 2. * hash2(float(i) + vec2(2,2)) - 1.;
                    p -= vec2(sin(.1 * hash(float(i) + vec2(10., 50.)) * time + hash(float(i) + vec2(10,10))), 
                          cos(.1 * hash(float(i) + vec2(20., 40.)) * time + hash(float(i) + vec2(10,10))));
                    float k = (.5 * hash(float(i) + vec2(25., 75.)) + .01);
                    col += palette(k * 3., vec3(0.5,0.5,0.5), vec3(0.5,0.5,0.5), vec3(1,1,1), vec3(.0, .33, .67)) / length(uv - p);
                }
                col /= 360.;
                return vec4(col, 1.);
			}
			ENDCG
		}
	}
}
