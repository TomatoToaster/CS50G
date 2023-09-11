using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JumpingSize : MonoBehaviour
{
    public float destScale;
    public float scaleSpeed;
    private float origScale;
    private bool isEnlarging;

    // Start is called before the first frame update
    void Start()
    {
        origScale = transform.localScale.x;
        isEnlarging = true;
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 curScale = transform.localScale;
        transform.localScale += (isEnlarging ? scaleSpeed : -scaleSpeed) * Vector3.one * Time.deltaTime;
        if (curScale.x > destScale && isEnlarging) {
            isEnlarging = false;
        } else if (curScale.x < origScale && !isEnlarging) {
            isEnlarging = true;
        }
    }
}
