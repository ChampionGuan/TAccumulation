using System;

namespace UnityEngine.Timeline
{
    [AttributeUsage(AttributeTargets.Class)]
    public class TrackClipYellowColorAttribute : TrackClipColorAttribute
    {
        public TrackClipYellowColorAttribute() : base(1f, 1f, 0f)
        {
        }
    }
}