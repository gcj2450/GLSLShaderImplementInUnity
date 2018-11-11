//http://glslsandbox.com/e#15229.8
//http://glslsandbox.com/e#14613.3
Shader "Unlit/PopFlower"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Gravity ("Gravity", Vector) = (0,-0.3,0,1)
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

            uniform vec2 _Resolution;
            uniform vec2 _Gravity;
            float _Scale;

            // thank you for this function, anonymous person on the interwebs
            float
            rand(vec2 co)
            {
                return fract(sin(dot(co.xy, vec2(12.9898,78.233)))*43758.5453);
                
                // https://gist.github.com/johansten/3633917
                //float a = fract(dot(co.xy, vec2(2.067390879775102, 12.451168662908249))) - 0.5;
                //float s = a * (6.182785114200511 + a*a * (-38.026512460676566 + a*a * 53.392573080032137));
                //return fract(s * 43758.5453);
            }

            float
            rand(float from, float to, vec2 co)
            {
                return from + rand(co)*(to - from);
            }

            vec4 main(vec2 gl_FragCoord)
            {
                vec2 coord = gl_FragCoord.xy*_Scale;
                
                vec2 origin = vec2(.5*_Resolution.x*_Scale, 0);



                for (float i = 1.; i < 16.; i++) {
                    float period = rand(1.5, 2.5, vec2(i, 0.));

                    float t = time - period*rand(vec2(i, 1.));

                    float particle_time = fmod(t, period);
                    float index = ceil(t/period);

                    vec2 speed = vec2(rand(-.5, .5, vec2(index*i, 3.)), rand(.5, 1., vec2(index*i, 4.)));
                    vec2 pos = origin + particle_time*speed + _Gravity*particle_time*particle_time;

                    float threshold = .7*period;

                    float alpha;
                    if (particle_time > threshold)
                        alpha = 1. - (particle_time - threshold)/(period - threshold);
                    else
                        alpha = 1.;

                    vec4 particle_color = vec4(rand(vec2(i*index, 4.)), rand(vec2(i*index, 5.)), rand(vec2(i*index, 6.)), 1.);

                    float angle_speed = rand(-4., 4., vec2(index*i, 5.));
                    float angle = atan2(pos.y - coord.y, pos.x - coord.x) + angle_speed*time;

                    vec4 gl_FragColor = vec4(0., 0., 0., 0.);

                    //五角星
                    //float radius = rand(.01, .05, vec2(index*i, 2.));
                    //float dist = radius + .3*sin(5.*angle)*radius;
                    //gl_FragColor += alpha*(1. - smoothstep(dist, dist + .01, distance(coord, pos)))*particle_color;

                    //菊花星
                    float radius = rand(.025, .075, vec2(index*i, 2.));
                    float dist = radius + .6*sin(11.*angle)*radius;

                    gl_FragColor += alpha * ((1.0 - smoothstep(dist, dist + .01, distance(coord, pos))) + 
                                              (1.0 - smoothstep(0.01, 0.2, distance(coord, pos)))/2. +
                                              (1.0 - smoothstep(radius * 0.2, radius * 0.4, distance(coord, pos)))) * particle_color;

                                     
                   
                    return gl_FragColor;
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
			
			fixed4 frag (v2f i) : SV_Target
			{
				return main(i.uv);
			}
			ENDCG
		}
	}
}
