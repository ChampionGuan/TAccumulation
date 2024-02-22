using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using X3.PlayableAnimator;
using BattleCurveAnimator;
using UnityEngine.Profiling;
using X3.Character;

namespace X3Battle
{
    public class ActorWeapon : ActorComponent
    {
        public WeaponLogicConfig weaponLogicCfg => _weaponLogicCfg;
        public WeaponSkinConfig weaponSkinCfg => _weaponSkinConfig;
        public Dictionary<string, bool> weaponPartName => _weaponPartNameSet;
        public bool? stateVisible => _stateVisible;
        public bool? customVisible => _customVisible;
        public bool finalVisible => _finalVisible;

        private Dictionary<string, bool> _weaponPartNameSet = new Dictionary<string, bool>();
        private WeaponSkinConfig _weaponSkinConfig;
        private WeaponLogicConfig _weaponLogicCfg;
        private GameObject _actorModel;
        private GameObject _goWeapon;
        private int _hashID;

        //武器显隐状态
        private bool _pauseVisible = false;
        private bool? _stateVisible;
        private int? _stateVisibleSkillOwner;
        private bool? _customVisible;
        private int? _customVisibleOwner;
        private bool _finalVisible = false;
        private string _visibleWeaponName = string.Empty;
        private Action _fadeOutAction;

        //bake Weapon隐藏效果相关
        private X3Character _x3Character;
        private List<string> _curWeaponList = new List<string>(8);
        private Dictionary<string, CurveAnimator> _bakeWeaponAnims = new Dictionary<string, CurveAnimator>(8);
        private Dictionary<string, bool> _bakeIsFollow = new Dictionary<string, bool>(4); //策划:隐藏时武器不跟随
        private Dictionary<int, string> _bakeHideEndTimerID = new Dictionary<int, string>(4);//隐藏结束后恢复跟随
        private Dictionary<string, Vector3> _bakeHidePos = new Dictionary<string, Vector3>(4);
        private Dictionary<string, Vector3> _bakeHideRot = new Dictionary<string, Vector3>(4);
        private Dictionary<string, List<Transform>> _weaponBones = new Dictionary<string, List<Transform>>(8);

        //一次性效果
        private bool _onceEffectSet = false;
        private bool _onceEffectLateClear = false;
        private int[] _onceFadeOutFxs;
        private string _onceOutSound;
        private string _onceOutMatAnim;
        private Dictionary<string, CurveAnimAsset> _cacheOutMatAnims = new Dictionary<string, CurveAnimAsset>();
        private Action<int, StateNotifyType, string> _actionOnAnimStateChange;
        private Action<int> _actionDestroyBakeWeapon;

        public ActorWeapon() : base(ActorComponentType.Weapon)
        {
            requiredPhysicalJobRunning = true;
            _actionOnAnimStateChange = _OnAnimStateChange;
            _actionDestroyBakeWeapon = _DestroyBakeWeapon;
            _hashID = GetHashCode();
        }

        protected override void OnStart()
        {
            _Clear();
            _x3Character = actor.EnsureComponent<X3Character>(actor.GetDummy(ActorDummyType.Model).gameObject);
            TryAddWeapon();
            _PreloadExtWeaponParts();
            _fadeOutAction = _FadeOutWeapon;
        }

        protected override void OnDestroy()
        {
            _goWeapon?.ClearVisible();
            foreach (var anim in _cacheOutMatAnims.Values)
                BattleResMgr.Instance.Unload(anim);
            _cacheOutMatAnims.Clear();

            _x3Character = null;
            _bakeWeaponAnims.Clear();
            _bakeIsFollow.Clear();
            _bakeHideEndTimerID.Clear();
            _bakeHidePos.Clear();
            _bakeHideRot.Clear();
            _Clear();
        }
        
