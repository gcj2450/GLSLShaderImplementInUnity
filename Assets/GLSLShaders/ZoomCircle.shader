//http://glslsandbox.com/e#44853.1
Shader "Unlit/ZoomCircle"
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
                fixed4 gl_FragColor=fixed4(0,0,0,1);
				vec2 position = ((input.uv.xy / _Resolution.xy) * 2. - 1.) * vec2(_Resolution.x / _Resolution.y, 1.0);
                float d = abs(0.1 + length(position) - 0.5 * abs(cos(sin(time)))) * 5.0;
                gl_FragColor += vec4(sin(time) /4./d, 0.1 / d, cos(time) /4.0 / d, 1.0);
                return gl_FragColor;
			}
			ENDCG
		}
	}
}
