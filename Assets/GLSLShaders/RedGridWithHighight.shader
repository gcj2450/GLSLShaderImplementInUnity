//http://glslsandbox.com/e#11264.0
//http://glslsandbox.com/e#10832.0
Shader "Unlit/RedGridWithHighight"
{
	Properties
	{
		 _Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
        _Scale("Scale",float)=1
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

            uniform vec2 _Mouse;
            uniform vec2 _Resolution;
            float _Scale;


            vec4 main( vec2  gl_FragCoord) {
                
                vec3 col = vec3(0.1,.1,.1);
                gl_FragCoord=(gl_FragCoord+_Resolution)*_Scale;
                //really light lines
                col.g += clamp(ceil(fmod(gl_FragCoord.x + .1, 5.0)) - 0.0, 10.0, 1.0) * 0.05;
                col.g += clamp(ceil(fmod(gl_FragCoord.y + .1, 5.0)) - 4.0, 0.0, 1.0) * 0.05;
                col.g = clamp(col.g, 0.0, 0.55);
                
                //light lines
                col.b += clamp(ceil(fmod(gl_FragCoord.x, 15.0)) - 14.0, 0.0, 1.0) * 0.25;
                col.b += clamp(ceil(fmod(gl_FragCoord.y, 15.0)) - 14.0, 0.0, 1.0) * 0.25;
                col.b = clamp(col.b, 0.0, 0.25);
                
                //strong lines
                col.r += clamp(ceil(fmod(gl_FragCoord.x, 30.0)) - 29.0, 0.0, 1.0);
                col.r += clamp(ceil(fmod(gl_FragCoord.y, 30.0)) - 29.0, 0.0, 1.0);
                //使用这一句可以实现网格被灯光照亮的效果
                //col.r += clamp(fmod(gl_FragCoord.y, 30.0) - 29.0, 0.0, 1.0);
                col.r = clamp(col.r, 0.0, 1.0);
                
                //mouse detect
                vec2 mousePos = _Resolution.xy * _Mouse*_Scale;
                col.g *= 1.0 - clamp(distance(mousePos, gl_FragCoord.xy)/175.0, 0.0, 1.0);
                
                
                return vec4(col, 1.0);
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
			
			fixed4 frag (v2f i) : SV_Target
			{
				return main(i.uv);
			}
			ENDCG
		}
	}
}
