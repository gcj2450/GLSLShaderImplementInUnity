//from https://www.shadertoy.com/view/4dl3zn
//http://glslsandbox.com/e#46606.0
Shader "Unlit/ElegantMoveSphere"
{
	Properties
	{
        _Color("ColorTint",Color)=(0.2,0.01,0.1,1)
        _Resolution ("Resolution", Vector) = (0,1,0,1)
        
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
            #define mix lerp

            #ifdef GL_ES
            precision mediump float;
            #endif

            //#extension GL_OES_standard_derivatives : enable
            vec4 _Color;
            uniform vec2 mouse;
            uniform vec2 _Resolution;

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

                vec2 uv = -1.0 + 2.0*input.uv.xy / _Resolution.xy;
                uv.x *=  _Resolution.x / _Resolution.y;

                // background    
                vec3 color = vec3(0.8 + 0.2*uv.y,0.8 + 0.2*uv.y,0.8 + 0.2*uv.y);

                // bubbles  
                for( int i=0; i<40; i++ )
                {
                    // bubble seeds
                    float pha =      sin(float(i)*546.13+1.0)*0.5 + 0.5;
                    float siz = pow( sin(float(i)*651.74+5.0)*0.5 + 0.5, 4.0 );
                    float pox =      sin(float(i)*321.55+4.1) * _Resolution.x / _Resolution.y;

                    // buble size, position and color
                    float rad = 0.1 + 0.5*siz;
                    vec2  pos = vec2( pox, -1.0-rad + (2.0+2.0*rad)*fmod(pha+0.1*time*(0.2+0.8*siz),1.0));
                    float dis = length( uv - pos );
                    vec3  col = mix( vec3(0.5,0.4,0.1), vec3(0.1,0.4,0.8), 0.5+0.5*sin(float(i)*1.2+1.9));
                    //更改这句可以改变色调
                    col = mix( _Color.rgb, col, 0.5+0.5*sin(float(i*i)*-.125+4.9));
                    //打开这句可以描边
                    //    col+= 8.0*smoothstep( rad*0.95, rad, dis );
                    
                    // render
                    float f = length(uv-pos)/rad;
                    f = sqrt(clamp(1.0-f*f,0.0,1.0));
                    color -= col.zyx *(1.0-smoothstep( rad*0.95, rad, dis )) * f-0.04/(10.0+color);
                }

                // vigneting    
                color *= sqrt(1.5-0.5*length(uv));

                return vec4(color,1.0);
			}
			ENDCG
		}
	}
}
