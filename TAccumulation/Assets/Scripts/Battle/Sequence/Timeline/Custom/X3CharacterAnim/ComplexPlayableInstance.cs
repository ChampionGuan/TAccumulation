

using System.Collections.Generic;

// 一个timeline可能有多个不同的playableInstance，这边做个聚合方便lua层持有使用
// 这个聚合类存在的意义是使lua层的接口更加优雅，并且性能更加友好
public class ComplexPlayableInstance: IPlayableInsInterface
{
    private List<IPlayableInsInterface> items = null;

    public List<IPlayableInsInterface> GetItems()
    {
        return items;
    }

    #region 外部接口
    
    // 添加一个playable
    public void AddPlayableIns(IPlayableInsInterface playable)
    {
        if (items == null)
        {
            items = new List<IPlayableInsInterface>();  
        }  
        items.Add(playable);
    }
    
    // 删除一个已添加的playable
    public void RemovePlayableIns()
    {
        
    }
    
    // 销毁
    public void Destory()
    {
        this.Clear();  
    }

    // 设置时间
    public void SetTime(float time)
    {
        if (items != null)
        {
            var count = items.Count;
            for (int i = 0; i < count; i++)
            {
                items[i].SetTime(time); 
            }
        }
    }

    public void SetPlayableWeight(float weight)
    {
        if (items != null)
        {
            var count = items.Count;
            for (int i = 0; i < count; i++)
            {
                items[i].SetPlayableWeight(weight); 
            }
        }
    }

    #endregion
    
    // 清理playable
    private void Clear()
    {
        if (items != null)
        {
            items.Clear(); 
        }
    }
}