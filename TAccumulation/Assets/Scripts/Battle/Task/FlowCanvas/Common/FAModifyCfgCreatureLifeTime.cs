using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("修改召唤物的模板属性-持续时间\nFAModifyCfgCreatureLifeTime")]
    public class FAModifyCfgCreatureLifeTime : FlowAction
    {
        [Name("召唤ID")]
        public BBParameter<int> summonID = new BBParameter<int>(0);

        [Name("修改类型")]
        public ModifyCfgType modifyType;

        [Name("时间")]
        public BBParameter<float> time = new BBParameter<float>(0f);

        protected override void _Invoke()
        {
            var targetID = summonID.GetValue();
            if (targetID > 0)
            {
                var summonConfig = TbUtil.LoadModifyCfg<BattleSummon>(targetID);
                if (summonConfig != null)
                {
                    var modifyCfgType = modifyType;
                    var lifeTime = time.GetValue();
                    if (modifyCfgType == ModifyCfgType.Set)
                    {
                        summonConfig.LifeTime = lifeTime;
                    }
                    else if(modifyCfgType == ModifyCfgType.Add)
                    {
                        summonConfig.LifeTime += lifeTime;
                    }
                    else if (modifyCfgType == ModifyCfgType.Sub)
                    {
                        summonConfig.LifeTime -= lifeTime;
                    }
                }
            }
        }
    }
}