using UnityEngine;
using System.Collections;

public class Configurator : MonoBehaviour
{
    public int framerate = 60;
    public bool fixFramerate = false;

    void Start ()
    {
        if (fixFramerate) {
            Time.captureFramerate = framerate;
        } else {
            Application.targetFrameRate = framerate;
        }
    }
}
