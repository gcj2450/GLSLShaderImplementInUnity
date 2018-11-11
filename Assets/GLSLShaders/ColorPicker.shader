//http://glslsandbox.com/e#33366.0
Shader "Unlit/ColorPicker"
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

            uniform vec2 _Resolution;
            uniform vec2 _Mouse;

            vec3 Hue( float hue )
            {
                vec3 rgb = fract(hue + vec3(0.0,2.0/3.0,1.0/3.0));

                rgb = abs(rgb*2.0-1.0);
                    
                return clamp(rgb*3.0-1.0,0.0,1.0);
            }

            vec3 HSVtoRGB( vec3 hsv )
            {
                return ((Hue(hsv.x)-1.0)*hsv.y+1.0) * hsv.z;
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
				float h = input.uv.x / _Resolution.x;
                
                float s = input.uv.y / _Resolution.y;
                
                float v = _Mouse.y;
                
                return vec4(HSVtoRGB(vec3(h,s,v)),1.0);
			}
			ENDCG
		}
	}
}
