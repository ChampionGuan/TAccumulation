using System;

namespace X3Battle
{
    [Serializable]
    public struct ModuleID
    {
        public ModuleType moduleType;
        public int id;

        public override string ToString()
        {
            return $"{moduleType}: {id}";
        }
    }
}