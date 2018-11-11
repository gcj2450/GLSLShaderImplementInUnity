//http://glslsandbox.com/e#29612.2
//http://glslsandbox.com/e#12228.1
Shader "Unlit/MathFxDiagram"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
        _Scale("Scale",float)=2
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

            vec3 Line(vec2 p1,vec2 p2,float r,vec2 px)
            {
                float c = 0.0;
                vec2 n = normalize((p2-p1).yx)*vec2(-1,1);  
                vec2 d = normalize((p2-p1));    
                c = 1.0 - abs( dot(n,px-p1) / r );
                c *= clamp( (dot(d,px-p1) * dot(-d,px-p2)) * 0.1 , 0.0, 1.0);
                c = clamp(c, 0.0, 1.0); 
                return vec3(c,c,c);
            }

            vec4  IsocelesTriangle( vec2  gl_FragCoord) {

                vec2 p = ( gl_FragCoord.xy )*_Scale*290;
                
                vec2 m =vec2(500,90)* _Mouse*_Resolution;

                vec3 c = vec3(0,0,0);
                
                vec2 p1 = _Resolution/2.;
                vec2 p2 = m;
                
                vec2 mid = p1-(p1-p2)/2.0;
                vec2 perp = mid+((p2-p1).yx)*vec2(-1,1);
                
                c = Line(p1,p2,1.5,p);
                c += Line(mid,perp,1.5,p)*vec3(0,1,1);
                c += Line(p1,perp,1.5,p)*vec3(1,0,1);
                c += Line(p2,perp,1.5,p)*vec3(1,0,1);

                return vec4( vec3( c ), 1.0 );

            }

            vec4 TriangleWithCircle(vec2  gl_FragCoord )
            {
                vec2 p = (gl_FragCoord.xy * _Scale - _Resolution) / min(_Resolution.x, _Resolution.y)+_Mouse;
                
                // ring
                float t;
                if(p.y > 0.452)
                {
                    t = 0.0;
                }
                else
                {
                    if(p.y < -0.21)
                    {
                        t=0.0;
                    }
                    else if(p.x < -0.33)
                    {
                        t = 0.0;
                    }
                    else if(p.x > 0.33)
                    {
                        t = 0.0;
                    }
                    else
                    {
                        t = 0.002/abs(p.x)+ 0.002/abs(0.2+p.y) + 0.002/abs(-0.23 +0.5* p.y - p.x) + 
                              0.002/abs(-0.23 +0.5* p.y + p.x) + 0.002/abs(0.2 - length(p));
                    }
                }
                return vec4(vec3(t,0.3, 0.3), 1.0);
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
                return IsocelesTriangle(input.uv)+TriangleWithCircle(input.uv );
                //return  IsocelesTriangle(input.uv);
				//return TriangleWithCircle(input.uv );
			}
			ENDCG
		}
	}
}
