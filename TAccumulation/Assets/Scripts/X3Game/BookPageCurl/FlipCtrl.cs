using System;
using System.Collections;
using System.Collections.Generic;
using BookCurlPro;
using UnityEngine;

namespace BookCurlPro
{
    public class FlipCtrl : MonoBehaviour
    {
        public Transform followPoint;
    
        private BookPro book;
        private void OnEnable()
        {
            book = null;
        }
    
        // Update is called once per frame
        void Update()
        {
            if (followPoint)
            {
                if (book == null)
                {
                    book = GetComponent<BookPro>();
                    book.CurrentPaper = 0;
                    book.DragRightPageToPoint(followPoint.localPosition);
                }
                else
                {
                    book.UpdateBookRTLToPoint(followPoint.localPosition);
                }
            }
           
        }
    }
}
