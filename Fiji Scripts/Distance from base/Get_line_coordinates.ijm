getLine(x1, y1, x2, y2, lineWidth);
   if (x1==-1)
      exit("This macro requires a straight line selection");
   getPixelSize(unit, pw, ph);
   x1*=pw; y1*=ph; x2*=pw; y2*=ph;
   print("Starting point: (" + x1 + ", " + y1 + ")");
   print("Ending point: (" + x2 + ", " + y2 + ")");
   print("Width:", lineWidth, "pixels");
   dx = x2-x1; dy = y2-y1;
   length = sqrt(dx*dx+dy*dy);
   print("Length:", length, unit);