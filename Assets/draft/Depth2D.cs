using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Depth2D : MonoBehaviour {

	// Use this for initialization
	void Start () {
		Material mat = GetComponent<Renderer> ().material;
		Texture tex = mat.mainTexture;
		RenderTexture rt = new RenderTexture (tex.width, tex.height, 0);
		rt.enableRandomWrite = true;
		mat.SetTexture ("_RWTexture",rt);
	}


}
