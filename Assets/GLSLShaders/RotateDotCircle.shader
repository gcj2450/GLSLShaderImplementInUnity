//http://glslsandbox.com/e#40812.0
Shader "Unlit/RotateDotCircle"
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

            //precision highp float;

            uniform vec2 _Resolution;

            #define TWO_PI 6.283185
            #define NUMBALLS 50.0

            float d = -TWO_PI/36.0;

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
				vec2 p = (2.0*input.uv.xy - _Resolution)/min(_Resolution.x, _Resolution.y);
                //P *= mat2(cos(time), -sin(time), sin(time), cos(time));
                
                vec3 c = vec3(0,0,0); //ftfy
                for(float i = 0.0; i < NUMBALLS; i++) {
                    float t = TWO_PI * i/NUMBALLS + time;
                    float x = cos(t);
                    float y = sin(1.0 * t + d);
                    vec2 q = 0.8*vec2(x, y);
                    c += 0.01/distance(p, q) * vec3(0.5 * abs(x), 0, abs(y));
                }
                return vec4(c, 1.0);
			}
			ENDCG
		}
	}
}
