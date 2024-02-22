using Framework.RigidBodyDynamics;
using Unity.Mathematics;
using UnityEngine;

namespace X3Game
{
    public class BlockTowerPhysicsUtil
    {
        public static void RewritePpMaterial(GameObject go, float friction, float bounciness)
        {
            if (go)
            {
                var rb = go.GetComponent<PpRigidBody>();
                if (friction >= 0)
                {
                    rb.rewriteFriction = true;
                }
                else
                {
                    friction = rb.rewriteMaterial.friction;
                }

                if (bounciness >= 0)
                {
                    rb.rewriteBounciness = true;
                }
                else
                {
                    bounciness = rb.rewriteMaterial.bounciness;
                }

                rb.rewriteMaterial = new PpNativeMaterial(friction, bounciness);
            }
        }

        public static RaycastHit[] CheckColliderCastDistance(GameObject cube, Vector3 direction, float distance)
        {
            BoxCollider collider = cube.GetComponent<BoxCollider>();
            var size = collider.size / 2;
            if (direction != Vector3.up && direction != Vector3.down)
            {
                size *= 0.95f; //防止紧挨着的两个块无论任何方向都判断为接触
            }

            return Physics.BoxCastAll(cube.transform.position, size, direction, cube.transform.rotation,
                distance);
        }

        public static Collider[] CheckColliderOverlap(GameObject cube, Vector3 offset)
        {
            BoxCollider collider = cube.GetComponent<BoxCollider>();
            return Physics.OverlapBox(cube.transform.position, collider.size / 2 + offset, cube.transform.rotation);
        }

        public static PpIndex ConvertMeshToGeometry(PpPhysicsScene ppScene, PpShapeType type, Mesh mesh)
        {
            return ppScene.ConvertMeshToGeometry(type, mesh);
        }

        public static PpIndex ConvertPointToGeometry(PpPhysicsScene ppScene, PpShapeType type, Vector3[] points)
        {
            return ppScene.ConvertMeshToGeometry(type, points);
        }

        public static void WorldToLocal(Transform transform, float x, float y, float z, out float localX,
            out float localY, out float localZ)
        {
            var worldPoint = new Vector3(x, y, z);
            var localPoint = transform.worldToLocalMatrix.MultiplyPoint(worldPoint);
            localX = localPoint.x;
            localY = localPoint.y;
            localZ = localPoint.z;
        }

        public static void LocalToWorld(Transform transform, float x, float y, float z, out float worldX,
            out float worldY, out float worldZ)
        {
            var localPoint = new Vector3(x, y, z);
            var worldPoint = transform.localToWorldMatrix.MultiplyPoint(localPoint);
            worldX = worldPoint.x;
            worldY = worldPoint.y;
            worldZ = worldPoint.z;
        }

        public static void ClearVelocity(GameObject blockGO)
        {
            if (blockGO != null)
            {
                var ppRigidBody = blockGO.GetComponent<PpRigidBody>();
                ppRigidBody.velocity.liner = float3.zero;
                ppRigidBody.velocity.angular = float3.zero;
            }
        }

        public static PpRigidBody[] CreateBodyCollision()
        {
            return new PpRigidBody[64];
        }
    }
}