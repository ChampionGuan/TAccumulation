using System;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [MessagePackObject]
    public class ActorSkillCmdEditor : ActorCmd
    {
        [Key(0)]public int actorID;
        [Key(1)]public int skillID;

        public ActorSkillCmdEditor()
        {
        }
        
        public ActorSkillCmdEditor(int actorID, int skillID)
        {
            this.actorID = actorID;
            this.skillID = skillID;
        }
        
        protected override void _OnEnter()
        {
#if UNITY_EDITOR
            var doMain = AppDomain.CurrentDomain;
            var assemblies = doMain.GetAssemblies();
            var typeName = "X3Battle.BattlePreview.Util.BPBridgeUtil";
            var editorAssembleName = "Assembly-CSharp-Editor";
            for (int i = 0; i < assemblies.Length; i++)
            {
                var assembly = assemblies[i];
                string anme = assembly.GetName().Name;
                if (!anme.Equals(editorAssembleName))
                    continue;
                var type = assembly.GetType(typeName);
                if (type == null)
                {
                    continue;
                }

                var bindFlag = System.Reflection.BindingFlags.Static
                               | System.Reflection.BindingFlags.Public;
                var method = type.GetMethod("PlaySkill", bindFlag);
                if (method == null)
                {
                    continue;
                }
                method.Invoke(null, new object[1] {this});
                break;
            }
#endif
        }

    }
}