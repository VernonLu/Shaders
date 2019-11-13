using UnityEngine;

[ExecuteInEditMode]
public class Bloom : MonoBehaviour {
	
	// 高光阈值
	[Range(0f, 4f)] public float m_threshold = 0.4f;
	
	// 降采样率
	[Range(1, 8)] public int m_downSample = 2;

	// 迭代次数
	[Range(0, 4)] public int m_iterations = 3;

	// 模糊扩散量
	[Range(0.2f, 3f)] public float m_blurSpread = 0.6f;

	public Shader shader = null;

	public Material _material = null;


	private void OnRenderImage(RenderTexture src, RenderTexture dest) {
		int w = (int)(src.width / m_downSample);
		int h = (int)(src.height / m_downSample);

		RenderTexture buffer0 = RenderTexture.GetTemporary(w, h);
		RenderTexture buffer1 = RenderTexture.GetTemporary(w, h);
		buffer0.filterMode = FilterMode.Bilinear;
		buffer1.filterMode = FilterMode.Bilinear;

		// 提取亮光图
		_material.SetFloat("_Threshold", m_threshold);
		Graphics.Blit(src, buffer0, _material, 0);

		// 将亮光图高斯模糊化
		for (int i = 0; i < m_iterations; i++) {
			//_material.SetFloat("_BlurSpread", 1 + i * m_blurSpread);

			Graphics.Blit(buffer0, buffer1, _material, 1);
			Graphics.Blit(buffer1, buffer0, _material, 2);
		}

		// 将亮光图与原图混合
		_material.SetTexture("_Bloom", buffer0);
		Graphics.Blit(src, dest, _material, 3);

		RenderTexture.ReleaseTemporary(buffer0);
		RenderTexture.ReleaseTemporary(buffer1);
	}
}