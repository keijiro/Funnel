using UnityEngine;

public class CopyFromFunnel : MonoBehaviour
{
    [SerializeField] Funnel.Funnel _target;

    void Start()
    {
        GetComponent<Renderer>().material.mainTexture = _target.renderTexture;
    }
}
