//http://glslsandbox.com/e#24153.0
Shader "Unlit/FlowLightGrid"
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


            #ifdef GL_ES
            precision mediump float;
            #endif

            #define PI 3.1415926535897932384626433832795
            #define vec2 float2
            #define vec3 float3
            #define vec4 float4
            #define time _Time.g
            #define fract frac

            uniform float2 _Resolution;


            float2 circuit(float2 p)
            {
                p = fract(p);
                float r = 0.3;
                float v = 0.0, g = 1.0;
                float d;
                
                const int iter = 7;
                for(int i = 0; i < iter; i ++)
                {
                    d = p.x - r;
                    g += pow(clamp(1.0 - abs(d), 0.0, 1.0), 1000.0);

                    if(d > 0.0) {
                        p.x = (p.x - r) / (1.8 - r);
                    }
                    else {
                        p.x = p.x;
                    }
                    p = p.yx;
                }
                v /= float(iter);
                return float2(g, v);
            }

            vec4 main(in vec2 gl_FragCoord)
            {
                float2 uv = gl_FragCoord.xy;
                uv /= _Resolution.xy;
                float2 cid2 = floor(uv);
                float cid = (cid2.y + cid2.x);

                float2 dg = circuit(uv * 2.0);
                float d = dg.x;
                float maxVal=max(min(d, 2.0) - 1.0, 0.0);
                float3 col1 = (0.5-float3(maxVal,maxVal,maxVal));
                float maxVal2=max(d - 1.0, 0.0);
                float3 col2 = float3(maxVal2,maxVal2,maxVal2) * float3(1.0, 1.0, 1.0);

                float intensity = 5.0;
                float speed = 0.5;
                float f = max(0.4 - fmod(uv.y - uv.x + ((sin(time * 2.0) +1.0) * 0.2 + time * speed) + (dg.y * 0.2), 2.5), 0.0) * intensity;
                col2 *= f;
                
                return vec4(col1 + col2, 1.0);
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
				o.uv =v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return main(i.uv);
			}
			ENDCG
		}
	}
}
