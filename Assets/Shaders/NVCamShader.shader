Shader "Custom/NVCamShader"
{
    Properties
    {
        // "Global variables"
        _MainTex ("Texture", 2D) = "white" {}
        [HideInInspector]
        _Tint ("ColourTint", Color) = (0, 0.5, 0, 1.0)
        _Static ("Static Texture", 2D) = "white" {}
        _Noise ("Noise Texture", 2D) = "white" {}
        _Amplitude ("Amplitude", float) = 0
        _Chunkiness ("Chunkiness", float) = 0
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
            fixed4 _Tint;
            sampler2D _Static;
            sampler2D _Noise;
            float _Amplitude;
            float _Chunkiness;
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
                    o.uv.x /= _AspectRatio;
                }

                return o;
            }
            
            // Fragment funtion, converts pixels to colours
            fixed4 frag (v2f i) : SV_Target
            {
                // Holds the new colour value for the pixel
                fixed4 col;

                // Assign the colour based on transformed values of the pixel's original colour
                col.a = tex2D(_MainTex, i.uv).a;
                col.r = tex2D(_MainTex, i.uv).r;
                col.g = tex2D(_MainTex, i.uv).g;
                col.b = tex2D(_MainTex, i.uv).b;

                float random = tex2D(_Noise, _Time).r;
                float2 noiseCoords;

                noiseCoords.x = i.uv.x + random * 5;
                noiseCoords.y = i.uv.y - random * 3;

                col *= _Tint * Luminance(col) * (1 - tex2D(_Static, noiseCoords * _Chunkiness).r  * _Amplitude);

                return col;
            }
            ENDHLSL
        }
    }

    FallBack "Standard"
}
