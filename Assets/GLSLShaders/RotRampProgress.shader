//http://glslsandbox.com/e#22806.0
Shader "Unlit/RotRampProgress"
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

            uniform vec2 _Mouse;
            uniform vec2 _Resolution;

            #define SMOOTH(r) (lerp(0.0, 1.0, smoothstep(0.98,1.0, r)))
            #define M_PI 3.1415926535897932384626433832795

            float movingRing(vec2 uv, vec2 center, float r1, float r2)
            {
                vec2 d = uv - center;
                float r = sqrt( dot( d, d ) );
                d = normalize(d);
                float theta = -atan2(d.y,d.x);
                theta  = fmod(-time+0.5*(1.0+theta/M_PI), 1.0);
                //anti aliasing for the ring's head (thanks to TDM !)
                theta -= max(theta - 1.0 + 1e-2, 0.0) * 1e2;
                return theta*(SMOOTH(r/r2)-SMOOTH(r/r1));
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
			
			fixed4 frag (v2f input) : SV_Target
			{
				vec2 uv = input.uv.xy+_Mouse;
                float ring = movingRing(uv, vec2(_Resolution.x/2.0,_Resolution.y/2.0), .2, .35);
                //return vec4( ring, ring, ring,ring );
                return vec4( 0.1 + 0.9*ring, 0.1 + 0.9*ring, 0.1 + 0.9*ring,0.1 + 0.9*ring );
			}
			ENDCG
		}
	}
}
