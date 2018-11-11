//http://glslsandbox.com/e#32657.0
Shader "Unlit/GlowRectangle"
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

            #ifdef GL_ES
            precision mediump float;
            #endif

            //#extension GL_OES_standard_derivatives : enable

            uniform vec2 _Resolution;


            float DrawLine( vec2 a,vec2 b, vec2 p )
            {
                vec2 aTob = b - a;
                vec2 aTop = p - a;
                
                float t = dot( aTop, aTob ) / dot( aTob, aTob);
                
                t = clamp( t, 0.01, 0.99);
                
                float d = length( p - (a + aTob * t) );
                d = 0.3 / d;
                
                return clamp( d, 0.0, 0.5 );
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
				vec2 uv = ( input.uv.xy / _Resolution.xy );
                vec2 signedUV = uv * 2.0 - 1.0;

                float freq = lerp( 0.7, 0.9, sin(time*4.) );
                
                
                float scale = 55.0;
                float v = 50.0;
                vec3 finalColor = vec3( 0,0,0 );
                float t = DrawLine( vec2(-v, -v), vec2(-v, v), signedUV * scale );
                finalColor = vec3( 2.0 * t, 2.0 * t, 8.0 * t) * freq;
                t = DrawLine( vec2(-v, v), vec2(v, v), signedUV * scale );
                finalColor += vec3( 2.0 * t, 2.0 * t, 8.0 * t) * freq;
                t = DrawLine( vec2(v, v), vec2(v, -v), signedUV * scale );
                finalColor += vec3( 2.0 * t, 4.0 * t, 8.0 * t) * freq;
                t = DrawLine( vec2(v, -v), vec2(-v, -v), signedUV * scale );
                finalColor += vec3( 2.0 * t, 4.0 * t, 8.0 * t) * freq;

                return vec4( finalColor, 1.0 );
			}
			ENDCG
		}
	}
}
