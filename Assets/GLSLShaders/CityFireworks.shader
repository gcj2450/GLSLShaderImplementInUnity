//http://glslsandbox.com/e#44156.2
Shader "Unlit/CityFireworks"
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
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
            #define vec2 float2
            #define vec3 float3
            #define vec4 float4
            #define time _Time.g
            #define fract frac

            #ifdef GL_ES
            precision mediump float;
            #endif

            #define N(h) fract(sin(vec4(6,9,1,0)*h) * 9e2)

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
			
			fixed4 frag (v2f input) : SV_Target
			{
				vec4 o = vec4(0,0,0,0);
                vec2 u = input.uv.xy;

                float e, d, i=0.;
                vec4 p;

                for(float i=0.; i<9.; i++) {
                  d = floor(e = i*9.1+time);
                  p = N(d)+.3;
                  e -= d;
                  for(float d=0.; d<50.;d++)
                    o += p*(1.-e)/1e3/length(u-(p-e*(N(d*i)-.5)).xy);
                }

                if(u.y<N(ceil(u.x*10.+d+e)).x*.5)
                  o-=o*u.y;
                return vec4(o.rgb, 1.);
			}
			ENDCG
		}
	}
}
