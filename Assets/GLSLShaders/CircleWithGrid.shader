Shader "Unlit/CircleWithGrid"
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

            //#ifdef GL_ES
            //precision mediump float;
            //#endif

            //#extension GL_OES_standard_derivatives : enable

            uniform vec2 _Mouse;
            uniform vec2 _Resolution;

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
				vec2 p = (input.uv.xy * 2.0 - _Resolution) / min(_Resolution.x, _Resolution.y);
                vec3 color = vec3(0.0, 0.3, 0.5);
                
                float f = 0.0;
                float PI = 3.141592;
                for(float i = 0.0; i < 20.0; i++){
                    
                    float s = sin(time + i * PI / 10.0) * 0.8;
                    float c = cos(time + i * PI / 10.0) * 0.8;
             
                    f += 0.001 / (abs(p.x + c) * abs(p.y + s));
                }
                
                
                return vec4(vec3(f * color), 1.0);
			}
			ENDCG
		}
	}
}
