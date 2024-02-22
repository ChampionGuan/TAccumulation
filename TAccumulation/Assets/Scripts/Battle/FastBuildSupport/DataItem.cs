using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle.FastBuildSupport
{
    public class DataItem
    {
        // private static int _instanceID;
        protected string _name;
        protected int _cfgID;
        
        // public int instanceID;
        public int cfgID => _cfgID;
        public string name
        {
            get => _name;
            set => _name = value;
        }
        public DataItem(int cfgID)
        {
            _cfgID = cfgID;
            // instanceID = _instanceID++;
        }
    }

    public class LevelData:DataItem
    {
        public LevelData(int levelID):base(levelID)
        {
            _name = levelID.ToString();
            BattleLevelConfig levelConfig = TbUtil.GetCfg<BattleLevelConfig>(levelID);
            if (levelConfig != null)
            {
                string name = TbUtil.GetDebugText(levelConfig.Name);
                _name = levelID +"&"+ name;
            }
        }
    }

    public class RoleData : DataItem
    {
        private int _suitID;
        public int suidID => _suitID;
        
        public RoleData(int suidID, int cfgID):base(cfgID)
        {
            _suitID = suidID;
            if (!TbUtil.TryGetCfg(cfgID, out ActorCfg actorCfg))
            {
                LogProxy.LogErrorFormat("错误的ActorCfgID：{0}，无法取到对应的ActorCfg数据", cfgID);
                return;
            }
            _name = actorCfg.ID + actorCfg.Name;
            if (TbUtil.TryGetCfg(_suitID, out ActorSuitCfg suitCfg))
            {
                _name = $"{suitCfg.SuitID}&{suitCfg.Name} （{_name}）";
            }
        }
    }
    
    public class WeaponData:DataItem
    {
        public WeaponData(int weaponSkinID):base(weaponSkinID)
        {
            _name = weaponSkinID.ToString();
            if (TbUtil.TryGetCfg<WeaponSkinConfig>(weaponSkinID, out var cfg))
            {
                _name = weaponSkinID +"&"+ TbUtil.GetDebugText(cfg.WeaponSkinDesc);
            }
        }
    }

    public class BattleLauncherData
    {
        private List<LevelData> _levels;
        private List<RoleData> _boys;
        private List<RoleData> _girls;
        private List<WeaponData> _weapons;
        
        public List<LevelData> levels => _levels;
        public List<RoleData> boys => _boys;
        public List<RoleData> girls => _girls;
        public List<WeaponData> weapons => _weapons;
        
        public BattleLauncherData()
        {
            _levels = new List<LevelData>();
            _boys = new List<RoleData>();
            _girls = new List<RoleData>();
            _weapons = new List<WeaponData>();
            InitLevelData();
            InitWeaponData();
            InitActorData();
        }

        private void InitLevelData()
        {
            foreach (var item in TbUtil.battleLevelConfigs)
            {
                if (item.Value.Visible)
                {
                    _levels.Add(new LevelData(item.Key));
                }
            }
        }

        private void InitWeaponData()
        {
            foreach (var item in TbUtil.weaponSkinConfigs)
            {
                if (!item.Value.IsVisible)
                {
                    continue;
                }
                _weapons.Add(new WeaponData(item.Key));
            }
        }

        private void InitActorData()
        {
            foreach (var actorCfg in TbUtil.actorCfgs.Values)
            {
                // 搜索套装IDs
                List<int> suitIDs = new List<int>();
                int cfgID = actorCfg.ID;
                TbUtil.GetActorSuitIDsByCfgID(cfgID, suitIDs);
                if (suitIDs.Count < 1)
                    continue;
                foreach (var suitID in suitIDs)
                {
                    if (TbUtil.HasCfg<BoyCfg>(cfgID))
                    {
                        // 男主
                        _boys.Add(new RoleData(suitID, cfgID));
                    }
                    else if (TbUtil.HasCfg<HeroCfg>(cfgID))
                    {
                        _girls.Add(new RoleData(suitID, cfgID));
                    }
                }
            }
        }

    }
    
}