// based on https://www.shadertoy.com/view/lsf3RH
//http://glslsandbox.com/e#43033.0
Shader "Unlit/YellowSun"
{
	Properties
	{
        _Resolution ("Resolution", Vector) = (1,1,0,1)
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
            #define mix lerp

            #ifdef GL_ES
            precision mediump float;
            #endif

            //#extension GL_OES_standard_derivatives : enable

            uniform vec2 _Resolution;

            float snoise(vec3 uv, float res)    // by trisomie21
            {
                const vec3 s = vec3(1e0, 1e2, 1e4);
                
                uv *= res;
                
                vec3 uv0 = floor(fmod(uv, res))*s;
                vec3 uv1 = floor(fmod(uv+vec3(1,1,1), res))*s;
                
                vec3 f = fract(uv); f = f*f*(3.0-2.0*f);
                
                vec4 v = vec4(uv0.x+uv0.y+uv0.z, uv1.x+uv0.y+uv0.z,
                              uv0.x+uv1.y+uv0.z, uv1.x+uv1.y+uv0.z);
                
                vec4 r = fract(sin(v*1e-3)*1e5);
                float r0 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
                
                r = fract(sin((v + uv1.z - uv0.z)*1e-3)*1e5);
                float r1 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
                
                return mix(r0, r1, f.z)*2.-1.;
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
                float brightness    = 1. * 0.25 + 2. * 0.25;
                float radius        = 0.24 + brightness * 0.2;
                float invRadius     = 1.0/radius;
                
                vec3 orange     = vec3( 0.8, 0.65, 0.3 );
                vec3 orangeRed      = vec3( 0.8, 0.35, 0.1 );
                time      = time * 0.1;
                float aspect            = _Resolution.x/_Resolution.y;
                vec2 uv         = 2. * input.uv.xy / _Resolution.xy - 1.; //fragCoord / resolution;
                vec2 p          = -1.5 + uv;
                p.x *= aspect;

                float fade      = pow( length( 2.0 * p ), 0.5 );
                float fVal1     = 1.0 - fade;
                float fVal2     = 1.0 - fade;
                
                float angle     = atan2( p.x, p.y )/6.2832;
                float dist      = length(p);
                vec3 coord      = vec3( angle, dist, time * 0.1 );
                
                float newTime1  = abs( snoise( coord + vec3( 0.0, -time * ( 0.35 + brightness * 0.001 ), time * 0.015 ), 15.0 ) );
                float newTime2  = abs( snoise( coord + vec3( 0.0, -time * ( 0.15 + brightness * 0.001 ), time * 0.015 ), 45.0 ) );  
                for( int i=1; i<=7; i++ ){
                    float power = pow( 2.0, float(i + 1) );
                    fVal1 += ( 0.5 / power ) * snoise( coord + vec3( 0.0, -time, time * 0.2 ), ( power * ( 10.0 ) * ( newTime1 + 1.0 ) ) );
                    fVal2 += ( 0.5 / power ) * snoise( coord + vec3( 0.0, -time, time * 0.2 ), ( power * ( 25.0 ) * ( newTime2 + 1.0 ) ) );
                }
                
                float corona        = pow( fVal1 * max( 1.1 - fade, 0.0 ), 2.0 ) * 50.0;
                corona              += pow( fVal2 * max( 1.1 - fade, 0.0 ), 2.0 ) * 50.0;
                corona              *= 1.2 - newTime1;
                vec3 sphereNormal   = vec3( 0.0, 0.0, 1.0 );
                vec3 dir            = vec3( 0,0,0 );
                vec3 center         = vec3( 0.5, 0.5, 1.0 );
                vec3 starSphere     = vec3( 0,0,0 );
                
                vec2 sp = -1.0 + 2.0 * uv;
                sp.x *= aspect;
                sp *= ( 2.0 - brightness );
                float r = dot(sp,sp);
                float f = (1.0-sqrt(abs(1.0-r)))/(r) + brightness * 0.5;
                if( dist < radius ){
                    corona          *= pow( dist * invRadius, 24.0 );
                    vec2 newUv;
                    newUv.x = sp.x*f;
                    newUv.y = sp.y*f;
                    newUv += vec2( time, 0.0 );
                }
                fixed4 gl_FragColor;
                float starGlow  = min( max( 1.0 - dist * ( 1.0 - brightness ), 0.0 ), 1.0 );
                gl_FragColor.rgb    = vec3( f * ( 0.75 + brightness * 0.3 ) * orange ) + starSphere + corona * orange + starGlow * orangeRed;
                gl_FragColor.a      = 1.0;
                return gl_FragColor;
			}
			ENDCG
		}
	}
}
