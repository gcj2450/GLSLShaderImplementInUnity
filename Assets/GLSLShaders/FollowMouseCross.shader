//http://glslsandbox.com/e#25014.1
Shader "Unlit/FollowMouseCross"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
        _Scale("Scale",float)=64
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

            uniform float2 _Resolution;
            uniform float2 _Mouse;
            float _Scale;

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
				vec2 position =_Scale* input.uv.xy / _Resolution.xy;
                int x = int((position.x  -_Mouse.x) * _Resolution.x) / 1;
                int y = int((position.y  -_Mouse.y) * _Resolution.y) / 1;
                int xy = x * y;
                if (xy * xy / 8 * 8 == 0) {
                    return vec4(1.0, 0.0, 0.0, 1.0 );
                } else {
                    return vec4(1.0, 1.0, 1.0, 1.0 );
                }
			}
			ENDCG
		}
	}
}
