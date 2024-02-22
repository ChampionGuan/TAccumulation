using System.Collections.Generic;

namespace AIDesigner.AutoLayout
{
    public class Tree<T>
    {
        public float m_width, m_height; // Width and height.
        public float m_x, m_y, m_prelim, m_mod, m_shift, m_change;
        public Tree<T> m_leftThread, rightThread; // Left and right thread.
        public Tree<T> m_leftExtreme, m_rightExtreme; // Extreme left and right nodes.
        public float m_leftExtremeModSum, m_rightExtremeModSum; // Sum of modifiers at the extreme nodes.
        public List<Tree<T>> m_children;

        public T m_innerData;

        public Tree(float w, float h, float y, List<Tree<T>> children, T innerData)
        {
            this.m_width = w;
            this.m_height = h;
            this.m_y = y;
            this.m_children = children;
            this.m_innerData = innerData;
        }
    }

    public static class Paper<T>
    {
        public static void Layout(Tree<T> t)
        {
            FirstWalk(t);
            SecondWalk(t, 0);
        }

        static void FirstWalk(Tree<T> t)
        {
            if (t.m_children.Count == 0)
            {
                SetExtremes(t);
                return;
            }

            FirstWalk(t.m_children[0]);
            //  Create siblings in contour minimal vertical coordinate and
            // index list.
             Iyl ih = UpdateIyl(Bottom(t.m_children[0].m_leftExtreme), 0, null);
            for (int i = 1; i < t.m_children.Count; i++)
            {
                FirstWalk(t.m_children[i]);
                //  Store lowest vertical coordinate while extreme nodes still
                // point in current subtree.
                float minY = Bottom(t.m_children[i].m_rightExtreme);
                Seperate(t, i, ih);
                ih = UpdateIyl(minY, i, ih);
            }

            PositionRoot(t);
            SetExtremes(t);
        }

        static void SetExtremes(Tree<T> t)
        {
            if (t.m_children.Count == 0)
            {
                t.m_leftExtreme = t;
                t.m_rightExtreme = t;
                t.m_leftExtremeModSum = t.m_rightExtremeModSum = 0;
            }
            else
            {
                t.m_leftExtreme = t.m_children[0].m_leftExtreme;
                t.m_leftExtremeModSum = t.m_children[0].m_leftExtremeModSum;
                t.m_rightExtreme = t.m_children[t.m_children.Count - 1].m_rightExtreme;
                t.m_rightExtremeModSum = t.m_children[t.m_children.Count - 1].m_rightExtremeModSum;
            }
        }

        static void Seperate(Tree<T> t, int i, Iyl ih)
        {
            //  Right contour node of left siblings and its sum of modfiers.
            Tree<T> sr = t.m_children[i - 1];
            float mssr = sr.m_mod;
            //  Left contour node of current subtree and its sum of modfiers.
            Tree<T> cl = t.m_children[i];
            float mscl = cl.m_mod;
            while (sr != null && cl != null)
            {
                if (Bottom(sr) > ih.lowY)
                    ih = ih.nxt;
                //  How far to the left of the right side of sr is the left side of
                // cl?
                float dist = (mssr + sr.m_prelim + sr.m_width) - (mscl + cl.m_prelim);
                if (dist > 0)
                {
                    mscl += dist;
                    MoveSubtree(t, i, ih.index, dist);
                }

                float sy = Bottom(sr), cy = Bottom(cl);
                //  Advance highest node(s) and sum(s) of modifiers
                if (sy <= cy)
                {
                    sr = NextRightContour(sr);
                    if (sr != null)
                        mssr += sr.m_mod;
                }

                if (sy >= cy)
                {
                    cl = NextLeftContour(cl);
                    if (cl != null)
                        mscl += cl.m_mod;
                }
            }

            //  Set threads and update extreme nodes.
            //  In the first case, the current subtree must be taller than the
            // left siblings.
            if (sr == null && cl != null)
                SetLeftThread(t, i, cl, mscl);
            //  In this case, the left siblings must be taller than the current
            // subtree.
            else if (sr != null && cl == null)
                SetRightThread(t, i, sr, mssr);
        }

