// http://glslsandbox.com/e#20670.2
//Created by inigo quilez - iq/2013 : https://www.shadertoy.com/view/4dl3zn
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Messed up by Weyland
// Mouse test by Xenodimensional

Shader "Unlit/ElegantGreenSphere"
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

            vec4 main(in vec2 fragUv)
            {
                vec2 uv = fragUv;
                // background    
            //  vec3 color = vec3(0.9 + 0.2*uv.y);
                vec3 color = vec3(1.0,1.0,1.0);

                // bubbles  
                for( int i=0; i<64; i++ )
                {
                    // bubble seeds
                    float pha =      sin(float(i)*546.13+1.0)*0.5 + 0.5;
                    float siz = _Mouse.y;
                    float pox =      sin(float(i)*321.55+4.1) * _Resolution.x / _Resolution.y;

                    // buble size, position and color
                    float rad = sin(i)*_Mouse.x;
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
                color *= sqrt(1.5-0.5*length(uv));

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
				return main(i.uv);
			}
			ENDCG
		}
	}
}
