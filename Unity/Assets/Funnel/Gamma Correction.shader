Shader "Hidden/Gamma Correction"
{
    Properties
    {
        _MainTex("-", 2D) = ""{}
    }

CGINCLUDE

#include "UnityCG.cginc"

sampler2D _MainTex;

half3 linear_to_srgb(half3 lin)
{
    return max(1.055 * pow(lin, 0.41666667) - 0.055, 0);
}

half4 frag(v2f_img i) : SV_Target
{
    half4 c = tex2D(_MainTex, i.uv.xy);
    c.rgb = linear_to_srgb(c.rgb);
    return c;
}

ENDCG

    SubShader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            Fog { Mode off }
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
