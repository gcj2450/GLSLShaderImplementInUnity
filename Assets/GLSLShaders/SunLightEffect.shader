//http://glslsandbox.com/e#29441.0
Shader "Unlit/SunLightEffect"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
        _Scale("Scale",float)=10
        _RotSpeed("RotSpeed",float)=10
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
            float _RotSpeed;

            //return sin in range 0.0 to 1.0 instead of -1.0 to 1.0
            float sin2(float a) {
                return pow(sin(a*.5),2.);
            }
            float karo(float angle) {
                return step(.2,sin2(angle));
            }
            float explosion(float angle) {
                return step(.75+sin(time)*0.15,sin2(angle));
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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv =v.uv;
				return o;
			}
			
			fixed4 frag (v2f input) : SV_Target
			{
				vec2 p =( input.uv+_Resolution)*_Scale;
                float c = 0.;
                float a = atan2(p.x,p.y);
                float r = length(p);
                c = explosion(a*(10.)*1.5+time*_RotSpeed);
                
                vec2 pp = vec2(0.,0.); pp.x *= _Resolution.x/_Resolution.y;
                float dist = distance( pp, p );
                float heat = (.1/ dist);

                    float tmp = pow(heat,3.)*c+heat;
                tmp = min(max(tmp, 0.0), 1.0);
                vec3 cc = vec3(tmp,tmp,tmp);
                return vec4(cc,1)+vec4(0.2,0.4,0.7,1.0);
			}
			ENDCG
		}
	}
}
