// warping hexagons, WIP. @psonice_cw
// I'm sure there's a less fugly way of making a hexagonal grid, but hey :)
//http://glslsandbox.com/e#18724.0
//  Maybe - Try this...

// Simplify!

// @eddbiddulph - modulated hexagons by the hexagon shape itself, and added some colour.

Shader "Unlit/BeeHex"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Scale("Scale",float)=1
        _Thickness("Thickness",float)=0.05
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

            vec2 _Resolution;
            float _Scale;
            float _Thickness;


            // 1 on edges, 0 in middle
            float hex(vec2 p) {
                p.x *= 0.57735*2.0;
                p.y += fmod(floor(p.x), 2.0) * 0.5;
                p = abs((fmod(p, 1.0) - 0.5));
                return abs(max(p.x * 1.5 + p.y, p.y *2.0 ) - 1.0);
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
			
			fixed4 frag (v2f input) : SV_Target
			{
				vec2 pos = input.uv.xy;
                vec2 p = pos * _Scale;

                float r = (1.0 - 1.0) * 0.5;
                vec4 gl_FragColor;
                gl_FragColor.rgb = vec3(1.0,1.0,1.0) * smoothstep(r, r + _Thickness, hex(p));
                gl_FragColor.a = 1.0;
                return gl_FragColor;
			}
			ENDCG
		}
	}
}
