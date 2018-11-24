//http://glslsandbox.com/e#42554.0
Shader "Unlit/ColorfulSinLine"
{
	Properties
	{
        _ColorBg("ColorBg",Color)=(0.0, 0.0, 0.30)
        _ColorBlock("ColorBlock",Color)=(0.50, .0, 0.0)
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Intensity("Intensity",float)=1
        _Speed("_Speed",float)=0.03
        _BlockWidth("BlockWidth",float)=0.03
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
            float _Intensity;
            float _Speed;

            float4 ColorBg;
            float4 _ColorBlock ;
            float _BlockWidth; 

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
				vec2 position = ( input.uv.xy / _Resolution.xy );
                
                vec3 color = vec3(0,0,0);

                // 取余，留下奇数区域
                float c1 = fmod(position.x, 2.0 * _BlockWidth);
                //Returns (x >= a) ? 1 : 0
                c1 = step(_BlockWidth, c1);

                float c2 = fmod(position.y, 2.0 * _BlockWidth);
                //Returns (x >= a) ? 1 : 0
                c2 = step(_BlockWidth, c2);
                
                color += lerp( position.y * ColorBg,  position.y * _ColorBlock, c1 * c2);

                //使用这个方法可以收缩波形范围
                position = 2*position-1;
                float lineWidth = 0.0;
                //将波形向上偏移
                vec2 sPos = position;
                for( float i = 0.0; i < 13.; i++) {
                    sPos.y += (0.07 * sin(position.x + i/5.0+ time*_Speed));

                    float lineWidth = abs(1.0 / sPos.y)*_Intensity;
                    color += vec3( lineWidth*(7.0-i)/7.0, lineWidth*i/10.0, pow(lineWidth,0.9)*1.5 );
                    
                }
                
                return vec4(color, 1.0);
			}
			ENDCG
		}
	}
}
