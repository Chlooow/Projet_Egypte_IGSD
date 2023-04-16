int cols, rows;
int scl = 20;
int w = 6000;
int h = 6000;

PImage texture1;
//float flying = 0;

float[][] terrain;

void terrainSable() {
  //size(1000, 1000, P3D);
  cols = w / scl;
  rows = h/ scl;
  terrain = new float[cols][rows];
  texture0 = loadImage("sable.jpg");
  
  // Generate the terrain using Perlin noise
  //flying -= 0.1;
  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      float noiseVal = noise(x * 0.05, y * 0.05, 0.05);
      terrain[x][y] = map(noiseVal, 0, 1, -100, 100);
    }
  }
  
  // Set the lighting and background colors
  perspective();
  //directionalLight(255, 255, 255, 0, 0, -1);
  //pointLight(207, 100, 50, 7, 50, 15);
  //ambientLight(127, 127, 127);
  //background(255, 204, 102);
  
  // Draw the sand dunes using triangle strips
  textureMode(NORMAL);
  
  noStroke();
  fill(194, 178, 128);
  //translate(width/2, height/2 + 400);
  //rotateX(PI/2.5);
  //scale(2);
  //pushMatrix();
  //translate(-w/2, -h/2);
  //popMatrix();
  for (int y = 0; y < rows-1; y++) {
    beginShape(QUAD_STRIP);
    for (int x = 0; x < cols; x++) {
      vertex(x*scl, y*scl, terrain[x][y], 10, 30);
      vertex(x*scl, (y+1)*scl, terrain[x][y+1], 20, 30);
    }
    endShape();
    
  }
 // texture(texture0);
}
