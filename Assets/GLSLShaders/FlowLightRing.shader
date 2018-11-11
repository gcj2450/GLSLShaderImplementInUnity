//http://glslsandbox.com/e#24106.0
Shader "Unlit/FlowLightRing"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
        _CircleSize("CircleSize",float)=0.1
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
            float _CircleSize;

            vec2 position;

            vec3 ball(vec3 colour, float sizec, float xc, float yc){
                return colour * (sizec / distance(position, vec2(xc, yc)));
            }

            vec3 grid(vec3 colour, float linesize, float xc, float yc){
                float xmod = fmod(position.x, xc);
                float ymod = fmod(position.y, yc);
                return xmod < linesize || ymod < linesize ? vec3(0,0,0) : colour;
            }

            vec3 circle(vec3 colour, float size, float linesize, float xc, float yc){
                float dist = distance(position, vec2(xc, yc));
                return colour * clamp(-(abs(dist - size)*linesize * 50.0) + 0.5, 0.1, 1.0);
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
				position = ( input.uv.xy / _Resolution.xy )+_Mouse;
                position.y = position.y * _Resolution.y/_Resolution.x;
                
                vec3 color = vec3(0,0,0);
                float ratio = _Resolution.x / _Resolution.y;
                color += circle(vec3(1, 1, 2), _CircleSize, 0.6, 0.5, 0.5);
                
                //color += grid(vec3(1, 1, 2) * 0.1, 0.001, 0.06, 0.06);
                //color *= 1.0 - distance(position, vec2(0.5, 0.5));
                color += ball(vec3(1, 2, 1), 0.01, sin(time*4.0) / 12.0 + 0.5, cos(time*4.0) / 12.0 + 0.5);
                color *= ball(vec3(2, 1, 1), 0.02, -sin(time*-8.0) / 12.0 + 0.5, -cos(time*-8.0) / 12.0 + 0.5) + 0.5;
                return vec4(color, 1.0 );

			}
			ENDCG
		}
	}
}
