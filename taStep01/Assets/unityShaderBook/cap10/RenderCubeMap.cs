using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RenderCubeMap : MonoBehaviour
{
    public Cubemap cubemap;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    [ContextMenu("生成CubeMap")]
    void doRender()
    {
        GameObject go = new GameObject("CubemapCamera");
        Camera camera = go.AddComponent<Camera>();
        camera.RenderToCubemap(cubemap);
        DestroyImmediate(go);
    }
}
