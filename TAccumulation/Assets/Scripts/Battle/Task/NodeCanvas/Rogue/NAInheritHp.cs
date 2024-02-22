using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Rogue")]
    public class NAInheritHp : BattleAction
    {
        protected override void OnExecute()
        {
            if (_battle.rogue.levelConfig.HPSaved && _battle.rogue.arg.PreviousLayerData != null)
            {
                _battle.actorMgr.girl?.attributeOwner?.SetAttrValue(AttrType.HP, _battle.rogue.arg.PreviousLayerData.GirlHp);
                _battle.actorMgr.boy?.attributeOwner?.SetAttrValue(AttrType.HP, _battle.rogue.arg.PreviousLayerData.BoyHp);
            }
            
            EndAction(true);
        }
    }
}