using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class cameradeapth : MonoBehaviour {
    public Material mat;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, mat);
    }
}
