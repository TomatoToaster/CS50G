using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MazeCounter : MonoBehaviour
{
    private Text myText;
    private static int counter = 1;
    
    public static void Reset() {
        counter = 1;
    }
    public static void Increment() {
        counter += 1;
    }


    void Start() {
        myText = GetComponent<Text>();

        // Only need to update text in Start (i.e when loading this component into scene)
        UpdateText();
    }


    private void UpdateText() {
        myText.text = counter.ToString();
    }

}
