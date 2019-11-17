using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class Vortex : MonoBehaviour
{
	public float angle = 0;
	public float radius = 0.1f;
	Material mat;
	void Start() {
		mat = this.GetComponent<Image>().material;

		//延迟2秒开始，每隔0.2s调用一次
		InvokeRepeating("DoSwirl", 0, 0.2f);
	}

	void DoSwirl() {
		angle += 1f;
		radius += 0.1f;

		mat.SetFloat("_Angle", angle);
		mat.SetFloat("_Radius", radius);

		//rest
		if (radius >= 0.6f) {
			angle = 0;
			radius = 0.1f;
		}
	}
}