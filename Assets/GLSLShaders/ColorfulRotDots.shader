//http://glslsandbox.com/e#38158.0
Shader "Unlit/ColorfulRotDots"
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
            uniform sampler2D backbuffer;

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
				float 
                    t = time,
                    p;
                
                vec2 
                g = input.uv.xy,
                    s = _Resolution.xy,
                    u = (g+g-s)/s.y,
                    ar = vec2(
                        atan2(u.x, u.y) * 3.18 + t*2., 
                        length(u)*3. + sin(t*.5)*10.);
                
                p = floor(ar.y)/5.;
                
                ar = abs(fract(ar)-.5);
                
                vec4 cl= lerp(vec4(1,.3,0,1), 
                        vec4(.3,.2,.5,1), 
                        vec4(p,p,p,p))* 0.1/dot(ar,ar) * .1;
                cl.a = 1.;
                return cl;
			}
			ENDCG
		}
	}
}
