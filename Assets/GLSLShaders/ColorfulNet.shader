//http://glslsandbox.com/e#23803.0
Shader "Unlit/ColorfulNet"
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

            uniform vec2 _Mouse;
            uniform vec2 _Resolution;

            #define PI 3.14159
            #define COUNT 70

            float sin01( float a )
            {
                return ( sin( a ) + 1.0 ) * 0.5;
            }

            vec4 calc( vec2 surfacePosition, float range, float color_mul )
            {
                vec4    color;
                surfacePosition=surfacePosition+_Mouse;
                float   x = surfacePosition.x * PI;
                float   sinx1 = sin( 0.7 * x + time * 2.0 );
                
                for( int i = 0; i < COUNT; ++i )
                {       
                    
                    float   y = surfacePosition.y * ( 6.0 + 2.0 * sin01( float( i ) * 4.0 ) );
                    float   desired_y = ( sin( ( x + float( i ) ) + time * 2.0 ) + sinx1 ) * float( i + 1 ) * 0.04;
                    float   diff_y = abs( y - desired_y );
                    float   cur_range = range + range * sin01( time * 2.0 );
                    float cur_rangeDiff=( cur_range - diff_y ) / cur_range;
                    color += ( vec4( sin01( time + float( i ) ), sin01( float( i * i ) ), sin01( float( i ) ), 1.0 )
                        * ( diff_y <= cur_range ? vec4( cur_rangeDiff,cur_rangeDiff,cur_rangeDiff,cur_rangeDiff ) : vec4( 0,0,0,0 ) ) ) * color_mul;
                }

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
			
			fixed4 frag (v2f input) : SV_Target
			{
                return calc(input.uv, 1.0, 1.0 / 70.0 )
                    + calc(input.uv, 0.01, 1.0 / 5.0 );
			}
			ENDCG
		}
	}
}
