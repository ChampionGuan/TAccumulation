using System.Collections.Generic;

namespace X3Battle
{
    public class SharedFlag
    {
        public HashSet<object> owners { get; private set; }

        public SharedFlag()
        {
            owners = new HashSet<object>();
        }

        public void Acquire(object owner)
        {
            owners.Add(owner);
        }

        public void Remove(object owner)
        {
            owners.Remove(owner);
        }

        public bool IsActive()
        {
            return owners.Count > 0;
        }

        public void Clear()
        {
            owners.Clear();   
        }
    }
}