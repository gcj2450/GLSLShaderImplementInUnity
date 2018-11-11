//http://glslsandbox.com/e#21861.0
Shader "Unlit/CrossRuler"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
        _Scale ("Scale", float) = 1
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

            vec4 main( in vec2 gl_FragCoord) {
                
                vec2 position = floor( gl_FragCoord.xy*_Scale);
                
                float color = 0.0;;
                //Y Axis
                float strip = fmod(floor(position.y / 10.0), 10.0);
                if (fmod(position.y, 10.0) <0.1){
                    if (abs(strip - 5.0) < 0.1){
                        if ((position.x>10.0)&&(position.x<40.0)) color=1.0;
                    }else if(abs(strip) < 0.1) {
                        if (position.x<40.0) color=1.0;
                    }else {
                        if ((position.x>20.0)&&(position.x<40.0)) color=1.0;
                    }
                }
                //X Axis
                 strip = fmod(floor(position.x / 10.0), 10.0);
                 if (fmod(position.x, 10.0) <0.1){
                    if (abs(strip - 5.0) < 0.1){
                        if ((position.y>10.0)&&(position.y<40.0)) color=1.0;
                    }else if(abs(strip) < 0.1) {
                        if (position.y<40.0) color=1.0;
                    }else {
                        if ((position.y>20.0)&&(position.y<40.0)) color=1.0;
                    }
                }

                if (abs(position.y-_Mouse.y*_Resolution.y)<0.5) color=1.0;
                if (abs(position.x-_Mouse.x*_Resolution.x)<0.5) color=1.0;
                    
                

                return vec4( vec3( color, color, color* 0.75 ), 1.0 );

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
