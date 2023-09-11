using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WinCondition : MonoBehaviour
{
    public GameObject winText;
    void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player") {
            winText.SetActive(true);
        }
    }
}