        public override void OnBorn()
        {
            _stateVisible = false;//默认进入普通idle
            _stateVisibleSkillOwner = null;
            _customVisible = null;
            _customVisibleOwner = null;
            _finalVisible = false;
            _visibleWeaponName = null;
            actor.animator.onStateNotify.AddListener(_actionOnAnimStateChange);
            battle.onPostUpdate.Add(PostUpdateVisible, (int)BattlePostUpdateEventLayer.Weapon);
        }

        public override void OnRecycle()
        {
            actor.animator.onStateNotify.RemoveListener(_actionOnAnimStateChange);
            battle.onPostUpdate.Remove(PostUpdateVisible, (int)BattlePostUpdateEventLayer.Weapon);
        }

        //基础规则 当动画改变时,根据是否技能状态设置武器是否显示
        private void _OnAnimStateChange(int layer, StateNotifyType eState, string state)
        {
            using (ProfilerDefine.ActorWeaponBakeOnAnimStateChangePMarker.Auto())
            {
                if (layer != 0)
                    return;
                if (eState == StateNotifyType.Enter)
                {
                    bool isSkill = actor.mainState.mainStateType == ActorMainStateType.Skill;
                    if (isSkill && _stateVisibleSkillOwner == actor.skillOwner.currentSlot.ID)//同一个技能内 动画切换不再切显隐
                        return;
                    _stateVisible = isSkill;
                    _stateVisibleSkillOwner = actor.skillOwner.currentSlot?.ID;

                    if (_stateVisible == false && _visibleWeaponName == null)//外部优先
                        _MarkHideWeapon();
                }
            }
        }
        /// <summary>
        /// 自定义武器隐藏,总是成功的
        /// </summary>
        /// <param name="visible"></param>
        /// <param name="immediately"></param>
        /// <param name="owner">技能Action可以瞬间多次执行 所以同样ID允许置回空</param>
        public void RequireCustomVisible(bool? visible, bool immediately = false, int? owner = 0)
        {
            _customVisible = visible;
            _customVisibleOwner = owner;
            if (immediately)
            {
                _MarkHideWeapon();
                PostUpdateVisible();
            }
            else
            {
                if (visible == false)
                    _MarkHideWeapon();
            }
        }
        /// 释放控制
        public void ReleaseCustomVisible(int owner = 0)
        {
            if(_customVisibleOwner.HasValue && _customVisibleOwner.Value == owner)
            {
                _customVisible = null;
                _customVisibleOwner = null;
                _visibleWeaponName = null;
            }
        }
        protected void _MarkHideWeapon()
        {
            using (ProfilerDefine.ActorWeaponMarkHideWeaponPMarker.Auto())
            {
                //获取激活的weaponMesh
                if (_goWeapon == null) return;
                _curWeaponList.Clear();
                _visibleWeaponName = null;

                CharacterMgr.GetPartNamesWithPartType(_actorModel, (int)PartType.Weapon, _curWeaponList);
                foreach (var curPartName in _curWeaponList)
                {
                    var visible = CharacterMgr.GetPartVisibility(_actorModel, curPartName);
                    if (visible)
                    {
                        _visibleWeaponName = curPartName;
                        break;
                    }
                }
            }
        }

        public void SetWeaponVisiblePause(bool value)
        {
            _pauseVisible = value;
        }
        // 设置一次性自定义隐藏特效
        public void SetOnceOutEffect(int[] outFxs, string outSound, string outMatAnim)
        {
            _onceEffectSet = true;
            _onceFadeOutFxs = outFxs;
            _onceOutSound = outSound;
            _onceOutMatAnim = outMatAnim;
        }
        public void ClearOnceOutEffectLate()
        {
            _onceEffectLateClear = true;
        }
        // 清理一次性自定义隐藏特效
        private void _ClearOnceEffect()
        {
            _onceEffectSet = false;
            _onceFadeOutFxs = null;
            _onceOutSound = null;
            _onceOutMatAnim = null;
        }

