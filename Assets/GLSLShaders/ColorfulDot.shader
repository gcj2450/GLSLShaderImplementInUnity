//http://glslsandbox.com/e#48398.1
// original https://www.shadertoy.com/view/Ml3cWs
Shader "Unlit/ColorfulDot"
{
	Properties
	{
        _Color ("Color", Color) = (0,0,0.1,1)
        _ParticlesCnt ("ParticlesCnt", float ) = 15
        _Size ("Size", Range(0,1)) = 0.02
        _Softness ("Softness", float) = 444
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
            #define vec2 fixed2
            #define vec3 fixed3
            #define vec4 fixed4
            #define time _Time.g

            #ifdef GL_ES
            precision mediump float;
            #endif

            float _ParticlesCnt;
            fixed _Size;
            float _Softness;
            fixed4 _Color;

            float random (int i)
            { return frac(sin(float(i)*43.0)*4790.234); }

            fixed softEdge(float edge, float amt)
            { return clamp(0.50 / (clamp(edge, 0.120/amt, 1.0)*amt), 0.,1.); }

			struct appdata
			{
				float4 vertex : POSITION;
				fixed2 uv : TEXCOORD0;
			};

			struct v2f
			{
				fixed2 uv : TEXCOORD0;
				fixed4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				vec2 uv = i.uv;
                fixed4 finalColor;
                for(int i = 0; i < _ParticlesCnt; i++)
                {
                    fixed r1 = random(i);
                    fixed r2 = random(i+_ParticlesCnt);
                    fixed r3 = random(i+_ParticlesCnt*2);
                    vec2 tc = uv - vec2(sin(time*0.125 + r1*30.0)*r1 
                                       ,cos(time*0.125 + r1*40.0)*r2*0.5);
                    fixed l = length(tc - vec2(0.5, 0.5)) - r1*_Size;
                    vec4 orb = vec4(r1, r2, r3, softEdge(l, _Softness));
                    finalColor+= lerp(_Color, orb, orb.a);
                }
                return finalColor;
			}
			ENDCG
		}
	}
}
