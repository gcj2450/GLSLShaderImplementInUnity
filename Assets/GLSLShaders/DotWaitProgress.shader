//http://glslsandbox.com/e#10866.1
Shader "Unlit/DotWaitProgress"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
        _R0("R0",float)=0.75
        _R1("R1",float)=0
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
            float _R0;
            float _R1;
            float _Offset;

            const float PI= 3.14159265358979323846264;

            vec4 main(vec2 gl_FragCoord) {
                vec2 c = ( gl_FragCoord.xy / min(_Resolution.x, _Resolution.y) - vec2(0.5,0.5)) * 3.0;
                 vec4 color = vec4(0.196, 0.666, 0.929, 1.0);
                 float r = distance(c, vec2(0,0));
                 float t = atan2(c.y, c.x);

                 vec2 p0 = vec2(cos(_Offset + 0.0),           sin(_Offset + 0.0))          * _R0;
                 vec2 p1 = vec2(cos(_Offset + PI / 4.0),          sin(_Offset + PI / 4.0))         * _R0;
                 vec2 p2 = vec2(cos(_Offset + PI / 2.0),          sin(_Offset + PI / 2.0))         * _R0;
                 vec2 p3 = vec2(cos(_Offset + PI / 4.0 + PI / 2.0),   sin(_Offset + PI / 4.0 + PI / 2.0))  * _R0;
                
                 vec4 d1 = vec4(distance(p0, c), distance(p1, c), distance(p2, c), distance(p3, c));
                 vec4 d2 = vec4(distance(-p0, c), distance(-p1, c), distance(-p2, c), distance(-p3, c));
                 vec4 d = min(d1, d2);
                 float dist = min(min(d[0], d[1]), min(d[2], d[3]));
                    if (dist > _R1) {
                        discard;
                    }
                
                 float phase = 2.0 * PI * fract(time * 0.8);
                 float angle = atan2(c.y, c.x);
                    angle = floor((PI / 8.0 + 2.0 * PI - angle) / PI / 4.0) * PI / 4.0;
                     float blend = fract((angle - phase) / 2.0 * PI);
                blend = blend * (1.0 - smoothstep(_R1 - 0.01, _R1, dist));
                
                return color;
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
