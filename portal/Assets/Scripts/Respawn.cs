using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.Characters.FirstPerson;

public class Respawn : MonoBehaviour
{
    public Vector3 startPosition;
    public float killHeight;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        if (transform.position.y <= killHeight) {
            transform.rotation = Quaternion.identity;
            transform.position = startPosition;
            GetComponent<FirstPersonController>().MouseReset();
        }
    }
}
