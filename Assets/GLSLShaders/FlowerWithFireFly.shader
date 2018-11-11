//http://glslsandbox.com/e#28521.0
Shader "Unlit/FlowerWithFireFly"
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

            #define pi 3.1415926535897932384626433832795
            #define flyCount 30.


            float testFuncFloor(float v){

                const float amplitude=1.;
                const float t=pi*2.;
                float k=4.*amplitude/t;
                float r=fmod( v  ,t);
                float d=floor(v /(.5* t) );
                
                return lerp(k* r-amplitude ,  amplitude*3.-k* r ,fmod(d,2.)  );
            }

            float getRad(vec2 q){
               return atan2(q.y,q.x); 
            }

            vec2 noise(vec2 tc){
                //return (2.*texture2D(iChannel0, tc).xy-1.).xy;
                return vec2(fract(sin(tc.x) ),fract(sin(tc.y) ) );
            }

            float firefly(vec2 p,float size){
                
                //return smoothstep(0.,size,dot(p,p)*200. );
                return smoothstep(0.,size,length(p) );

            }

            const float pow=1.;
            const float flySpeed=0.1;


            vec3 RetroCrtEffect(vec3 rgb, vec2 texCoord, vec2 resolution)
            {
                const float blendFactor = 0.1; // range (0.0, 1.0]
                float artifact = cos(texCoord.y * resolution.y * 2.0) * 0.5 + 0.5;
                return max(rgb - vec3(artifact * blendFactor,artifact * blendFactor,artifact * blendFactor), vec3(0,0,0));
            }

            void main( in vec2 gl_FragCoord, out vec4 gl_FragColor ) {

                float pow=1.;
                const float duration=1.;
                float t=duration*(1.+sin(3.* time ) );
                vec2 p= gl_FragCoord.xy / _Resolution.xy;
               
                float ratio= _Resolution.y/_Resolution.x;
                
                 vec2 uv=p;
                uv.y*=ratio;
                
                
                vec2 flowerP=vec2(.618,0.518);
                vec2 q=p-flowerP-vec2( pow*.008*cos(3.*time) ,pow*.008*sin(3.*time) ) ;
                vec2 rootP=p-+flowerP-vec2( pow*.02*cos(3.*time)*p.y ,-0.48+pow*.008*sin(3.*time) );
               
                q.y*=ratio;
                
                //sky
                vec3 col=lerp( vec3(0.1,0.6,0.5), vec3(0.2,0.1,0.2), sqrt(p.y)*.6 );
                

                //draw stem 
                float width=0.01;
                float h=.5;
                float w=.0005;
                col=lerp(vec3(.5,.7,.4),col, 1.- (1.- smoothstep(h,h+width, abs(rootP.y ) )  ) * (1.- smoothstep(w,w+width, abs(rootP.x-0.1*sin(4.*rootP.y+pi*.35) ) )  ) );
                
                //draw flower 
                vec3 flowerCol=lerp(vec3(.7,.7,.2),vec3(.7,.9,.7), smoothstep( .0,1.,length(q)*10. ) ) ;

                const float edge=.02;
                float r= .1+0.05*( testFuncFloor( getRad( q ) *7.  + 2.*q.x*(t-duration)  )  );

                col=lerp(flowerCol,col, smoothstep(r,r+edge,  length( q )  ) );
                
                //draw buds
                float r1=0.;
                r1=.04;
                vec3 budCol=lerp (vec3(.3,.4,0.),vec3(.9,.8,0.), length(q)*10. );
                col=lerp(budCol,col, smoothstep(r1,r1+0.01,  length( q )  ) );
                
                //draw firefly
                //vec3 flyCol=lerp (vec3(.1,.4,0.1),vec3(.1,1.,1.), length(q)*10. );
                
                for (float i=0.;i<flyCount;i++){
                    
                    float seed=i/flyCount;
                float seed2=fract(i/flyCount*5.);
                    float t1=1.*(1.+sin(noise(vec2(seed,seed) ).x* time ) );
                    vec2 fireflyP=uv- 
                        vec2(noise(vec2(seed2,seed2) ).x+noise(vec2(seed2,seed2) ).x*t1*flySpeed,
                         noise(vec2(seed,seed) ).y+noise(vec2(seed,seed) ).y*t1*flySpeed);
                    
                    float fly= firefly( fireflyP,.002+.008*seed );
                    vec3 flyCol=lerp(vec3(0.1,0.9,0.1)*t1,vec3(0,0,0), fly );
                    col+=flyCol;
                }

                //vec3 color = RetroCrtEffect(col, uv, _Resolution.xy);
                vec3 color = col;

                
                gl_FragColor= vec4(color, 1.0);
                /*
                vec2 position = ( gl_FragCoord.xy / _Resolution.xy ) + mouse / 4.0;

                float color = 0.0;
                color += sin( position.x * cos( time / 15.0 ) * 80.0 ) + cos( position.y * cos( time / 15.0 ) * 10.0 );
                color += sin( position.y * sin( time / 10.0 ) * 40.0 ) + cos( position.x * sin( time / 25.0 ) * 40.0 );
                color += sin( position.x * sin( time / 5.0 ) * 10.0 ) + sin( position.y * sin( time / 35.0 ) * 80.0 );
                color *= sin( time / 10.0 ) * 0.5;

                gl_FragColor = vec4( vec3( color, color * 0.5, sin( color + time / 3.0 ) * 0.75 ), 1.0 );
                */
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
                float4 fCol;
				main( i.uv, fCol );
                return fCol;
			}
			ENDCG
		}
	}
}