        static void MoveSubtree(Tree<T> t, int i, int si, float dist)
        {
            //  Move subtree by changing mod.
            t.m_children[i].m_mod += dist;
            t.m_children[i].m_leftExtremeModSum += dist;
            t.m_children[i].m_rightExtremeModSum += dist;
            DistributeExtra(t, i, si, dist);
        }

        static Tree<T> NextLeftContour(Tree<T> t)
        {
            return t.m_children.Count == 0 ? t.m_leftThread : t.m_children[0];
        }

        static Tree<T> NextRightContour(Tree<T> t)
        {
            return t.m_children.Count == 0 ? t.rightThread : t.m_children[t.m_children.Count - 1];
        }

        static float Bottom(Tree<T> t)
        {
            return t.m_y + t.m_height;
        }

        static void SetLeftThread(Tree<T> t, int i, Tree<T> cl, float modsumcl)
        {
            Tree<T> li = t.m_children[0].m_leftExtreme;
            li.m_leftThread = cl;
            //  Change mod so that the sum of modifier after following thread
            // is correct.
            float diff = (modsumcl - cl.m_mod) - t.m_children[0].m_leftExtremeModSum;
            li.m_mod += diff;
            //  Change preliminary x coordinate so that the node does not
            // move.
            li.m_prelim -= diff;
            //  Update extreme node and its sum of modifiers.
            t.m_children[0].m_leftExtreme = t.m_children[i].m_leftExtreme;
            t.m_children[0].m_leftExtremeModSum = t.m_children[i].m_leftExtremeModSum;
        }

        //  Symmetrical to setLeftThread.
        static void SetRightThread(Tree<T> t, int i, Tree<T> sr, float modsumsr)
        {
            Tree<T> ri = t.m_children[i].m_rightExtreme;
            ri.rightThread = sr;
            float diff = (modsumsr - sr.m_mod) - t.m_children[i].m_rightExtremeModSum;
            ri.m_mod += diff;
            ri.m_prelim -= diff;
            t.m_children[i].m_rightExtreme = t.m_children[i - 1].m_rightExtreme;
            t.m_children[i].m_rightExtremeModSum = t.m_children[i - 1].m_rightExtremeModSum;
        }

        static void PositionRoot(Tree<T> t)
        {
            //  Position root between children, taking into account their
            // mod.
            t.m_prelim = (t.m_children[0].m_prelim + t.m_children[0].m_mod +
                          t.m_children[t.m_children.Count - 1].m_mod +
                          t.m_children[t.m_children.Count - 1].m_prelim +
                          t.m_children[t.m_children.Count - 1].m_width) /
                         2 -
                         t.m_width / 2;
        }

        static void SecondWalk(Tree<T> t, float modsum)
        {
            modsum += t.m_mod;
            //  Set absolute (non-relative) horizontal coordinate.
            t.m_x = t.m_prelim + modsum;
            AddChildSpacing(t);
            for (int i = 0; i < t.m_children.Count; i++)
                SecondWalk(t.m_children[i], modsum);
        }

        static void DistributeExtra(Tree<T> t, int i, int si, float dist)
        {
            //  Are there intermediate children?
            if (si != i - 1)
            {
                float nr = i - si;
                t.m_children[si + 1].m_shift += dist / nr;
                t.m_children[i].m_shift -= dist / nr;
                t.m_children[i].m_change -= dist - dist / nr;
            }
        }

        //  Process change and shift to add intermediate spacing to mod.
        static void AddChildSpacing(Tree<T> t)
        {
            float d = 0, modsumdelta = 0;
            for (int i = 0; i < t.m_children.Count; i++)
            {
                d += t.m_children[i].m_shift;
                modsumdelta += d + t.m_children[i].m_change;
                t.m_children[i].m_mod += modsumdelta;
            }
        }

        //  A linked list of the indexes of left siblings and their lowest
        // vertical coordinate.
        internal class Iyl
        {
            public float lowY;
            public int index;
            public Iyl nxt;

            public Iyl(float lowY, int index, Iyl nxt)
            {
                this.lowY = lowY;
                this.index = index;
                this.nxt = nxt;
            }
        }

        static Iyl UpdateIyl(float minY, int i, Iyl ih)
        {
            //  Remove siblings that are hidden by the new subtree.
            while (ih != null && minY >= ih.lowY)
                ih = ih.nxt;
            //  Prepend the new subtree.
            return new Iyl(minY, i, ih);
        }
    }
}