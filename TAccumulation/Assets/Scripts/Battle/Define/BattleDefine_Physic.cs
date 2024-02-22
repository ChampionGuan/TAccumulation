namespace X3Battle
{
    public enum ColliderType
    {
        Collider,
        Trigger,
        HurtBox,
        Ground,
        IgnoreCollision,
    }
    
    public enum ColliderTag
    {
        Default,
        Actor,
        Ground,
        AirWall,
    }
    
    public class X3Layer
    {
        public const int ActorCollider = 11;         
        public const int Trigger = 14; // 该层仅用于Trigger
        public const int IgnoreCollision = 13; // 该层不会产生碰撞效果
        public const int HurtBox = 12;
        public const int Ground = 9;
        public const int CameraCollider = 10;
    }
    
    // TODO 付强 老艾
    public class X3LayerMask
    {
        // 受击包围盒
        public const int HurtTest = 1 << X3Layer.HurtBox;
        // 碰撞器
        public const int ColliderTest = 1 << X3Layer.ActorCollider | 1 << X3Layer.Ground;
       
        // 光环使用
        public const int HaloTest = 1 << X3Layer.ActorCollider | 1 << X3Layer.IgnoreCollision;
        // 子弹使用
        public const int MissileTest = 1 << X3Layer.HurtBox | 1 << X3Layer.Ground;

        public const int GroundTest = 1 << X3Layer.Ground;
        public const int CameraColliderTest = 1 << X3Layer.CameraCollider;

        public const int ActorCollider = 1 << X3Layer.ActorCollider;
        public const int Trigger = 1 << X3Layer.Trigger;
    }

}