//http://glslsandbox.com/e#20507.0
Shader "Unlit/TornadoBubble"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
        _Scale("Scale",float)=64
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

            uniform float _Scale;
            uniform vec2 _Mouse;
            uniform vec2 _Resolution;



            vec4 tornado(vec2 gl_FragCoord ){
                vec2 p = (gl_FragCoord.yx / _Resolution.yx) - .5;

                float sx = 0.3 * (p.x+ 0.8) * sin(900.0 * p.x - 1. * pow(time, 0.55)*5.);
                
                float dy = 4. / ( 500.0 * abs(p.y - sx));
                
                dy += 1./ (25. * length(p - vec2(p.x, 0)));
                
                return vec4((p.x + 0.1) * dy, 0.3 * dy, dy, 1.1);   
            }

            vec4 bubble(vec2 gl_FragCoord){

                vec2 uv = -1.0 + 2.0*gl_FragCoord.xy / _Resolution.xy;
                uv.x *= _Resolution.x / _Resolution.y;

                // background    
            //  vec3 color = vec3(0.9 + 0.2*uv.y);
                vec3 color = vec3(1.0,1.0,1.0);

                // bubbles  
                for( int i=0; i<64; i++ )
                {
                    // bubble seeds
                    float pha =      sin(float(i)*546.13+1.0)*0.5 + 0.5;
                    float siz = pow( sin(float(i)*651.74+5.0)*0.5 + 0.5, 4.0 );
                    float pox =      sin(float(i)*321.55+4.1) * _Resolution.x / _Resolution.y;

                    // buble size, position and color
                    float rad = 0.1 + 0.5*siz+sin(time/6.+pha*500.+siz)/20.;
                    vec2  pos = vec2( pox+sin(time/10.+pha+siz), -1.0-rad + (2.0+2.0*rad)
                                     *fmod(pha+0.1*(time/5.)*(0.2+0.8*siz),1.0));
                    float dis = length( uv - pos );
                    vec3  col = lerp( vec3(0.194*sin(time/6.0),0.3,0.0), 
                                    vec3(1.1*sin(time/9.0),0.4,0.8), 
                                    0.5+0.5*sin(float(i)*1.2+1.9));
                          //col+= 8.0*smoothstep( rad*0.95, rad, dis );
                    
                    // render
                    float f = length(uv-pos)/rad;
                    f = sqrt(clamp(1.0-f*f,0.0,1.0));
                    color -= col.zyx *(1.0-smoothstep( rad*0.95, rad, dis )) * f;
                }

                // vigneting    
                //color *= sqrt(1.5-0.5*length(uv));

                return vec4(color,1.0);
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
				return tornado(i.uv) + bubble(i.uv);
			}
			ENDCG
		}
	}
}
