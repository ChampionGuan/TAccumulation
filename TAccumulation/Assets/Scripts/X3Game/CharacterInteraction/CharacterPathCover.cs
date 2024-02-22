using System.Collections.Generic;
using PapeGames.X3UI;
using UnityEngine;

namespace X3Game
{
    public class CharacterPathCover : MonoBehaviour
    {
        
        public float filledRateThreshold = 0.75f;
        public float distanceThreshold = 15.5f;
        
        public PathSDF pathSDF;
        public RectTransform targetRectTransform;
        
        private Camera m_UICamera;
        private bool m_IsDrawing = false;
        private int m_Count = 0; // 得分
        private long m_TotalDisSqr = 0;
        private Dictionary<int, bool> m_Records;

        private void OnEnable()
        {
            m_Records = new Dictionary<int, bool>();
            m_UICamera = UIMgr.Instance.UICamera;
        }

        public void ClearPainting() // 清除画板
        {
            m_Records.Clear();
            m_Count = 0;
            m_TotalDisSqr = 0;
        }

        public void BeginPainting()
        {
            if (!m_IsDrawing)
            {
                m_IsDrawing = true;
                ClearPainting();
            }
        }

        public void EndPainting()
        {
            if (m_IsDrawing)
            {
                m_IsDrawing = false;
            }
        }
        
        public bool GetResult()
        {
            float filledRate = (float)m_Records.Count / pathSDF.samplesCount;
            float mse = (float)m_TotalDisSqr / m_Count;
            float rmse = Mathf.Sqrt(mse);
            bool result = rmse < distanceThreshold && filledRate > filledRateThreshold;
            string isSuccess = result ? "Success" : "Fail";
            string res = $"Result: {isSuccess}\nFilled Rate: {filledRate}\nAverage Distance: {rmse}" ;
            Debug.Log(res);
            return result;
        }

        void FixedUpdate()
        {
            if (m_IsDrawing)
            {
                Rect targetRect = targetRectTransform.rect;
                RectTransformUtility.ScreenPointToLocalPointInRectangle(targetRectTransform, Input.mousePosition,
                    m_UICamera, out Vector2 localPos);
                Vector2 offset = new Vector2(targetRect.width / 2, targetRect.height / 2);
                localPos += offset;
                localPos.x = Mathf.Clamp(localPos.x, 0, targetRect.width - 1);
                localPos.y = Mathf.Clamp(localPos.y, 0, targetRect.height - 1);

                float uvx = (float)localPos.x / targetRect.width;
                float uvy = (float) localPos.y / targetRect.height;
                int i = Mathf.FloorToInt(uvx * 128);
                int j = Mathf.FloorToInt(uvy * 128);
                        
                int x = Mathf.FloorToInt(uvx * 16);
                int y = Mathf.FloorToInt(uvy * 16);
                        
                var d = pathSDF.sdf[j * 128 + i];
                float dis = (d - 128)  * targetRect.height / 256f;
                if (dis < 0)
                {
                    m_TotalDisSqr += Mathf.RoundToInt(dis) * Mathf.RoundToInt(dis);
                }

                CheckCover(x,y, 0, 0);
                CheckCover(x,y,1, 0);
                CheckCover(x,y,0, 1);
                CheckCover(x,y,-1, 0);
                CheckCover(x,y,0, -1);
                CheckCover(x,y,1, 1);
                CheckCover(x,y,-1, -1);
                CheckCover(x,y,1, -1);
                CheckCover(x,y,-1, 1);
                        
                m_Count++;
            }
            
            void CheckCover(int x, int y, int offsetX, int offsetY)
            {
                y += offsetX;
                x += offsetY;

                int index = y * 16 + x;
                if (index > 255 || index < 0)
                    return;
            
                var s = pathSDF.samples[y * 16 + x];
                if (s == 1)
                {
                            
                    if (!m_Records.ContainsKey(y * 16 + x))
                    {
                        m_Records[y * 16 + x] = true;
                    }
                }
            }
        }
    }
}