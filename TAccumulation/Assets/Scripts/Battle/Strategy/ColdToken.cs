namespace X3Battle
{
    public class ColdToken
    {
        public int token;
        public float coldSecond;

        public bool Update(float deltaTime)
        {
            coldSecond -= deltaTime;
            return coldSecond < 0;
        }
    }
}