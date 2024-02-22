using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    [CustomEditor(typeof(CharacterInteractionCamera))]
    public class CharacterInteractionCameraInspector : BaseInspector<CharacterInteractionCamera>
    {       
        private SerializedProperty targets;
        private SerializedProperty type;
        private SerializedProperty center;
        private SerializedProperty omega;
        private SerializedProperty omegaR;
        protected override void Init()
        {
            base.Init();
            targets = this.GetSP("targets");
            type = this.GetSP("type");
            center = this.GetSP("center");
            omega = this.GetSP("omega");
            omegaR = this.GetSP("omegaR");
        }
        public override void OnInspectorGUI()
        {
            EditorGUILayout.LabelField("目标点列表");
            this.DrawPF(targets);
            this.DrawPF(type);
            var followType = Enum.GetValues(typeof(CharacterInteractionCamera.FollowType))
                .GetValue(type.enumValueIndex);
            switch (followType)
            {
                case CharacterInteractionCamera.FollowType.Lever:
                    this.DrawPF(center);
                    this.DrawPF(omega);
                    this.DrawPF(omegaR);
                    break;
                case CharacterInteractionCamera.FollowType.Follow:
                    this.DrawPF(omega);
                    this.DrawPF(omegaR);
                    break;
            }
            serializedObject.ApplyModifiedProperties();
        }
    }
}