        #region Update
        // 在动画和Action执行后(这两顺序不确定)，决定是否要显隐武器
        // FadeOut会记录bakeMesh位置,一定要动画更新之前执行
        public void PostUpdateVisible()
        {
            if (_pauseVisible)
                return;
            var visible = _customVisible.HasValue ? _customVisible : _stateVisible;
            if (visible.HasValue && visible.Value != _finalVisible)
            {
                if (visible.Value)
                    _FadeInWeapon();
                else
                    actor.transform.ApplyPrevFrameTransform(_fadeOutAction);
                _finalVisible = visible.Value;
            }
        }
        protected override void OnPhysicalJobRunning()
        {
            _BakeWeaponFollow();//bake默认跟随骨骼，在动画Evaluate之后重设到脱离位置
            foreach (var animator in _bakeWeaponAnims.Values)
            {
                animator.Update(actor.deltaTime);
                animator.OnLateUpdate();
            }
            if (_onceEffectLateClear)
            {
                _onceEffectLateClear = false;
                _ClearOnceEffect();
            }
        }
        private void _BakeWeaponFollow()
        {
            using (ProfilerDefine.ActorWeaponBakeWeaponFollowPMarker.Auto())
            {
                foreach (var bakeFollow in _bakeIsFollow)
                {
                    if (!bakeFollow.Value)
                    {
                        if (_bakeWeaponAnims.TryGetValue(bakeFollow.Key, out var bakeGO))
                        {
                            bakeGO.transform.position = _bakeHidePos[bakeFollow.Key];
                            bakeGO.transform.eulerAngles = _bakeHideRot[bakeFollow.Key];
                        }
                    }
                }
            }
        }
        #endregion

        #region Add/Remove Weapon
        // 尝试添加武器
        public void TryAddWeapon()
        {
            if (actor.type != ActorType.Hero)
            {
                return;
            }

            if (_weaponSkinConfig != null)
            {
                LogProxy.LogErrorFormat("现阶段只有一把武器，在添加武器之前应先调用TryRemoveWeapon卸载武器！请检查代码逻辑！");
                return;
            }

            _actorModel = actor.GetDummy(ActorDummyType.Model).gameObject;

            int weaponSkinID = -1;
            if (actor.subType == (int) HeroType.Girl)
            {
                weaponSkinID = actor.battle.arg.girlWeaponID;
                if (weaponSkinID <= 0)
                {
                    return;
                }
            }
            else if (actor.suitCfg is MaleSuitConfig suitCfg)
            {
                weaponSkinID = suitCfg.WeaponID;
            }
            
            var weaponSkinConfig = TbUtil.GetCfg<WeaponSkinConfig>(weaponSkinID);
            if (weaponSkinConfig == null)
            {
                LogProxy.LogErrorFormat("武器配置不存在：id={0}", weaponSkinID);
                return;
            }
            _weaponSkinConfig = weaponSkinConfig;

            if (!string.IsNullOrEmpty(weaponSkinConfig.FadeInMat))
                _cacheOutMatAnims[weaponSkinConfig.FadeInMat] = BattleResMgr.Instance.Load<CurveAnimAsset>(weaponSkinConfig.FadeInMat, BattleResType.MatCurveAsset);
            if (!string.IsNullOrEmpty(weaponSkinConfig.FadeOutMat))
                _cacheOutMatAnims[weaponSkinConfig.FadeOutMat] = BattleResMgr.Instance.Load<CurveAnimAsset>(weaponSkinConfig.FadeOutMat, BattleResType.MatCurveAsset);
            var partNames = BattleUtil.GetWeaponParts(weaponSkinConfig.ID);
            if (partNames != null)
            {
                foreach (var partName in partNames)
                {
                    BattleCharacterMgr.AddPart(_actorModel, partName);
                    this._weaponPartNameSet[partName] = true;
                    BattleCharacterMgr.GetPartParentBone(_actorModel, partName);
                    CurveAnimAsset curveAnim = null;
                    if (!string.IsNullOrEmpty(weaponSkinConfig.FadeOutMat))
                        curveAnim = _cacheOutMatAnims[weaponSkinConfig.FadeOutMat];
                    _InitBakeWeaponCurveAnimator(partName, curveAnim);
                }
            }
            else
            {
                //男主不是Add的武器 是本身武器 从这获取
                _curWeaponList.Clear();
                CharacterMgr.GetPartNamesWithPartType(_actorModel, (int)PartType.Weapon, _curWeaponList);
                foreach(var partName in _curWeaponList)
                {
                    CurveAnimAsset curveAnim = null;
                    if (!string.IsNullOrEmpty(weaponSkinConfig.FadeOutMat))
                        curveAnim = _cacheOutMatAnims[weaponSkinConfig.FadeOutMat];
                    _InitBakeWeaponCurveAnimator(partName, curveAnim);
                }
            }
            
            _weaponLogicCfg = TbUtil.GetCfg<WeaponLogicConfig>(weaponSkinConfig.WeaponLogicID);

            var weaponTransform = _actorModel.transform.Find("Weapon");
            if (weaponTransform)
            {
                _goWeapon = weaponTransform.gameObject;
                // 默认隐藏
                _goWeapon.SetVisible(false);
                actor.animator.SetPrevBone(weaponTransform, 0);
            }

            if (_goWeapon != null)
            {
                _HideWeaponGO();
            }
        }

