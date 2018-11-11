//http://glslsandbox.com/e#18408.0
Shader "Unlit/GridWhiteBg"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Scale("Scale",float)=10000.0
        _Offset("Offset",Vector) =(-0.023500000000000434, 0.9794000000000017,0,0)
        _GridSize("Pitch",Vector)  = (50, 50,0,0)
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

            uniform vec2 _Resolution;
            uniform vec2 _Offset;
            uniform vec2 _GridSize;
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
				o.uv =v.uv;
				return o;
			}
			
			fixed4 frag (v2f input) : SV_Target
			{
                vec2 Pos=(input.uv+_Resolution)*_Scale;
                float lX = Pos.x / _Resolution.x;
                float lY =Pos.y / _Resolution.y;

                float offX = _Offset[0] + Pos.x;
                float offY = _Offset[1] + (1.0 - Pos.y);

                if (int(fmod(offX, _GridSize[0])) == 0 ||
                  int(fmod(offY, _GridSize[1])) == 0) {
                return vec4(0.0, 0.0, 0.0, 0.5);
                } else {
                return vec4(1.0, 1.0, 1.0, 1.0);
                }
			}
			ENDCG
		}
	}
}
