//http://glslsandbox.com/e#43869.0
Shader "Unlit/ColorfulRect"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse("Mouse", Vector) = (1,1,0,1)
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

            uniform vec2 _Mouse;
            uniform vec2 _Resolution;

            #ifdef GL_ES
            precision mediump float;
            #endif

            //#extension GL_OES_standard_derivatives : enable

            vec3 HSV2RGB(vec3 c)
            {
                vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
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
                vec2 position = ( input.uv.xy / _Resolution.xy );

                float koef = _Mouse.x - position.x + time * 0.1;
                float vstep = koef * 10.0;
                float vfloor = floor(vstep);
                float vfract = fract(vstep);
                float top = clamp(vfract * 5. , 0., 1.);
                float color = vfloor * .1;//, -1.0, 1.0));
                
                return vec4(HSV2RGB(vec3(color, 1.0, 1.0)) * (0.3 + top*.7), 1.0 );
			}
			ENDCG
		}
	}
}
