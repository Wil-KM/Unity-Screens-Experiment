Shader "Custom/CRTShader"
{
    Properties
    {
        // "Global variables"
        _MainTex ("Texture", 2D) = "white" {}
        _Static ("Static Texture", 2D) = "white" {}
        _Noise ("Noise Texture", 2D) = "white" {}
        _Amplitude ("Amplitude", float) = 0
        _Smoothness ("Smoothness", float) = 0
        _LineWidth ("Line Width", float) = 0
        _Brightness ("Brightness", float) = 0
        _CentreX ("Centre X", float) = 0.5
        _CentreY ("Centre Y", float) = 0.5
        _VinetteRadiusX ("Vinette Radius X", float) = 0
        _VinetteRadiusY ("Vinette Radius Y", float) = 0
        _AspectRatio("Aspect Ratio X/Y", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
    
        // Pass for GPU, main code goes in here
        Pass
        {
            // HLSL code must go in here
            HLSLPROGRAM
            // Compile function vert as a vertex (polygon) shader
            #pragma vertex vert
            // Compile function frag as a fragment (pixel) shader 
            #pragma fragment frag
			
			#include "UnityCG.cginc"

            // Structure for data passed into the shader
            struct appdata
			{
                // Positions of the polygons in the scene
                float4 vertex : POSITION;
                // Positions of pixels on the game screen
                float2 uv : TEXCOORD0;
			};

            // Vertex to fragment structure, returned by v2f function
			struct v2f
			{
                // Positions of pixels on the game screen
				float2 uv : TEXCOORD0;
                // Converted polygon positions
                float4 vertex : SV_POSITION;
			};
            
            sampler2D _MainTex;
            sampler2D _Static;
            sampler2D _Noise;
            float _Amplitude;
            float _Smoothness;
            float _LineWidth;
            float _Brightness;
            float _CentreX;
            float _CentreY;
            float _VinetteRadiusX;
            float _VinetteRadiusY
            ;
            float _AspectRatio;

            // Vertex function, converts polygons to pixels
            v2f vert (appdata v)
            {
                v2f o;
                // Convert the vertices of the object to SV
                o.vertex = UnityObjectToClipPos(v.vertex);
                // Copy over the UV coordinates
                o.uv = v.uv;

                if (_AspectRatio > 1)
                {
                    o.uv.y /= _AspectRatio;
                }
                else
                {
                    o.uv.x *= _AspectRatio;
                }

                return o;
            }
            
            // Fragment funtion, converts pixels to colours
            fixed4 frag (v2f i) : SV_Target
            {
                float2 centreUV = float2(i.uv.x - _CentreX, i.uv.y - _CentreY);

                //i.uv.y += _A * cos(sqrt(centreUV.x * centreUV.x + centreUV.y * centreUV.y) * _D);

                float lineTripleWidth = _LineWidth * 3;
                float heightInTriple = i.uv.y % lineTripleWidth;
                fixed4 col = tex2D(_MainTex, i.uv);

                if (heightInTriple < _LineWidth)
                {
                    col *= fixed4(0.75, 0.75, 1, 1) * _Brightness;
                }
                else if (heightInTriple < _LineWidth * 2)
                {
                    col *= fixed4(0.75, 1, 0.75, 1) * _Brightness;
                }
                else
                {
                    col *= fixed4(1, 0.75, 0.75, 1) * _Brightness;
                }

                col *= (1 - sqrt(centreUV.x * centreUV.x * _VinetteRadiusX + centreUV.y * centreUV.y * _VinetteRadiusY));

                float random = tex2D(_Noise, _Time).r;
                float2 noiseCoords = i.uv.xy + random * 8;

                col *= (1 - tex2D(_Static, noiseCoords * _Smoothness).r  * _Amplitude);

                return col;
            }
            ENDHLSL
        }
    }

    FallBack "Standard"
}
