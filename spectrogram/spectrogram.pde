 
import ddf.minim.analysis.*;
import ddf.minim.*;


Table table;

 
Minim minim;
AudioInput in;
FFT fft;
int colmax = 500;
int rowmax = 256;
int[][] sgram = new int[rowmax][colmax];
int[][][] sgramRGB = new int[rowmax][colmax][3];

int col;
int leftedge;

Colormap cm = new Colormap();

void setup()
{
  size(512, 256, P3D);
  table = new Table();
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO,1024);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.window(FFT.HAMMING);
  
  for(int i = 0; i < 513; i++){
    table.addColumn("bin" + i);
  }
}
 
void draw()
{
  background(0);
  stroke(255);
 
  fft.forward(in.mix);
  
  TableRow newRow = table.addRow();
  for(int i = 0; i < 513; i++){
    newRow.setFloat("bin"+i, fft.getBand(i));
  }
  

  for(int i = 0; i < rowmax ; i++)
  {
    // fill in the new column of spectral values
    sgram[i][col] = (int)Math.round(Math.max(0,2*20*Math.log10(1000*fft.getBand(i))));
    sgramRGB[i][col] = cm.getColor((sgram[i][col]/255f));
  }
  
  col = col + 1; 
 
  if (col == colmax) { col = 0; }
  
  for (int i = 0; i < colmax-leftedge; i++) {
    for (int j = 0; j < rowmax; j++) {
      //stroke(sgram[j][i+leftedge]);
      stroke(sgramRGB[j][i+leftedge][0],sgramRGB[j][i+leftedge][1],sgramRGB[j][i+leftedge][2]);
      point(i,height-j);
    }
  }
  
  for (int i = 0; i < leftedge; i++) {
    for (int j = 0; j < rowmax; j++) {
      //stroke(sgram[j][i]);
      stroke(sgramRGB[j][i][0], sgramRGB[j][i][1],sgramRGB[j][i][2]);
      point(i+colmax-leftedge,height-j);
    }
  }

  leftedge = leftedge + 1; 
  
  if (leftedge == colmax) { leftedge = 0; }
}
 
 
void stop()
{
  in.close();
  minim.stop();
  super.stop();
}

void keyPressed(){
 if(key == ' '){
   saveTable(table, "data/new_crossing.csv");
   println("table saved!");
 }
}