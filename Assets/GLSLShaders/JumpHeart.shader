Shader "Unlit/JumpHeart"
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
            #define time _Time.g
            #define fract frac

            // Skralltig, Skruttig :-) 


            #ifdef GL_ES
            precision mediump float;
            #endif

            //#extension GL_OES_standard_derivatives : enable

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
				vec2 uv= 2.0*input.uv.xy-vec2(1,1);
                
                vec3 grad = vec3(1.0,0.8,0.7-0.07*uv.y)*(1.0-0.25*length(uv));

                float tt = fmod(time,1.5)/1.5;
                float ss = pow(tt,.2)*0.5 + 0.5;
                
                ss = 1.0 + ss*0.5*sin(tt*6.2831*3.0 + uv.y*0.5)*exp(-tt*4.0);
                uv *= vec2(0.5,1.5) + ss*vec2(0.5,-0.5);

                uv *=  0.8 ;
                uv.y = -0.1 - uv.y*1.2 + abs(uv.x)*(1.0-abs(uv.x)) ;
                
                float r = length(uv);
                float d = 0.5;
                
                float s = 0.75 + 0.75*uv.x;
                s *= 1.0-0.4*r;
                s = 0.3 + 0.7*s;
                s *= 0.5+0.5*pow( 1.0-clamp(r/d, 0.0, 1.0 ), 0.1 );
                vec3 heart = vec3(1.0,0.5*r,0.3)*s;
                
                vec3 col = lerp( grad, heart, smoothstep( -0.01, 0.01, d-r) );

                return vec4(col,1.0);
			}
			ENDCG
		}
	}
}
