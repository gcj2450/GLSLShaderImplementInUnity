//http://glslsandbox.com/e#40947.1
//http://glslsandbox.com/e#40944.0
Shader "Unlit/GrayFractNoise"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
        _Max_Iter("Max_Iter",float)=3
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

            int _Max_Iter;

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
				float gtime = time * .5+23.0;
                // uv should be the 0-1 uv of texture...
                vec2 uv = input.uv.xy / _Resolution.xy;
                vec2 p = fmod(uv*6.28, 6.28)-250.0;
                vec2 i = vec2(p);
                float c = 1.0;
                float inten = .008;

                for (int n = 0; n < _Max_Iter; n++) 
                {
                    float t = gtime * (0.0 - (3.0 / float(n+1)));
                    i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
                    c += 1.0/length(vec2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
                    vec2 uv = input.uv.xy / _Resolution.xy;
                    vec2 p = fmod(uv*6.28, 6.28)-250.0;
                    vec2 i = vec2(p);
                    float c = 1.0;
                    float inten = .008;

                    for (int n = 0; n < _Max_Iter; n++) 
                    {
                        float t = gtime * (0.0 - (3.0 / float(n+1)));
                        i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
                        c += 1.0/length(vec2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
                    }
                }
                c /= float(_Max_Iter);
                c = 1.17-pow(c, 1.4);
                vec3 clr = vec3(pow(abs(c), 8.0),pow(abs(c), 8.0),pow(abs(c), 8.0));
                clr = clamp(clr + vec3(0.0, 0.35, 0.5), 0.0, 1.0);  //水的颜色vec3(0.0, 0.35, 0.5)
                return vec4(clr, 1.0);
			}
			ENDCG
		}
	}
}
