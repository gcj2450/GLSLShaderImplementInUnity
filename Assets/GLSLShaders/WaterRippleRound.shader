//http://glslsandbox.com/e#14354.1
//http://glslsandbox.com/e#13679.1
Shader "Unlit/WaterRippleRound"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
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

            uniform vec2 _Resolution;
            float _Scale;
            // drip test --joltz0r

            float check (vec2 p, float size) {
                float c = float(int(floor(cos(p.x/size)*10000.0)*ceil(cos(p.y/size)*10000.0)))*0.0001;
                return clamp(c, 0.3, 0.7);
            }
            vec4 main( vec2 gl_FragCoord ) {

                vec2 p = (( gl_FragCoord.xy / _Resolution.xy ) - 0.5) * _Scale;
                p.x *= _Resolution.x/_Resolution.y;
                vec2 i = p;
                
                float c = 0.0;
                    vec2 sc = vec2(sin(time*0.54), cos(time*0.56));
                    
                float d = length(p)*10.0;
                float r = atan2(p.x, p.y);
                float len = (1.0-length(p*0.5));
                float dist = (1.0-sin(pow(d,1.25)+(cos(d-time*2.5)*4.0)));
                float pc = check(p, 0.125);
                    i += vec2(dist*0.05,dist*0.05);
                float ic = check(i, 0.125);

                c = 1.0/((length(p+sc)*pc)+((length(i+sc)*ic*8.0)));
                return vec4( vec3(c,c,c), 1.0 );

            }

            vec4 main2( vec2 gl_FragCoord ) {

                vec2 p = (( gl_FragCoord.xy / _Resolution.xy ) - 0.5) * _Scale;
                p.x *= _Resolution.x/_Resolution.y;

                    // pixel size with aspect correction
                vec2 ps = 1.0/_Resolution;
                ps.x *= _Resolution.x/_Resolution.y;

                vec2 i = p;
                
                float c = 0.0;
                    vec2 sc = vec2(sin(time*0.54), cos(time*0.56));
                    
                float d = length(p)*10.0;
                float r = atan2(p.x, p.y);
                float len = (1.0-length(p*0.5));
                float dist = len*(1.0-sin(pow(d,1.25)+(cos(d-time*2.5)*4.0)));
                float pc = check(p, 0.125);
                    i += vec2(dist*0.05,dist*0.05)/length(p);
                float ic = check(i, 0.125);

                c = 1.0/((length(p+sc)*pc)+((length(i+sc)*ic*8.0)));
                return vec4( vec3(c,c,c), 1.0 );

            }


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv =v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                //两种水波纹
                //return main(i.uv);
				return main2(i.uv);
			}
			ENDCG
		}
	}
}
