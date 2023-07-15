Shader "GrabPassInvert"
{
    SubShader
    {
        // すべての不透明のジオメトリの後に、自身を描画します
        Tags { "Queue" = "Transparent" }

        // オブジェクトの後ろの画面を _BackgroundTexture 内に取得します
        GrabPass
        {
            "_BackgroundTexture"
        }

        // オブジェクトを上で生成したテクスチャと一緒にレンダリングし、カラーを反転します
        Pass
        {   
            // 外からも、中に入っても、適用されるようにカリングをオフにします
            Cull Off
            // 
            ZTest Always
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 grabPos : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata_base v) {
                v2f o;
                //  UnityCG.cginc の UnityObjectToClipPos  を使って 
                // 頂点のクリップスペースを計算します
                o.pos = UnityObjectToClipPos(v.vertex);
                // UnityCG.cginc の ComputeGrabScreenPos を使って 
                // 正しいテクスチャ座標を取得します
                o.grabPos = ComputeGrabScreenPos(o.pos);
                return o;
            }

            sampler2D _BackgroundTexture;

            half4 frag(v2f i) : SV_Target
            {
                // 例として色反転やっときます
                half4 bgcolor = tex2Dproj(_BackgroundTexture, i.grabPos);
                return 1 - bgcolor;
                // 白黒化にはmaxとかstepとかおすすめです if文は避けるべきらしい
            }
            ENDCG
        }
        // 参考元: https://docs.unity3d.com/ja/2018.4/Manual/SL-GrabPass.html
    }
}