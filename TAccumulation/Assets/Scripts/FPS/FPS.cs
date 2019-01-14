using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace LPCFramework
{
	public class FPS : MonoBehaviour 
	{
		public int FramesPerSec;
		private float m_frequency = 1.0f;

		private int m_lastFrameCount = 0;
		private float m_lastTime = 0;
		private float m_timeSpan = 0;
		// Use this for initialization
		void Start () 
		{
			StartCoroutine(CalcFPS());
		}
		
		private IEnumerator CalcFPS()
		{
			for (;;)
			{
				// Capture frame-per-second
				m_lastFrameCount = Time.frameCount;
				m_lastTime = Time.realtimeSinceStartup;
				yield return new WaitForSeconds(m_frequency);
				m_timeSpan = Time.realtimeSinceStartup - m_lastTime;
				FramesPerSec = (int)((Time.frameCount - m_lastFrameCount) / m_timeSpan);
			}
		}

		// 已放入lua层实现，屏蔽掉
		// void OnGUI()
		// {
		// 	GUI.Label(new Rect(Screen.width - 200, 50, 150, 20), FramesPerSec.ToString());
		// }
	}
}