        // 提前加载一下技能里面切换的武器部件
        private void _PreloadExtWeaponParts()
        {
            if (actor.subType == (int) HeroType.Girl)
            {
                var battleGirl = this.actor.GetDummy(ActorDummyType.Model).gameObject;
                var extParts = BattleEnv.GetHeroExtWeaponParts(HeroType.Girl, false);  // false表示非表演Action即正常Action的部件
                _LoadExtWeaponParts(battleGirl, extParts);
            }
            else if (actor.subType == (int) HeroType.Boy)
            {
                var battleBoy = this.actor.GetDummy(ActorDummyType.Model).gameObject;
                var extParts = BattleEnv.GetHeroExtWeaponParts(HeroType.Boy, false);  // false表示非表演Action即正常Action的部件
                _LoadExtWeaponParts(battleBoy, extParts);
            }
        }
        
        private void _LoadExtWeaponParts(GameObject battleModel, HashSet<string> extParts)
        {
            if (extParts == null)
            {
                return;
            }

            foreach (var extPart in extParts)
            {
                // 战斗主角添加不在默认武器配置中的部件并隐藏
                if (!_weaponPartNameSet.ContainsKey(extPart))
                {
                    if (battleModel != null)
                    {
                        BattleCharacterMgr.AddPart(battleModel, extPart, false);
                        _InitBakeWeaponCurveAnimator(extPart);
                        BattleCharacterMgr.HidePart(battleModel, extPart, true);   
                    }
                }
            }
        }

        private void _InitBakeWeaponCurveAnimator(string partName, CurveAnimAsset asset = null)
        {
            if (string.IsNullOrEmpty(partName))
                return;
            GameObject partParent;
            using (ProfilerDefine.ActorWeaponInitBakeWeaponCurveAnimatorBakeMeshPMarker.Auto())
            {
                //Bake WeaponMesh
                partParent = WeaponBakeMeshUtility.BakeMesh(_x3Character, partName);
                if (partParent == null) return;
            }

            //添加CurveAnimator 
            using (ProfilerDefine.ActorWeaponInitBakeWeaponCurveAnimatorAddCurveAnimatorPMarker.Auto())
            {
                if (!_bakeWeaponAnims.TryGetValue(partName, out _))
                {
                    CurveAnimator curveAnimator = null;
                    //Editor下可能创建两个一样的角色 理论上不允许 防报错
                    curveAnimator = partParent.GetComponent<CurveAnimator>();
                    if (curveAnimator == null)
                        curveAnimator = partParent.AddComponent<CurveAnimator>();
                    curveAnimator.updateMode = CurveAnimator.UpdateMode.Manual;
                    curveAnimator.Init(1, false);
                    if (asset != null)
                        curveAnimator.Play(asset);
                    _bakeWeaponAnims[partName] = curveAnimator;
                }

                //骨骼
                List<Transform> bones = new List<Transform>();
                BattleCharacterMgr.GetWeaponBones(_actorModel, bones);
                _weaponBones[partName] = bones;

                //策划:隐藏影子
                var meshRenderers = partParent.GetComponentsInChildren<MeshRenderer>();
                foreach (var r in meshRenderers)
                {
                    r.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
                }

                //默认隐藏
                partParent.SetVisible(false);
            }
        }

