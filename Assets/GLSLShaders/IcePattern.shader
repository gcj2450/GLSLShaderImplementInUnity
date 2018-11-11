//http://glslsandbox.com/e#33953.0
Shader "Unlit/IcePattern"
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
				vec2 pos = input.uv-_Resolution.xy;
                int j = 0;
                
                for(int i = 0; i < 256; i++){
                    j++;
                    if(length(pos) > 2.) break;
                    pos= vec2(pos.x * pos.x - pos.y * pos.y, 2. * pos.x * pos.y) + _Mouse;
                }
                float t = float(j) / 128. ;
                return vec4(vec3(t,t,t),1);
			}
			ENDCG
		}
	}
}
