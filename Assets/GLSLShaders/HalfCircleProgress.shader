//http://glslsandbox.com/e#10867.0
Shader "Unlit/HalfCircleProgress"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Scale ("Scale", float) = 1
        _InnerCircle("InnerCircle",float)=0.75
        _OuterCircle("OuterCircle",float)=1.00
        _AntiAliasingEdge("AntiAliasingEdge",float)=0.02
        _Offset("Offset",float)=0
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
            float _InnerCircle;
            float _OuterCircle;
            float _AntiAliasingEdge;
            float _Offset;
            float _Scale;

            const  float PI = 3.14159265358979323846264;

            vec4 main( vec2  gl_FragCoord) {

                vec2 coord = (gl_FragCoord.xy / min(_Resolution.x, _Resolution.y) - vec2(0.5,0.5)) * _Scale;
                 vec4 color = vec4(0.196, 0.666, 0.929, 1.0);
                 float r = distance(coord, vec2(0,0));
                     float t = atan2(coord.y, coord.x) + 2.0 * PI * fract(time * 3);
                bool hit = _InnerCircle <= r && r <= _OuterCircle;
                     float st = sin(t);
                    if (!hit || st <= _Offset) {
                    //discard;
                    }

                
                 float blend = (cos(t) + 1.0) / 2.0;
                blend *= smoothstep(_InnerCircle, _InnerCircle+ _AntiAliasingEdge, r);
                blend *= (1.0 - smoothstep(_OuterCircle - _AntiAliasingEdge, _OuterCircle, r));
                
                return color * blend;
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
