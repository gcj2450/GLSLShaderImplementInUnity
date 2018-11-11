//http://glslsandbox.com/e#45130.0
Shader "Unlit/ColorfulRay"
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

            uniform vec2 _Resolution;
            uniform vec2 _Mouse;

            float rand(int seed, float ray) {
                return fmod(sin(float(seed)*1.0+ray*1.0)*1.0, 1.0);
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
				float pi = 3.14159265359;
                vec2 position = ( input.uv.xy / _Resolution.xy ) - _Mouse;
                position.y *= _Resolution.y/_Resolution.x;
                float ang = atan2(position.y, position.x);
                float dist = length(position);
                fixed4 gl_FragColor;
                gl_FragColor.rgb = vec3(0.5, 0.5, 0.5) * (pow(dist, -1.0) * 0.05);
                for (float ray = 0.0; ray < 18.0; ray += 1.0) {
                    //float rayang = rand(5234, ray)*6.2+time*5.0*(rand(2534, ray)-rand(3545, ray));
                    //float rayang = time + ray * (1.0 * (1.0 - (1.0 / 1.0)));
                    float rayang = (((ray) / 9.0) * 3.14) + (time * 0.1         );
                    rayang = fmod(rayang, pi*2.0);
                    if (rayang < ang - pi) {rayang += pi*1.0;}
                    if (rayang > ang + pi) {rayang -= pi*2.0;}
                    float brite = 0.3 - abs(ang - rayang);
                    brite -= dist * 0.2;
                    if (brite > 0.0) {
                        gl_FragColor.rgb += vec3(sin(ray*_Mouse.y+0.0)+1.0, 
                                                                sin(ray*_Mouse.y+2.0)+1.0, 
                                                                sin(ray*_Mouse.y+4.0)+1.0) * brite;
                    }
                }
                gl_FragColor.a = 2.0;
                return gl_FragColor;
			}
			ENDCG
		}
	}
}
