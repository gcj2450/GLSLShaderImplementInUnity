Shader "Unlit/BurningFire"
{
	Properties
	{
        _Color("Color",Color)=(1,1,1,1)
		_Resolution ("Resolution", Vector) = (0,1,0,1)
	}
	SubShader
	{
        Blend SrcAlpha OneMinusSrcAlpha
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
            #define vec2 float2
            #define vec3 float3
            #define vec4 float4
            #define mat2 float2x2
            #define mat3 float3x3
            #define mat4 float4x4
            #define iGlobalTime _Time.y
            #define mod fmod
            #define mix lerp
            #define fract frac
            #define texture2D tex2D
         
            #define PI2 6.28318530718
            #define pi 3.14159265358979
            #define halfpi (pi * 0.5)
            #define oneoverpi (1.0 / pi)

            uniform vec4 _Color;
            uniform vec4 _Resolution;

            float noise(vec3 p) //Thx to Las^Mercury
            {
                vec3 i = floor(p);
                vec4 a = dot(i, vec3(1., 57., 21.)) + vec4(0., 57., 21., 78.);
                vec3 f = cos((p-i)*acos(-1.))*(-.5)+.5;
                a = mix(sin(cos(a)*a),sin(cos(1.+a)*(1.+a)), f.x);
                a.xy = mix(a.xz, a.yw, f.y);
                return mix(a.x, a.y, f.z);
            }
             
            float sphere(vec3 p, vec4 spr)
            {
                return length(spr.xyz-p) - spr.w;
            }
             
            float flame(vec3 p)
            {
                float d = sphere(p*vec3(1.,.5,1.), vec4(.0,-1.,.0,1.));
                return d + (noise(p+vec3(.0,iGlobalTime*2.,.0)) + noise(p*3.)*.5)*.25*(p.y) ;
            }
             
            float scene(vec3 p)
            {
                return min(100.-length(p) , abs(flame(p)) );
            }
             
            vec4 raymarch(vec3 org, vec3 dir)
            {
                float d = 0.0, glow = 0.0, eps = 0.02;
                vec3  p = org;
                bool glowed = false;
                
                for(int i=0; i<64; i++)
                {
                    d = scene(p) + eps;
                    p += d * dir;
                    if( d>eps )
                    {
                        if(flame(p) < .0)
                            glowed=true;
                        if(glowed)
                            glow = float(i)/64.;
                    }
                }
                return vec4(p,glow);
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
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f input) : SV_Target
			{
				vec4 fragColor;
                vec2 v = -1.0 + 2.0 * input.uv.xy / _Resolution.xy;
                v.x *= _Resolution.x/_Resolution.y;
                
                vec3 org = vec3(0, -2., 4.);
                vec3 dir = normalize(vec3(v.x*1.6, -v.y, -1.5));
                
                vec4 p = raymarch(org, dir);
                float glow = p.w;
                
                vec4 col = mix(vec4(1.0,0.5,0.1,1.0), vec4(0.1,0.5,1.0,1.0), p.y*0.02+0.4);
                
                fragColor = mix(_Color, col, pow(glow*2,4));
                return fragColor;
			}
			ENDCG
		}
	}
}
