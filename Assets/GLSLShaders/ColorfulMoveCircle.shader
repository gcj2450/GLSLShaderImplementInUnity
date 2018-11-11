//http://glslsandbox.com/e#33621.0
Shader "Unlit/ColorfulMoveCircle"
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

            #ifdef GL_ES
            precision mediump float;
            #endif

            uniform vec2 _Resolution;

            // http://glslsandbox.com/e#10679.0 0 
            //<- original shader this just initializing vars to make it look right on intel gnu / mac
            vec3 color=vec3(0,0,0);

            vec2 center ( vec2 border , vec2 offset , vec2 vel ) {
                vec2 c = offset + vel * time;
                c = fmod ( c , 2. - 4. * border );
                if ( c.x > 1. - border.x ) c.x = 2. - c.x - 2. * border.x;
                if ( c.x < border.x ) c.x = 2. * border.x - c.x;
                if ( c.y > 1. - border.y ) c.y = 2. - c.y - 2. * border.y;
                if ( c.y < border.y ) c.y = 2. * border.y - c.y;
                return c;
            }

            void circle (vec2 uv, float r , vec3 col , vec2 offset , vec2 vel ) {
                vec2 pos = uv.xy / _Resolution.y;
                float aspect = _Resolution.x / _Resolution.y;
                vec2 c = center ( vec2 ( r / aspect , r ) , offset , vel );
                c.x *= aspect;
                float d = distance ( pos , c );
                color += col * ( ( d < r ) ? 0.5 : max ( 0.8 - min ( pow ( d - r , .3 ) , 0.9 ) , -.2 ) );
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
				circle (input.uv, .03 , vec3 ( 0.7 , 0.2 , 0.8 ) , vec2 ( .6,.6 ) , vec2 ( .30 , .70 ) );
                circle (input.uv, .05 , vec3 ( 0.7 , 0.9 , 0.6 ) , vec2 ( .1,.1 ) , vec2 ( .02 , .20 ) );
                circle (input.uv, .07 , vec3 ( 0.3 , 0.4 , 0.1 ) , vec2 ( .1,.1 ) , vec2 ( .10 , .04 ) );
                circle (input.uv, .10 , vec3 ( 0.2 , 0.5 , 0.1 ) , vec2 ( .3,.3 ) , vec2 ( .10 , .20 ) );
                circle (input.uv, .20 , vec3 ( 0.1 , 0.3 , 0.7 ) , vec2 ( .2,.2 ) , vec2 ( .40 , .25 ) );
                circle (input.uv, .30 , vec3 ( 0.9 , 0.4 , 0.2 ) , vec2 ( .0,0 ) , vec2 ( .15 , .20 ) );
                
                return vec4( color, 1.0 );
			}
			ENDCG
		}
	}
}
