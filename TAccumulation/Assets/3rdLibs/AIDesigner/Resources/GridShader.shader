Shader "Hidden/AIDesigner/Grid" {
    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"
            fixed4 frag(v2f_img i) : Color {
                return fixed4(0.13, 0.13, 0.13, 1);
            }
            ENDCG
        }
		Pass {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"
            fixed4 frag(v2f_img i) : Color {
                return fixed4(0.13, 0.13, 0.13, 1);
            }
            ENDCG
        }
		Pass {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"
            fixed4 frag(v2f_img i) : Color {
                return fixed4(0.15, 0.15, 0.15, 1);
            }
            ENDCG
        }
		Pass {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"
            fixed4 frag(v2f_img i) : Color {
                return fixed4(0.17, 0.17, 0.17, 1);
            }
            ENDCG
        }
    }
}