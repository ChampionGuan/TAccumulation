using System;
using System.Collections.Generic;
using System.Configuration;
using DG.Tweening;
using DG.Tweening.Core;
using UnityEditor;
using UnityEngine;

namespace PapeGames.X3UI
{
    [CustomEditor(typeof(HoleMaskCtrl))]
    public class HoleMaskCtrlInspector : Editor
    {

        public bool ShowTest = false;
        
        public float PosX1 = 0;
        public float PosY1 = 0;
        public float Width1 = 100;
        public float Height1 = 100;
        public float Cornor1 = 0;
        public bool WithAnim1 = false;
        public float Time1 = 1f;
        
        
        public float PosX2 = 0;
        public float PosY2 = 0;
        public float Width2 = 100;
        public float Height2 = 100;
        public float Cornor2 = 0;
        public bool WithAnim2 = false;
        public float Time2 = 1f;
        
        
        public float PosX3 = 0;
        public float PosY3 = 0;
        public float Width3 = 100;
        public float Height3 = 100;
        public float Cornor3 = 0;
        public bool WithAnim3 = false;
        public float Time3 = 1f;
        
        
        public float PosX4 = 0;
        public float PosY4 = 0;
        public float Width4 = 100;
        public float Height4 = 100;
        public float Cornor4 = 0;
        public bool WithAnim4 = false;
        public float Time4 = 1f;
        
        private HoleMaskCtrl ctrl = null;

        private void OnEnable()
        {
            ctrl = target as HoleMaskCtrl;
        }

        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            ShowTest = EditorGUILayout.BeginFoldoutHeaderGroup(ShowTest, "测试");

            if (ShowTest)
            {
                if (!Application.isPlaying)
                {
                    EditorGUILayout.HelpBox("请先运行游戏！", MessageType.Warning);
                }
                else
                {
                    #region 1
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("PosX1");
                    PosX1 = EditorGUILayout.FloatField(PosX1);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("PosY1");
                    PosY1 = EditorGUILayout.FloatField(PosY1);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Width1");
                    Width1 = EditorGUILayout.FloatField(Width1);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Height1");
                    Height1 = EditorGUILayout.FloatField(Height1);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Cornor1");
                    Cornor1 = EditorGUILayout.FloatField(Cornor1);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("WithAnim1");
                    WithAnim1 = EditorGUILayout.Toggle(WithAnim1);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Time1");
                    Time1 = EditorGUILayout.FloatField(Time1);
                    GUILayout.EndHorizontal();
                    
                    if (GUILayout.Button("测试1"))
                    {
                        ctrl.ShowHole1(Cornor1, PosX1, PosY1, Width1, Height1, WithAnim1, Time1);
                    }

                    #endregion
                    
                    #region 2

                    GUILayout.BeginHorizontal();
                    GUILayout.Label("PosX2");
                    PosX2 = EditorGUILayout.FloatField(PosX2);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("PosY2");
                    PosY2 = EditorGUILayout.FloatField(PosY2);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Width2");
                    Width2 = EditorGUILayout.FloatField(Width2);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Height2");
                    Height2 = EditorGUILayout.FloatField(Height2);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Cornor2");
                    Cornor2 = EditorGUILayout.FloatField(Cornor2);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("WithAnim2");
                    WithAnim2 = EditorGUILayout.Toggle(WithAnim2);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Time2");
                    Time2 = EditorGUILayout.FloatField(Time2);
                    GUILayout.EndHorizontal();
                    
                    if (GUILayout.Button("测试2"))
                    {
                        ctrl.ShowHole2(Cornor2, PosX2, PosY2, Width2, Height2, WithAnim2, Time2);
                    }

                    #endregion
                    
                    #region 3

                    GUILayout.BeginHorizontal();
                    GUILayout.Label("PosX3");
                    PosX3 = EditorGUILayout.FloatField(PosX3);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("PosY3");
                    PosY3 = EditorGUILayout.FloatField(PosY3);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Width3");
                    Width3 = EditorGUILayout.FloatField(Width3);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Height3");
                    Height3 = EditorGUILayout.FloatField(Height3);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Cornor3");
                    Cornor3 = EditorGUILayout.FloatField(Cornor3);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("WithAnim3");
                    WithAnim3 = EditorGUILayout.Toggle(WithAnim3);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Time3");
                    Time3 = EditorGUILayout.FloatField(Time3);
                    GUILayout.EndHorizontal();
                    
                    if (GUILayout.Button("测试3"))
                    {
                        ctrl.ShowHole3(Cornor3, PosX3, PosY3, Width3, Height3, WithAnim3, Time3);
                    }

                    #endregion
                    
                    #region 4

                    GUILayout.BeginHorizontal();
                    GUILayout.Label("PosX4");
                    PosX4 = EditorGUILayout.FloatField(PosX4);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("PosY4");
                    PosY4 = EditorGUILayout.FloatField(PosY4);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Width4");
                    Width4 = EditorGUILayout.FloatField(Width4);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Height4");
                    Height4 = EditorGUILayout.FloatField(Height4);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Cornor4");
                    Cornor4 = EditorGUILayout.FloatField(Cornor4);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("WithAnim4");
                    WithAnim4 = EditorGUILayout.Toggle(WithAnim4);
                    GUILayout.EndHorizontal();
                    
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Time4");
                    Time4 = EditorGUILayout.FloatField(Time4);
                    GUILayout.EndHorizontal();
                    
                    if (GUILayout.Button("测试4"))
                    {
                        ctrl.ShowHole4(Cornor4, PosX4, PosY4, Width4, Height4, WithAnim4, Time4);
                    }

                    #endregion
                    
                    if (GUILayout.Button("同时"))
                    {
                        ctrl.ShowHole1(Cornor1, PosX1, PosY1, Width1, Height1, WithAnim1, Time1);
                        ctrl.ShowHole2(Cornor2, PosX2, PosY2, Width2, Height2, WithAnim2, Time2);
                        ctrl.ShowHole3(Cornor3, PosX3, PosY3, Width3, Height3, WithAnim3, Time3);
                        ctrl.ShowHole4(Cornor4, PosX4, PosY4, Width4, Height4, WithAnim4, Time4);
                    }
                }
            }

            EditorGUILayout.EndFoldoutHeaderGroup();
        }
    }
}