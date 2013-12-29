using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class Funnel : MonoBehaviour
{
	const int RenderEventID = 0xfa9100;
	static int slotCount = 0;

	int slotIndex;

	public int screenWidth = 1280;
    public int screenHeight = 720;
    RenderTexture renderTexture;

    [DllImport("Funnel")]
    static extern void FunnelSetFrameTexture (int slotIndex, string frameName, int textureID, int width, int height);

	[DllImport("Funnel")]
	static extern void FunnelReleaseSlot (int slotIndex);

	void Start ()
    {
		slotIndex = slotCount++;
        renderTexture = new RenderTexture (screenWidth, screenHeight, 24);
        camera.targetTexture = renderTexture;
    }

    void Update ()
    {
        FunnelSetFrameTexture (slotIndex, gameObject.name, renderTexture.GetNativeTextureID (), screenWidth, screenHeight);
        GL.IssuePluginEvent (RenderEventID + slotIndex);
    }

	void OnDisable ()
	{
		FunnelReleaseSlot (slotIndex);
	}
}
