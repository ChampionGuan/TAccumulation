using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using PapeGames.Rendering;
using UnityEngine;

namespace X3Game.SceneGesture
{
    [ExecuteInEditMode]
    public class PPVCtrl
    {
        public bool IsBlending { get; private set; } = false;
        public static PostProcessVolume PPV { set; get; }

        public CinemachineBlendDefinition.Style BlendType { get; set; }
        public AnimationCurve CustomCurve { get; set; }
        
        private bool DOFEnable = false;
        private DOFSettings m_DOFSettings;
        private DOFSettings m_StartSettings;

        private StateBase m_AimState;
        private float m_Duration;
        private float m_Time;

        private bool m_PreWithDOF = false;
        private bool m_PreDOFEnable = false;
        private DOFSettings m_PreDOFSetting = new DOFSettings();
        public void SwitchState(StateBase stateBase, float duration)
        {
            if (stateBase == null)
                return;

            m_AimState = stateBase;
            if (DOFEnable != stateBase.DOFEnable)
            {
                DOFEnable = stateBase.DOFEnable;
                m_DOFSettings = stateBase.DOFSettings;
                EnableDOF();

                IsBlending = false;
                m_Duration = 0;
                m_Time = 0;
            }
            else
            {
                if (DOFEnable)
                {
                    if (duration <= Mathf.Epsilon)
                    {
                        m_DOFSettings = m_AimState.DOFSettings;
                        ApplyPPVSettings();
                        
                        IsBlending = false;
                        m_Duration = 0;
                        m_Time = 0;
                    }
                    else
                    {
                        m_StartSettings = m_DOFSettings;
                        IsBlending = true;
                        m_Duration = duration;
                        m_Time = 0;
                    }
                }
            }
        }

        public void OnLateUpdate(float dt)
        {
            if (IsBlending)
            {
                m_Time += dt;
               
                if (m_Time >= m_Duration)
                {
                    m_DOFSettings = m_AimState.DOFSettings;

                    IsBlending = false;
                    m_Duration = 0;
                    m_Time = 0;
                }
                else
                {
                    m_DOFSettings = DOFSettings.Lerp(m_StartSettings, m_AimState.DOFSettings,
                        BlendHelper.GetBlendWeight(Mathf.Clamp01(m_Time / m_Duration), BlendType, CustomCurve));
                }
            }
            else
            {
                if (m_AimState && m_AimState.IsChanging)
                    m_DOFSettings = m_AimState.DOFSettings;
            }
        }

        public void EnableDOF()
        {
            if (PPV == null)
                return;

            if (DOFEnable)
            {
                PPV.EnableFeature(BlendableFeatureGroup.FeatureType.BFG_Dof);
                ApplyPPVSettings();
            }
            else
            {
                PPV.DeactivateFeature(BlendableFeatureGroup.FeatureType.BFG_Dof);
            }
        }
        public void DisableDOF()
        {
            if (PPV == null)
                return;
            PPV.DeactivateFeature(BlendableFeatureGroup.FeatureType.BFG_Dof);
        }

        public void ApplyPPVSettings(bool forceUpdate = false)
        {
            if (PPV == null)
                return;

            if(forceUpdate && !IsBlending && m_AimState != null)
                m_DOFSettings = m_AimState.DOFSettings;
            
            var dof = PPV.GetComponent<DofBfg>();
            dof.nearStart = m_DOFSettings.NearStart;
            dof.nearEnd = m_DOFSettings.NearEnd;
            dof.farStart = m_DOFSettings.FarStart;
            dof.farEnd = m_DOFSettings.FarEnd;
            dof.skyDepth = m_DOFSettings.SkyDepth;
            dof.cocScale = m_DOFSettings.COCScale;
            dof.nearCOCGamma = m_DOFSettings.NearCOCGamma;
            dof.farCOCOffset = m_DOFSettings.FarCOCOffset;
            dof.fakeMode = true;
        }
    }
}