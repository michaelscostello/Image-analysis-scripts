macro "Close All Windows" { 
      while (nImages>0) { 
          selectImage(nImages); 
          close(); 
      } 
  } 