        // 清理重设属性
        public void _Clear()
        {
            //-type table<string, boolean> 武器部件名
            this._weaponPartNameSet.Clear();
            //-type WeaponSkinConfig 武器皮肤配置
            this._weaponSkinConfig = null;
            //-type Transform[] 挂载的武器骨骼点
            this._weaponBones.Clear();
            //-type WeaponState 当前武器状态
            this._finalVisible = false;
            //-type GameObject
            this._goWeapon = null;
        }
        // 尝试卸载武器
        public void TryRemoveWeapon()
        {
            if (actor.type != ActorType.Hero)
            {
                return;
            }

            if (this._weaponPartNameSet != null)
            {
                var go = this.actor.GetDummy(ActorDummyType.Model).gameObject;
                foreach (var iter in _weaponPartNameSet)
                {
                    BattleCharacterMgr.RemovePart(go, iter.Key);
                }
            }

            this._Clear();
        }
        #endregion

        #region Fade View
        // 淡入武器
        private void _FadeInWeapon()
        {
            if (_weaponSkinConfig == null)
                return;

            _ShowWeaponGO();
        }
        public void _ShowWeaponGO()
        {
            if (_goWeapon != null)
            {
                _goWeapon.AddVisibleWithLayer(true, _hashID);
            }
        }

