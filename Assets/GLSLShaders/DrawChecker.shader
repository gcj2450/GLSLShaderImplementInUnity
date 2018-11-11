//http://glslsandbox.com/e#25453.0
Shader "Unlit/DrawChecker"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
        _Width("Width",float)=50
        _Height("Height",float)=50
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


            uniform vec2 _Mouse;
            uniform vec2 _Resolution;
            float _Width;
            float _Height;
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
				//vec2 position = ( input.uv.xy / _Resolution.xy ) + _Mouse / 1.0;
                vec2 position =input.uv.xy / _Resolution.xy;
                float colorID2 = clamp(fmod(input.uv.y,_Width)/_Scale,0.0,1); 
                float colorID = clamp(fmod(input.uv.x,_Height)/_Scale,0.0,1); 
                //vec3 color = vec3(position.x,position.x,position.x);
                float color =colorID*colorID2;
                return vec4( vec3( color,color,color ), 1.0 );
			}
			ENDCG
		}
	}
}
