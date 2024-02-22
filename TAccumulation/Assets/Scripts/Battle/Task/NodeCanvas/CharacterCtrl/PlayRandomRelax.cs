using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion;
using ParadoxNotion.Design;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("播放随机Relax")]
    public class PlayRandomRelax : CharacterAction
    {
        public float fade;

        protected int lastSelectedIndex = -1;
        protected float relaxTime = float.MaxValue;
        protected string animName = string.Empty;

        protected BattleAnimator animator;

        protected override string info
        {
            get { return $"播放随机Relax"; }
        }

        protected override void OnExecute()
        {
          if(_context.actor.type != ActorType.Hero)
            {
                EndAction(true);
                return;
            }

            var relaxWeights = _context.actor.locomotionView.relaxWeights;
            if (relaxWeights == null || relaxWeights.Length <= 0)
            {
                EndAction(true);
                return;
            }

            if (relaxWeights.Length == 1)
            {
                animName = relaxWeights[0].StrVal;
            }
            else
            {
                // 计算总权重
                int totalWeight = 0;
                for (int i = 0; i < relaxWeights.Length; i++)
                {
                    if (lastSelectedIndex != i)
                        totalWeight += relaxWeights[i].IntVal;
                }

                // 生成一个随机数
                int randomNumber = Random.Range(0, totalWeight);

                // 用随机数选择一个元素
                for (int i = 0; i < relaxWeights.Length; i++)
                {
                    if (i == lastSelectedIndex)
                        continue;
                    if (randomNumber < relaxWeights[i].IntVal)
                    {
                        lastSelectedIndex = i;
                        animName = relaxWeights[i].StrVal;
                        break;
                    }
                    else
                    {
                        randomNumber -= relaxWeights[i].IntVal;
                    }
                }
            }
            if (animator == null)
                animator = _context.actor.animator;
            if (animator != null && _context.locomotionCtrl.HasAnimState(animName))
            {
                relaxTime = animator.GetAnimatorStateInfo(0, animName).length;
                _context.locomotionCtrl.PlayAnim(animName, fade);
            }
            else
            {
                EndAction(true);
            }
        }
        protected override void OnUpdate()
        {
            if (elapsedTime >= relaxTime)
            {
                EndAction(true);
            }
        }
    }
}
