using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RepeatTranslate : MonoBehaviour
{
    public float timeToTranslate = 1;
    public Vector3 destinationPosition;
    private Vector3 startPosition;
    private bool goingToDest;
    private Vector3 differenceVector;
    private float curTime;

    // Start is called before the first frame update
    void Start()
    {
        goingToDest = true;
        startPosition = transform.position;
        differenceVector = destinationPosition - startPosition;
        curTime = 0;
    }

    // Update is called once per frame
    void Update()
    {
        float diff = Time.deltaTime;
        if (goingToDest) {
            transform.position += diff * differenceVector / timeToTranslate;
        } else {
            transform.position -= diff * differenceVector / timeToTranslate;
        }

        curTime += diff;
        if (curTime >= timeToTranslate) {
            curTime = 0;
            goingToDest = !goingToDest;
        }
    }
}
