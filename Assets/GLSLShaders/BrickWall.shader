//simple brick scene
//http://glslsandbox.com/e#28152.0
//intended to be scaled with nearest neighbour filtering
//mattdesl - http://devmatt.wordpress.com/
Shader "Unlit/BrickWall"
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

            uniform vec2 _Resolution;
            uniform vec2 _Mouse;

            float rand(vec2 co){
                return fract(sin(dot(co, vec2(12.9898,78.233))) * 43758.5453);
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
				float bw = 16.0;
                float bh = 32.0;
                float lw = 1.0;
                float x = input.uv.x;
                float y = input.uv.y;
                x *= _Mouse.x * 250.0;
                y *= _Mouse.y * 500.0;
                float bx = fmod(y, bh*2.0) < bh ? x + bw/2.0 : x;
                
                float xbw = fmod(bx, bw);
                float ybh = fmod(y, bh);
                float TW = _Resolution.x/bw+1.0;
                float TH = _Resolution.y/bh+1.0;
                
                vec3 normals = vec3(0.0, 0.0, 1.0);
                
                //bit of faux randomization
                float xpos = floor(fmod(floor(bx/bw), TW));
                float ypos = floor(fmod(floor(y/bh), TH));
                vec3 color = vec3(0.25 + rand(vec2(xpos, ypos))*0.25,
                                            0.25 + rand(vec2(xpos, ypos))*0.25,
                                            0.25 + rand(vec2(xpos, ypos))*0.25);
                
                normals.x = ((xbw/bw)*2.0-1.0)*.25;
                normals.y = ((ybh/bh)*2.0-1.0)*.25;
                
                //adapted from a software solution.. lots of ifs and shit
                if ( xbw >= bw-2.0)
                    normals.x += 0.25;
                else if ( xbw <= 2.0)
                    normals.x -= 0.5;
                else if ( ybh >= bh-3.0)
                    normals.y += 0.25;
                if ( ybh <= 2.0)
                    normals.y -= 0.25;
                
                color.r += .08;
                    
                //mortar
                if ( fmod(y+lw, bh) < lw || fmod(bx, bw) < lw ) {
                    color = vec3(0.85,0.85,0.85); 
                    normals = vec3(0.0, 0.0, 1.0);
                } 
                
                vec3 lightPos =  vec3(_Mouse.xy - (input.uv.xy/_Resolution.xy), 0.2); //vec3(_Mouse - vec2(0.5, 0.5), 0.5);
                vec3 L = normalize(lightPos);
                vec3 N = normalize(normals);
                
                float dist = sqrt(dot(lightPos, lightPos));
                vec3 att = vec3(2.3,-16.,37.5);
                
                float lambert = clamp(dot(N, L), 0.0, 1.0);
                float shadow = 1.0/(att.x + (att.y*dist) + (att.z*dist*dist));
                vec3 finalColor = vec3(0,0,0);
                
                finalColor += color ;

                
                
                return vec4(finalColor, 1.0);
			}
			ENDCG
		}
	}
}
