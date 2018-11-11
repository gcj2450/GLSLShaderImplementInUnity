//http://glslsandbox.com/e#23745.0
Shader "Unlit/SnowMountain"
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
            #define  m2  float2x2(0.8,-0.6,0.6,0.8)
            
            //precision mediump float; 
            uniform vec2 _Resolution;
            uniform vec4 _Mouse;
            const float pi = 3.141592653589793;
            float hash( in vec2 p ) 
            {
                return fract(sin(p.x*15.32+p.y*35.78) * 43758.23);
            }

            vec3 noised( in vec2 p ) 
            {
                    
                vec2 g = floor(p);
                vec2 f = fract(p);
                vec2 k = f*f*(3.0-2.0*f);
                float a = hash(g+vec2(0.0,0.0));
                float b = hash(g+vec2(1.0,0.0));
                float c = hash(g+vec2(0.0,1.0));
                float d = hash(g+vec2(1.0,1.0));
                return vec3(a+(b-a)*k.x+(c-a)*k.y+(a-b-c+d)*k.x*k.y,
                            6.0*f*(1.0-f)*(vec2(b-a,c-a)+(a-b-c+d)*k.yx));
            }
            vec3 light1 = normalize( vec3(-0.8,0.1,-0.3) );


            float terrain( in vec2 x )
            {
                vec2  p = x*0.003;
                float a = 0.0;
                float b = 1.0;
                vec2  d = vec2(0,0);
                for( int i=0; i<5; i++ )
                {
                    vec3 n = noised(p);
                    d += n.yz;
                    a += b*n.x/(1.0+dot(d,d));
                    b *= 0.5;
                    p = mul(m2,p)*2.0;
                }

                return 140.0*a;
            }

            float terrain2( in vec2 x ) 
            {
                vec2  p = x*0.003;
                float a = 0.0;
                float b = 1.0;
                vec2  d = vec2(0,0);
                for( int i=0; i<11; i++ ) {
                    vec3 n = noised(p);
                    d += n.yz;
                    a += b*n.x/(1.0+dot(d,d));
                    b *= 0.5;
                    p = mul(m2,p)*2.0;
                }

                return 140.0*a;
            }

            float map( in vec3 p )
            {
                return p.y - terrain(p.xz);
            }

            float interesct( in vec3 ro, in vec3 rd, in float tmin, in float tmax )
            {
                float t = tmin;
                for( int i=0; i<120; i++ )
                {
                    float h = map( ro + t*rd );
                    if( h<(0.002*t) || t>tmax ) break;
                    t += 0.5*h;
                }

                return t;
            }

            float softShadow(in vec3 ro, in vec3 rd )
            {
                // real shadows 
                float res = 1.0;
                float t = 0.001;
                for( int i=0; i<48; i++ )
                {
                    vec3  p = ro + t*rd;
                    float h = map( p );
                    res = min( res, 16.0*h/t );
                    t += h;
                    if( res<0.001 ||p.y>200.0 ) break;
                }
                return clamp( res, 0.0, 1.0 );
            }

            vec3 calcNormal( in vec3 pos, float t )
            {
                vec2  eps = vec2( 0.002*t, 0.0 );
                return normalize( vec3( terrain2(pos.xz-eps.xy) - terrain2(pos.xz+eps.xy),
                                        2.0*eps.x,
                                        terrain2(pos.xz-eps.yx) - terrain2(pos.xz+eps.yx) ) );
            }

            vec3 camPath( float _time )
            {
                return 1100.0*vec3( cos(0.10-0.23*_time), 0.0, cos(1.5+0.21*_time) );
            }

            float fbm( vec2 p )
            {
                float f = 0.0;
                f += 0.5000*noised(p).x; p = mul(m2,p)*2.02;
                f += 0.2500*noised(p).x; p = mul(m2,p)*2.03;
                f += 0.1250*noised(p).x; p = mul(m2,p)*2.01;
                f += 0.0625*noised(p).x;
                return f/0.9375;
            }

            vec4 main(in vec2 gl_FragCoord)
            {
                vec2 xy = -1.0 + 2.0*gl_FragCoord.xy/_Resolution.xy;
                vec2 s = xy*vec2(_Resolution.x/_Resolution.y,1.0);

                vec3 light1 = normalize( vec3(-0.8,0.4,-0.3) );

                // camera position
                vec3 ro = vec3(1.0,1,1);
                ro.x += time*9.0;
                vec3 ta = vec3(1.0,1,1);
                ro.y = 200.0;
                ta.y = ro.y - 20.0;
                float cr = 0.0;

                // camera ray    
                vec3  cw = normalize(ta-ro);
                vec3  cp = vec3(sin(cr), cos(cr),0.0);
                vec3  cu = normalize( cross(cw,cp) );
                vec3  cv = normalize( cross(cu,cw) );
                vec3  rd = normalize( s.x*cu + s.y*cv + 2.0*cw );

                // bounding plane
                float tmin = 2.0;
                float tmax = 2000.0;
                float maxh = 210.0;
                float tp = (maxh-ro.y)/rd.y;
                if( tp>0.0 )
                {
                    if( ro.y>maxh ) tmin = max( tmin, tp );
                    else            tmax = min( tmax, tp );
                }

                float sundot = clamp(dot(rd,light1),0.0,1.0);
                vec3 col=vec3(0,0,0);
                float t = interesct( ro, rd, tmin, tmax );
                if( t>tmax)
                {
                    // sky      
                    col = vec3(0.3,.55,0.8)*(1.0-0.8*rd.y)*0.9;
                    // sun
                    col += 0.25*vec3(1.0,0.7,0.4)*pow( sundot,5.0 );
                    col += 0.25*vec3(1.0,0.8,0.6)*pow( sundot,64.0 );
                    col += 0.2*vec3(1.0,0.8,0.6)*pow( sundot,512.0 );
                    // clouds
                    vec2 sc = ro.xz + rd.xz*(1000.0-ro.y)/rd.y;
                    col = lerp( col, vec3(1.0,0.95,1.0), 0.5*smoothstep(0.5,0.8,fbm(0.0005*sc)) );
                    // horizon
                    col = lerp( col, vec3(0.7,0.75,0.8), pow( 1.0-max(rd.y,0.0), 8.0 ) );
                }
                else
                {
                    // mountains        
                    vec3 pos = ro + t*rd;
                    vec3 nor = calcNormal( pos, t );
                    vec3 ref = reflect( rd, nor );
                    float fre = clamp( 1.0+dot(rd,nor), 0.0, 1.0 );
                    
                    // rock
                    float r = hash(127.0*pos.xz);
                    //col = (r*0.25+0.75)*0.9*mix( vec3(0.08,0.05,0.03), vec3(0.10,0.09,0.08), hash(0.00007*vec2(pos.x,pos.y*48.0)));
                    //col = mix( col, 0.20*vec3(0.45,.30,0.15)*(0.50+0.50*r),smoothstep(0.70,0.9,nor.y) );
                    //col = mix( col, 0.15*vec3(0.30,.30,0.10)*(0.25+0.75*r),smoothstep(0.95,1.0,nor.y) );

                    // snow
                    float h = smoothstep(55.0,80.0,pos.y + 25.0*fbm(0.01*pos.xz) );
                    float e = smoothstep(1.0-0.5*h,1.0-0.1*h,nor.y);
                    float o = 0.3 + 0.7*smoothstep(0.0,0.1,nor.x+h*h);
                    float s = h*e*o;
                    col = lerp( col, 0.29*vec3(0.62,0.65,0.7), smoothstep( 0.1, 0.9, s ) );
                    
                     // lighting        
                    float amb = clamp(0.5+0.5*nor.y,0.0,1.0);
                    float dif = clamp( dot( light1, nor ), 0.0, 1.0 );
                    float bac = clamp( 0.2 + 0.8*dot( normalize( vec3(-light1.x, 0.0, light1.z ) ), nor ), 0.0, 1.0 );
                    float sh = 1.0; if( dif>=0.0001 ) sh = softShadow(pos+light1*20.0,light1);
                    
                    vec3 lin  = vec3(0,0,0);
                    lin += dif*vec3(7.00,5.00,3.00)*vec3( sh, sh*sh*0.5+0.5*sh, sh*sh*0.8+0.2*sh );
                    lin += amb*vec3(0.40,0.60,0.80)*1.2;
                    lin += bac*vec3(0.40,0.50,0.60);
                    col *= lin;
                    
                    col += s*0.1*pow(fre,4.0)*vec3(7.0,5.0,3.0)*sh * pow( clamp(dot(light1,ref), 0.0, 1.0),16.0);
                    col += s*0.1*pow(fre,4.0)*vec3(0.4,0.5,0.6)*smoothstep(0.0,0.6,ref.y);

                    // fog
                    float fo = 1.0-exp(-0.0000011*t*t );
                    vec3 fco = 0.8*vec3(0.5,0.7,0.9) + 0.1*vec3(1.0,0.8,0.5)*pow( sundot, 4.0 );
                    col = lerp( col, fco, fo );

                    // sun scatter
                    col += 0.3*vec3(1.0,0.8,0.4)*pow( sundot, 818.0 )*(1.0-exp(-0.002*t));
                }

                // gamma
                col = pow(col,vec3(0.4545,0.4545,0.4545));

                // vignetting   
                col *= 0.5 + 0.5*pow( (xy.x+1.0)*(xy.y+1.0)*(xy.x-1.0)*(xy.y-1.0), 0.1 );
                
                return vec4(col,1.0);
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
