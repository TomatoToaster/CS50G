using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GemSpawner : MonoBehaviour
{
    public GameObject prefab;

    // Start is called before the first frame update
    void Start()
    {
        // infinite gem spawning
        StartCoroutine(SpawnGems());
    }

    // Update is called once per frame
    void Update()
    {
    }

    private IEnumerator SpawnGems()
    {
        while(true)
        {
            Instantiate(prefab, new Vector3(26, Random.Range(-10, 10), 10), Quaternion.identity);
			yield return new WaitForSeconds(Random.Range(1, 5));
        }
    }
}
