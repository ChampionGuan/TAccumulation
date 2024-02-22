#if UNITY_EDITOR

using System;
using UnityEditor;
using UnityEngine;

namespace EasyCharacterMovement
{
    [CustomEditor(typeof(CharacterMovement))]
    public class CharacterMovementInspector:Editor
    {
        private GUIStyle _foldoutStyle;
        protected bool _curFoldout;
        private void OnEnable()
        {
            _foldoutStyle = new GUIStyle
            {
                padding = new RectOffset(4, 4, 4, 4),
                margin = new RectOffset(4, 4, 4, 4),
                fixedHeight = 0,
                fontSize = 14,
                alignment = TextAnchor.MiddleLeft,
            };
        }

        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            _curFoldout = _DrawFoldoutHeadline(_curFoldout, "MoveMode");
            if (_curFoldout)
            {
                var character = target as CharacterMovement;
                var curMode = character.ModeCtrl.curMode;
                EditorGUILayout.LabelField("Mode", curMode.model.ToString());
                if (curMode.model == MovementMode.walking)
                {
                    EditorGUILayout.LabelField("isOnGround", character.isOnGround?"true":"False");
                    EditorGUILayout.LabelField("isOnWalkableGround", character.isOnWalkableGround?"true":"False");
                }
            }
        }
        
        
        private bool _DrawFoldoutHeadline(bool foldout, string title)
        {
            EditorGUILayout.BeginHorizontal();
            GUILayout.Space(15);
            foldout = EditorGUILayout.BeginFoldoutHeaderGroup(foldout, title, _foldoutStyle);
            EditorGUILayout.EndFoldoutHeaderGroup();
            EditorGUILayout.EndHorizontal();
            return foldout;
        }
    }
    
    public partial class CharacterMovement
    {
        // 纯测试逻辑
        private void OnDrawGizmosSelected()
        {
            // Draw Foot position
            float skinRadius = _radius;
            Vector3 footPosition = transform.position - transform.up * kAvgGroundDistance;

            Gizmos.color = new Color(0.569f, 0.957f, 0.545f, 0.5f);
            Gizmos.DrawLine(footPosition + Vector3.left * skinRadius, footPosition + Vector3.right * skinRadius);
            Gizmos.DrawLine(footPosition + Vector3.back * skinRadius, footPosition + Vector3.forward * skinRadius);

            // Draw perch offset radius
            var rotation = transform.rotation;
            if (_perchOffset > 0.0f && _perchOffset < _radius)
            {
                
                DrawDisc(footPosition, rotation, _perchOffset, new Color(0.569f, 0.957f, 0.545f, 0.15f));
                DrawDisc(footPosition, rotation, _perchOffset, new Color(0.569f, 0.957f, 0.545f, 0.75f), false);
            }

            // Draw step Offset
            if (stepOffset > 0.0f)
            {
                DrawDisc(footPosition + transform.up * stepOffset, rotation, _radius * 1.15f,
                    new Color(0.569f, 0.957f, 0.545f, 0.75f), false);
            }
            
            // Draw ground
            if (_currentGround.hitGround)
            {
                Gizmos.color = Color.red;
                var centerPos = _currentGround.point + _currentGround.normal * 0.001f;
                Gizmos.DrawSphere(centerPos, 0.01f);
                Vector3 endPos = _currentGround.point + _currentGround.normal * _currentGround.groundDistance;
                Gizmos.DrawLine(_currentGround.point, endPos);
            }
        }
        
        // 绘制圆盘
        private void DrawDisc(Vector3 _pos, Quaternion _rot, float _radius, Color _color = default,
            bool solid = true)
        {
            if (_color != default)
                UnityEditor.Handles.color = _color;

            Matrix4x4 mtx = Matrix4x4.TRS(_pos, _rot, UnityEditor.Handles.matrix.lossyScale);

            using (new UnityEditor.Handles.DrawingScope(mtx))
            {
                if (solid) //实心
                    UnityEditor.Handles.DrawSolidDisc(Vector3.zero, Vector3.up, _radius);
                else
                    UnityEditor.Handles.DrawWireDisc(Vector3.zero, Vector3.up, _radius);
            }
        }
    }
}
# endif