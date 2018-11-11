//http://glslsandbox.com/e#30741.0
Shader "Unlit/WhiteStrips"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
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

            //#extension GL_OES_standard_derivatives : enable

            uniform vec2 _Mouse;
            uniform vec2 _Resolution;


            vec4 main( in vec2 gl_FragCoord) {

                float position = ( _Resolution.x / 16.0);
                float aa = fmod(gl_FragCoord.x, position);

                if (aa < 1.){
                                return vec4( vec3( 1, 1.0, 1.0 ), 1.0 );
                } else {
                                return vec4( vec3( 0, 0, 0.0 ), 1.0 );;
                }
                
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
			
			fixed4 frag (v2f input) : SV_Target
			{
				vec2 uv = ( input.uv.xy / _Resolution.xy )+_Mouse;
                float a = 10110101.;
                float b = floor(uv.x*(floor(log(a)+1.)-1.));
                float f = floor(a/pow(10.,b))-(floor(a/pow(10.,b+1.))*10.);
                return vec4(vec3(f,f,f), 2.0 );
                //return main(input.uv);
			}
			ENDCG
		}
	}
}
