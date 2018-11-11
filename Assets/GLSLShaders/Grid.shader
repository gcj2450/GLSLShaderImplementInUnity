//http://glslsandbox.com/e#33806.1
Shader "Unlit/Grid"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Scale("Scale",float)=5
        _LineWidth("LineWidth",Range(0,1))=0.9
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
            uniform float _Scale;
            uniform float _LineWidth;

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
                vec2 originalUV = uv;
                uv.x *= _Resolution.x / _Resolution.y;
                
                uv *= _Scale;

                uv = fmod(uv, 1.0);
                
                bool t = max(uv.x, uv.y) > _LineWidth;

                vec3 finalColor = vec3( t,t,t );
                finalColor *= 1.0-length(originalUV - 0.5);
                    
                return vec4( finalColor, 1.0 );
			}
			ENDCG
		}
	}
}