        // 淡出武器
        private void _FadeOutWeapon()
        {
            if (_weaponSkinConfig == null)
                return;

            if (_visibleWeaponName != null && !_weaponBones.ContainsKey(_visibleWeaponName))//可能中途加没bake
            {
                _InitBakeWeaponCurveAnimator(_visibleWeaponName);
            }

            using (ProfilerDefine.ActorWeaponFadeOutWeaponPlayFadeOutFxPMarker.Auto())
            {
                var fadeOutFxs = _onceEffectSet ? _onceFadeOutFxs : _weaponSkinConfig.FadeOutFxs;
                if (fadeOutFxs != null && _visibleWeaponName != null && _weaponBones.ContainsKey(_visibleWeaponName))
                {
                    for (int i = 0; i < _weaponBones[_visibleWeaponName].Count; i++)
                    {
                        if (fadeOutFxs.Length <= i) break;
                        actor.effectPlayer.PlayFx(fadeOutFxs[i]);
                    }
                }
            }

            using (ProfilerDefine.ActorWeaponFadeOutWeaponPlayFadeOutSoundPMarker.Auto())
            {
                var fadeOutSound = _onceEffectSet ? _onceOutSound : _weaponSkinConfig.FadeOutSound;
                actor?.battle.wwiseBattleManager.PlaySound(fadeOutSound, actorInsId: actor.insID);
            }

            using (ProfilerDefine.ActorWeaponFadeOutWeaponPlayHideWeaponPMarker.Auto())
            {
                _PlayHideBakeWeapon();
            }

            using (ProfilerDefine.ActorWeaponFadeOutWeaponHideWeaponGOPMarker.Auto())
            {
                _HideWeaponGO();
            }

            _visibleWeaponName = null;
            _ClearOnceEffect();
        }
        protected void _HideWeaponGO()
        {
            if (_goWeapon != null)
            {
                _goWeapon.RemoveVisibleWithLayer(_hashID);
            }
        }
        protected void _PlayHideBakeWeapon()
        {
            if (_visibleWeaponName == null) return;
            
            //恢复跟随位置
            if (_bakeWeaponAnims.TryGetValue(_visibleWeaponName, out CurveAnimator curveAnimator))
            {
                curveAnimator.transform.localPosition = Vector3.zero;
                curveAnimator.transform.localEulerAngles = Vector3.zero;
            }

            //Bake WeaponMesh
            GameObject partParent;
            using (ProfilerDefine.ActorWeaponPlayHideWeaponBakeMeshPMarker.Auto())
            {
                partParent = WeaponBakeMeshUtility.BakeMesh(_x3Character, _visibleWeaponName);
                if (partParent == null) return;
            }

            using (ProfilerDefine.ActorWeaponPlayHideWeaponSetVisiblePMarker.Auto())
            {
                partParent.AddVisibleWithLayer(true, _hashID);
            }

            //记录part消失不跟随的位置 结束后取消
            using (ProfilerDefine.ActorWeaponPlayHideWeaponbakeHidePosPMarker.Auto())
            {
                if (_weaponSkinConfig.FadeOutFollow == 0)
                {
                    _bakeIsFollow[_visibleWeaponName] = false;
                    _bakeHidePos[_visibleWeaponName] = partParent.transform.position;
                    _bakeHideRot[_visibleWeaponName] = partParent.transform.eulerAngles;
                }
            }

            using (ProfilerDefine.ActorWeaponPlayHideWeaponSetParentPMarker.Auto())
            {
                //添加CurveAnimator 播放武器消失材质动画
                partParent.transform.SetParent(actor.GetDummy(ActorDummyType.Model), false);
            }

            using (ProfilerDefine.ActorWeaponPlayHideWeaponAddCurveAnimatorPMarker.Auto())
            {
                if (curveAnimator == null)
                {
                    curveAnimator = partParent.AddComponent<CurveAnimator>();
                    curveAnimator.Init(1, false);
                    _bakeWeaponAnims[_visibleWeaponName] = curveAnimator;
                }
            }

            CurveAnimAsset outMatAnim = null;
            if (_onceEffectSet)
            {
                using (ProfilerDefine.ActorWeaponPlayHideWeaponCurveAnimAssetLoadPMarker.Auto())
                {
                    if (!string.IsNullOrEmpty(_onceOutMatAnim))
                    {
                        if (!_cacheOutMatAnims.TryGetValue(_onceOutMatAnim, out outMatAnim))
                    	{
                        	outMatAnim = BattleResMgr.Instance.Load<CurveAnimAsset>(_onceOutMatAnim, BattleResType.MatCurveAsset);
                        	if (outMatAnim != null)
                            	_cacheOutMatAnims[_onceOutMatAnim] = outMatAnim;
                        }
                    }
                }
            }
            else
            {
                if (!string.IsNullOrEmpty(_weaponSkinConfig.FadeOutMat))
                    outMatAnim = _cacheOutMatAnims[_weaponSkinConfig.FadeOutMat];
            }

            using (ProfilerDefine.ActorWeaponPlayHideWeaponCurveAnimatorPlayPMarker.Auto())
            {
                curveAnimator.Play(outMatAnim, 0);
            }

            //播完后的处理(取消位置固定)
            using (ProfilerDefine.ActorWeaponPlayHideWeaponTimerInfoPMarker.Auto())
            {
                var destroyTime = outMatAnim != null ? outMatAnim.multiAnimData.anims[0].length : 0;
                int timerID;
                using (ProfilerDefine.ActorWeaponPlayHideWeaponAddTimerPMarker.Auto())
                {
                    timerID = actor.timer.AddTimer(null, 0, destroyTime, 1, null, null, null, _actionDestroyBakeWeapon);
                }

                _bakeHideEndTimerID[timerID] = _visibleWeaponName;
            }
        }
        protected void _DestroyBakeWeapon(int timerID)
        {
            if (!_bakeHideEndTimerID.TryGetValue(timerID, out var bakeWeapon)) return;
            
            _bakeIsFollow[bakeWeapon] = true;
            _bakeHideEndTimerID.Remove(timerID);
            if (_bakeWeaponAnims.TryGetValue(bakeWeapon, out var anim))
            {
                anim.gameObject.RemoveVisibleWithLayer(_hashID);
            }
        }
        #endregion
    }
}
