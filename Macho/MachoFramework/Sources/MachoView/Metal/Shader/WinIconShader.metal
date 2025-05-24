//
//  MachoFramework
//
//  WinIconShader.metal
//
//  Created by stotic-dev on 2025/05/24
//  Copyright © Macho All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 winIconShader(
    float2 position,
    half4 color,
    float2 size,
    float time
) {
    constexpr float speed = 0.6;
    constexpr float glossWidth = 0.15;
    
    float2 uv = position / size;
    
    // 擬似的な光源の向き（右上から照らす）
    float2 lightDir = normalize(float2(1.0, 0));

    // 表面の「法線」を疑似的に位置から生成
    float2 normal = normalize(uv);

    // 光源と法線の内積（0〜1の光のあたり具合）
    float highlight = dot(normal, lightDir);

    // ハイライトの動き（時間で流れる）
    float glossAnim = fmod(time * speed, 1.0);
    
    // ハイライトの位置がスクリーン上をスライド
    float glossPos = smoothstep(glossAnim - glossWidth, glossAnim, highlight)
                   * (1.0 - smoothstep(glossAnim, glossAnim + glossWidth, highlight));

    // 光沢を白く加算（やや青白い光でもOK）
    half3 glossyColor = color.rgb + half3(1.0) * half(glossPos) * 0.5;

    return half4(min(glossyColor, 1.0), color.a);
}
