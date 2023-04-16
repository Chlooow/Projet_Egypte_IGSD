/*String[] vertSrc = { """
uniform mat4 transform;
uniform mat3 normalMatrix;
uniform vec4 lightPosition;
attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;
//varying vec4 vertColor;
varying vec3 vertNormal;
varying vec4 vertPosition;
varying vec4 vertColor;
void main() {
  gl_Position = transform * position;    
  //vec3 ecPosition = vec3(modelview * position);  
  //vec3 ecNormal = normalize(normalMatrix * normal);
  //vec3 direction = normalize(lightPosition.xyz - ecPosition);    
  //float intensity = max(0.0, dot(direction, ecNormal));
  //vertColor = vec4(intensity, intensity, intensity, 1) * color;     
  vertNormal   = normal;
  vertPosition = position;
  vertColor    = color;
}
""" };
String[] fragSrc = { """
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
varying vec4 vertColor;
void main() {
  gl_FragColor = vertColor;
}
""" };*/

//PShader shade;
int iposX = 1;
int iposY = -1;

int posX = iposX;
int posY = iposY;

int dirX = 0;
int dirY = 1;
int odirX = 0;
int odirY = 1;
int WALLD = 1;

int anim = 0;
boolean animT=false;
boolean animR=false;

boolean inLab = true;

int LAB_SIZE = 21;
char labyrinthe [][];
char sides [][][];

PShape laby0;
PShape ceiling0;
PShape ceiling1;

PImage texture0;
PImage gold;

// Ciel Bleu
PImage cielBleu;
//sable
PImage texture;
PShape ground;
PImage pyrSol;

PShape pyramid1,pyramid2, pyramid3, pyramid4,
pyramid5, pyramid6,pyramid7,pyramid8;
PShape pyr;

PImage texture2;
PShape hand1; 
PShape hand2;
PShape momiie;
PShape arm;
PShape body;
PShape head;
PShape sarcophage;

// ___________ MOMIE ________________

void momie() {
  arm = createShape();
  body = createShape();
  head = createShape();
  
  arm.beginShape(QUAD_STRIP);
  body.setTexture(texture2);
  body.beginShape(QUAD_STRIP);
  
  arm.noStroke();
  body.noStroke();
  
  for (int i=-200; i<=250; i++){
    float a = i/50.0*2*PI;
    for (int j=-50; j<=50; j++){
      float R2 = 80+20*cos(i*PI/200);

      float n = noise(i, j) * 256;
      // il faut avoir the perfect balance of color to get it yellow
      // ca affiche du vert jauné :/
      arm.fill(n*7,n*5,n+40);
      arm.vertex(R2*cos(a), R2*sin(a),i);
      arm.vertex(R2*cos(a), R2*sin(a),i+60);

      //Body
      textureMode(NORMAL);
      texture(texture2);
      
      //body.fill(n*7,n*5,n+40);
      body.vertex(R2*cos(a), R2*sin(a),i, 10, 30);
      body.vertex(R2*cos(a), R2*sin(a),i+80, 20, 30);
      body.tint(n*7,n*5,n+40);
    }
  }
  arm.endShape();
  body.endShape();
  
  head.setTexture(texture2);
  // on dessine la tête 
  head.beginShape(QUAD_STRIP);
  head.noStroke();
  for (int i=-100; i<=200; i++){
    float a = i/50.0*2*PI;
    for (int j=-50; j<=50; j++){
      float RBig = 160+40*cos(i*PI/200);
      float R2 = RBig;
      
      // Head
      float n = noise(i, j) * 256;
      fill(n*7,n*5,n+40);
      head.vertex(R2*cos(a), R2*sin(a),i, 100, 10);
      head.vertex(R2*cos(a), R2*sin(a),i+60, 100, 20);
      head.tint(n*7,n*5,n+40);
     }
  }
  head.endShape();
}

// ___________ FIN MOMIE ________________

// ___________________________

void setup() { 
  
  frameRate(50);
  randomSeed(2);
  texture0 = loadImage("stones.jpg");
  gold = loadImage("gold.jpg");
  texture = loadImage("sable.jpg");
  pyrSol = loadImage("pierre.jpg");
  
  cielBleu = loadImage("cielbleu.jpg");
  cielBleu.resize(1000, 1000);
  
  texture2 = loadImage("bandages.png");
  //shade = new PShader(g.parent, vertSrc, fragSrc );
  
  hand1 = loadShape("hand1.obj");
  hand2 = loadShape("hand2.obj");
  
  sarcophage = loadShape("FrontSarcophagus.obj");
  sarcophage.setTexture(gold);
  
  size(1000, 1000, P3D);
  
   // __________________
  ground = createShape();
  ground.setTexture(texture);
  ground.texture(texture);
  textureWrap(REPEAT);
  ground.beginShape(QUADS);
  ground.normal(0, 1, 0);
  ground.vertex(-1000, 0, -1000, 1, 0);
  ground.vertex(1000, 0, -1000, 0, 1);
  ground.vertex(1000, 0, 1000, 1000, 1000);
  ground.vertex(-1000, 0, 1000, 0, 1000);
  ground.endShape();
 // _______________________________________
  
  labyrinthe = new char[LAB_SIZE][LAB_SIZE];
  sides = new char[LAB_SIZE][LAB_SIZE][4];
  int todig = 0;
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      sides[j][i][0] = 0;
      sides[j][i][1] = 0;
      sides[j][i][2] = 0;
      sides[j][i][3] = 0;
      if (j%2==1 && i%2==1) {
        labyrinthe[j][i] = '.';
        todig ++;
      } else
        labyrinthe[j][i] = '#';
    }
  }
  int gx = 1;
  int gy = 1;
  while (todig>0 ) {
    int oldgx = gx;
    int oldgy = gy;
    int alea = floor(random(0, 4)); // selon un tirage aleatoire
    if      (alea==0 && gx>1)          gx -= 2; // le fantome va a gauche
    else if (alea==1 && gy>1)          gy -= 2; // le fantome va en haut
    else if (alea==2 && gx<LAB_SIZE-2) gx += 2; // .. va a droite
    else if (alea==3 && gy<LAB_SIZE-2) gy += 2; // .. va en bas

    if (labyrinthe[gy][gx] == '.') {
      todig--;
      labyrinthe[gy][gx] = ' ';
      labyrinthe[(gy+oldgy)/2][(gx+oldgx)/2] = ' ';
    }
  }

  labyrinthe[0][1]                   = ' '; // entree
  labyrinthe[LAB_SIZE-2][LAB_SIZE-1] = ' '; // sortie

  for (int j=1; j<LAB_SIZE-1; j++) {
    for (int i=1; i<LAB_SIZE-1; i++) {
      if (labyrinthe[j][i]==' ') {
        if (labyrinthe[j-1][i]=='#' && labyrinthe[j+1][i]==' ' &&
          labyrinthe[j][i-1]=='#' && labyrinthe[j][i+1]=='#')
          sides[j-1][i][0] = 1;// c'est un bout de couloir vers le haut 
        if (labyrinthe[j-1][i]==' ' && labyrinthe[j+1][i]=='#' &&
          labyrinthe[j][i-1]=='#' && labyrinthe[j][i+1]=='#')
          sides[j+1][i][3] = 1;// c'est un bout de couloir vers le bas 
        if (labyrinthe[j-1][i]=='#' && labyrinthe[j+1][i]=='#' &&
          labyrinthe[j][i-1]==' ' && labyrinthe[j][i+1]=='#')
          sides[j][i+1][1] = 1;// c'est un bout de couloir vers la droite
        if (labyrinthe[j-1][i]=='#' && labyrinthe[j+1][i]=='#' &&
          labyrinthe[j][i-1]=='#' && labyrinthe[j][i+1]==' ')
          sides[j][i-1][2] = 1;// c'est un bout de couloir vers la gauche
      }
    }
  }

  // un affichage texte pour vous aider a visualiser le labyrinthe en 2D
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      print(labyrinthe[j][i]);
    }
    println("");
  }
  // _______________________________
  float wallW = width/LAB_SIZE;
  float wallH = height/LAB_SIZE;

  ceiling0 = createShape();
  ceiling1 = createShape();
  
  ceiling1.setTexture(texture0);
  
  ceiling1.beginShape(QUADS);
  ceiling0.beginShape(QUADS);
  
  laby0 = createShape();
  laby0.setTexture(texture0);
  laby0.beginShape(QUADS);
  laby0.texture(texture0);
  laby0.noStroke();
  noLights();
  laby0.tint(204, 172, 0);
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      if (labyrinthe[j][i]=='#') {
        
        laby0.fill(i*25, j*25, 255-i*10+j*10);
        if (j==0 || labyrinthe[j-1][i]==' ') {
          laby0.normal(0, -1, 0);
          for (int k=0; k<WALLD; k++)
            for (int l=-WALLD; l<WALLD; l++) {
              laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH-wallH/2, (l+0)*50/WALLD, k/(float)WALLD*texture0.width, (0.5+l/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH-wallH/2, (l+0)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+l/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH-wallH/2, (l+1)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH-wallH/2, (l+1)*50/WALLD, k/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
            }
        }
        if (j==LAB_SIZE-1 || labyrinthe[j+1][i]==' ') {
          laby0.normal(0, 1, 0);
          for (int k=0; k<WALLD; k++)
            for (int l=-WALLD; l<WALLD; l++) {
              laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH+wallH/2, (l+1)*50/WALLD, (k+0)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH+wallH/2, (l+1)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD, j*wallH+wallH/2, (l+0)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD, j*wallH+wallH/2, (l+0)*50/WALLD, (k+0)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
            }
        }
        if (i==0 || labyrinthe[j][i-1]==' ') {
          laby0.normal(-1, 0, 0);
          for (int k=0; k<WALLD; k++)
            for (int l=-WALLD; l<WALLD; l++) {
              laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2+(k+0)*wallW/WALLD, (l+1)*50/WALLD, (k+0)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2+(k+1)*wallW/WALLD, (l+1)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2+(k+1)*wallW/WALLD, (l+0)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2+(k+0)*wallW/WALLD, (l+0)*50/WALLD, (k+0)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
            }
        }
        if (i==LAB_SIZE-1 || labyrinthe[j][i+1]==' ') {
          laby0.normal(1, 0, 0);
          for (int k=0; k<WALLD; k++)
            for (int l=-WALLD; l<WALLD; l++) {
              laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+0)*wallW/WALLD, (l+0)*50/WALLD, (k+0)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+1)*wallW/WALLD, (l+0)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+1)*wallW/WALLD, (l+1)*50/WALLD, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2+(k+0)*wallW/WALLD, (l+1)*50/WALLD, (k+0)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
            }
        }
        ceiling1.fill(200, 172, 0);
        ceiling1.noStroke();
        ceiling1.vertex(i*wallW-wallW/2, j*wallH-wallH/2, 50,1, 0);
        ceiling1.vertex(i*wallW+wallW/2, j*wallH-wallH/2, 50,0, 1);
        ceiling1.vertex(i*wallW+wallW/2, j*wallH+wallH/2, 50,1, 1);
        ceiling1.vertex(i*wallW-wallW/2, j*wallH+wallH/2, 50, 0, 0);        
      } else {
        //laby0.fill(192); // ground
        //laby0.fill(204, 172, 0);        
        laby0.fill(i*25, j*25, 255-i*10+j*10); // ground
        laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2, -50, 0, 0);
        laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2, -50, 0, 1);
        laby0.vertex(i*wallW+wallW/2, j*wallH+wallH/2, -50, 1, 1);
        laby0.vertex(i*wallW-wallW/2, j*wallH+wallH/2, -50, 1, 0);
        //texture(pyrSol);        
        ceiling0.fill(0); // top of walls
        ceiling0.vertex(i*wallW-wallW/2, j*wallH-wallH/2, 50);
        ceiling0.vertex(i*wallW+wallW/2, j*wallH-wallH/2, 50);
        ceiling0.vertex(i*wallW+wallW/2, j*wallH+wallH/2, 50);
        ceiling0.vertex(i*wallW-wallW/2, j*wallH+wallH/2, 50);
      }
    }
  }
  laby0.endShape();
  ceiling0.endShape();
  ceiling1.endShape();  
  // __________________  
  pyramid1 = etagePyr(900, 900, 90);
  pyramid2 = etagePyr(800, 800, 90);
  pyramid3 = etagePyr(700, 700, 90);
  pyramid4 = etagePyr(600, 600, 90);
  pyramid5 = etagePyr(500, 500, 90);
  pyramid6 = etagePyr(400, 400, 90);
  pyramid7 = etagePyr(200, 200, 90);
  pyramid8 = etagePyr(100, 100, 90);
  
  // ------------------
  momie();
}
// _______________________ PYRAMIDE ______________________________

PShape etagePyr(float boxWidth, float boxHeight, float boxDepth) {
  PShape all = createShape(GROUP);
  
  float halfBoxWidth = boxWidth / 2;
  float halfBoxHeight = boxHeight / 2;
  float halfBoxDepth = boxDepth / 2;
  pyr = createShape();
 
  pyr.setTexture(texture0);
  pyr.beginShape(QUADS);
  pyr.texture(texture0);
  pyr.textureMode(NORMAL);
  //textureWrap(REPEAT);
  pyr.tint(204, 172, 0);
  pyr.noStroke();
  
  // face avant
  /*pyr.vertex(-halfBoxWidth, -halfBoxHeight, halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(halfBoxWidth, -halfBoxHeight, halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(halfBoxWidth, halfBoxHeight, halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(-halfBoxWidth, halfBoxHeight, halfBoxDepth, texture0.width, texture0.height);
  */
  pyr.vertex(-halfBoxWidth, -halfBoxHeight, halfBoxDepth, 1, 0);
  pyr.vertex(halfBoxWidth, -halfBoxHeight, halfBoxDepth, 0, 1);
  pyr.vertex(halfBoxWidth, halfBoxHeight, halfBoxDepth, 1, 1);
  pyr.vertex(-halfBoxWidth, halfBoxHeight, halfBoxDepth, 0, 0);
  
  // face arrière
  /*pyr.vertex(-halfBoxWidth, -halfBoxHeight, -halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(halfBoxWidth, -halfBoxHeight, -halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(halfBoxWidth, halfBoxHeight, -halfBoxDepth , texture0.width, texture0.height);
  pyr.vertex(-halfBoxWidth, halfBoxHeight, -halfBoxDepth, texture0.width, texture0.height);
  */
  pyr.vertex(-halfBoxWidth, -halfBoxHeight, -halfBoxDepth, 1, 0);
  pyr.vertex(halfBoxWidth, -halfBoxHeight, -halfBoxDepth, 0, 1);
  pyr.vertex(halfBoxWidth, halfBoxHeight, -halfBoxDepth , 1, 1);
  pyr.vertex(-halfBoxWidth, halfBoxHeight, -halfBoxDepth, 0, 0);
  
  // face 
  pyr.tint(204, 172, 0);
  /*pyr.vertex(-halfBoxWidth, halfBoxHeight, halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(halfBoxWidth, halfBoxHeight, halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(halfBoxWidth, halfBoxHeight, -halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(-halfBoxWidth, halfBoxHeight, -halfBoxDepth, texture0.width, texture0.height);
  */
  pyr.vertex(-halfBoxWidth, halfBoxHeight, halfBoxDepth, 1, 0);
  pyr.vertex(halfBoxWidth, halfBoxHeight, halfBoxDepth, 0, 1);
  pyr.vertex(halfBoxWidth, halfBoxHeight, -halfBoxDepth, 1, 1);
  pyr.vertex(-halfBoxWidth, halfBoxHeight, -halfBoxDepth, 0, 0);
  
  // face inférieure
  /*pyr.vertex(-halfBoxWidth, -halfBoxHeight, halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(halfBoxWidth, -halfBoxHeight, halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(halfBoxWidth, -halfBoxHeight, -halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(-halfBoxWidth, -halfBoxHeight, -halfBoxDepth, texture0.width, texture0.height);
  */
  pyr.vertex(-halfBoxWidth, -halfBoxHeight, halfBoxDepth, 1, 0);
  pyr.vertex(halfBoxWidth, -halfBoxHeight, halfBoxDepth, 0, 1);
  pyr.vertex(halfBoxWidth, -halfBoxHeight, -halfBoxDepth, 1, 1);
  pyr.vertex(-halfBoxWidth, -halfBoxHeight, -halfBoxDepth, 0, 0);
  
  // face droite
  /*pyr.vertex(halfBoxWidth, -halfBoxHeight, halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(halfBoxWidth, -halfBoxHeight, -halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(halfBoxWidth, halfBoxHeight, -halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(halfBoxWidth, halfBoxHeight, halfBoxDepth, texture0.width, texture0.height);
  */
  
  pyr.vertex(halfBoxWidth, -halfBoxHeight, halfBoxDepth, 1, 0);
  pyr.vertex(halfBoxWidth, -halfBoxHeight, -halfBoxDepth, 0, 1);
  pyr.vertex(halfBoxWidth, halfBoxHeight, -halfBoxDepth, 1, 1);
  pyr.vertex(halfBoxWidth, halfBoxHeight, halfBoxDepth, 0, 0);
  
  // face gauche
  /*pyr.vertex(-halfBoxWidth, -halfBoxHeight, halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(-halfBoxWidth, -halfBoxHeight, -halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(-halfBoxWidth, halfBoxHeight, -halfBoxDepth, texture0.width, texture0.height);
  pyr.vertex(-halfBoxWidth, halfBoxHeight, halfBoxDepth, texture0.width, texture0.height);
  */
  pyr.vertex(-halfBoxWidth, -halfBoxHeight, halfBoxDepth, 1, 0);
  pyr.vertex(-halfBoxWidth, -halfBoxHeight, -halfBoxDepth, 0, 1);
  pyr.vertex(-halfBoxWidth, halfBoxHeight, -halfBoxDepth, 1, 1);
  pyr.vertex(-halfBoxWidth, halfBoxHeight, halfBoxDepth, 0, 0);
  
  pyr.endShape();
  all.addChild(pyr);
  
  all.setTexture(texture0);
  
  return all;

}

// _____________ CONE DE LA PYRAMIDE ______________

void trianglePyr(int t){
  
  beginShape(TRIANGLES);
  noStroke();
  //fill(255, 150); 
  texture(gold);
  vertex(-t, -t, -t, 1, 0);
  vertex( t, -t, -t, 1, 1);
  vertex( 0, 0, t, 0, 1);

  //fill(150, 150);
  texture(gold);
  vertex( t, -t, -t, 1, 0);
  vertex( t, t, -t, 1, 1);
  vertex( 0, 0, t, 0, 1);

  //fill(255, 150);
  texture(gold);
  vertex( t, t, -t, 1, 0);
  vertex(-t, t, -t, 1, 1);
  vertex( 0, 0, t, 0, 1);

  //fill(150, 150);
  texture(gold);
  vertex(-t, t, -t, 1, 0);
  vertex(-t, -t, -t, 1, 1);
  vertex( 0, 0, t, 0, 1);
  
  endShape();
}

// _____________ FIN CONE DE LA PYRAMIDE ______________


// __________________ DRAW ____________________________

void draw() {
  //background(192);
  background(cielBleu);
  sphereDetail(6);
  if (anim>0) anim--;
  
  float wallW = width/LAB_SIZE;
  float wallH = height/LAB_SIZE;
  //lights();


  pushMatrix();
  perspective();
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
  noLights();
  stroke(0);
  
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      if (labyrinthe[j][i]=='#') {
        fill(i*25, j*25, 255-i*10+j*10);
        pushMatrix();
        translate(50+i*wallW/8, 50+j*wallH/8, 50);
        box(wallW/10, wallH/10, 5);
        popMatrix();
      }
    }
  }
  
  //sphère dans la map
  pushMatrix();
  fill(0, 255, 0);
  noStroke();
  translate(50+posX*wallW/8, 50+posY*wallH/8, 50);
  sphere(3);
  popMatrix();
  //stroke(0);
  popMatrix();
  
  // ___________________________ AVENTURIER _____________________________________
  
  // camera
  if (inLab) {
    perspective(2*PI/3, float(width)/float(height), 1, 1000);
    if (animT)
      camera((posX-dirX*anim/20.0)*wallW,      (posY-dirY*anim/20.0)*wallH,      -15+2*sin(anim*PI/5.0), 
             (posX-dirX*anim/20.0+dirX)*wallW, (posY-dirY*anim/20.0+dirY)*wallH, -15+4*sin(anim*PI/5.0), 0, 0, -1);
    else if (animR)
      camera(posX*wallW, posY*wallH, -15, 
            (posX+(odirX*anim+dirX*(20-anim))/20.0)*wallW, (posY+(odirY*anim+dirY*(20-anim))/20.0)*wallH, -15-5*sin(anim*PI/20.0), 0, 0, -1);
    else {
      camera(posX*wallW, posY*wallH, -15, 
             (posX+dirX)*wallW, (posY+dirY)*wallH, -15, 0, 0, -1);
    }
    //camera((posX-dirX*anim/20.0)*wallW, (posY-dirY*anim/20.0)*wallH, -15+6*sin(anim*PI/20.0), 
    //  (posX+dirX-dirX*anim/20.0)*wallW, (posY+dirY-dirY*anim/20.0)*wallH, -15+10*sin(anim*PI/20.0), 0, 0, -1);

    //lightFalloff(0.0, 0.01, 0.0001);
    pointLight(255, 255, 255, posX*wallW, posY*wallH, 15);
    //lights();
    //ambientLight(90,0,0);
    ambientLight(102, 102, 102);
    //background(cielBleu);
    
  } else {
    //background(cielBleu);
    //lightFalloff(0.0, 0.05, 0.0001);
    //pointLight(255, 255, 255, posX*wallW, posY*wallH, 15);
    translate(0,0,-100);
    //rotateX(PI/6);
    lights();
    pointLight(255, 255, 255, posX*wallW, posY*wallH, 15);
    camera(width/2.0, height*3, height/2, width/2.0, height/2.0, 0, 0, 1, 0);
  }
  // ___________________________ FIN AVENTURIER ______________________________________________
  noStroke();
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      pushMatrix();
      translate(i*wallW, j*wallH, 0);
      if (labyrinthe[j][i]=='#') {
        beginShape(QUADS);
        if (sides[j][i][3]==1) {
          pushMatrix();
          translate(0, -wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
        if (sides[j][i][0]==1) {
          pushMatrix();
          translate(0, wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
         
         if (sides[j][i][1]==1) {
          pushMatrix();
          translate(-wallW/2, 0, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
         
        if (sides[j][i][2]==1) {
          pushMatrix();
          translate(0, wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
      } 
      popMatrix();
    }
  }
  
  // _______________ INLAB CONDITION ___________________
  
  shape(laby0, 0, 0);
  
  if (inLab){
    shape(ceiling0, 0, 0);
    // momie 
    /*pushMatrix();
    translate(1000, 1000, 1000);
    shape(momiie, 0, 0);
    popMatrix();*/
    
    
    /* pushMatrix();
    translate(0, 0, -100);
    //translate(width/2, height/2, 0);
    rotateX(PI/2);
    shape(ground);
    popMatrix();*/
    
    
  }else{
    pushMatrix();
    shape(ceiling1, 0, 0);
    popMatrix();
  }
  
  // _______________ FIN INLAB CONDITION ___________________
  
  pushMatrix();
  translate(width/2, height/2, 0);
  translate(0, 0, -100);
  rotateX(PI/2);
  shape(ground);
  popMatrix();
  
  // _______________ PYRAMID ___________________
    
    translate(472,472,96);
    //box(900, 900,90);
    shape(pyramid1, 0, 0);
    translate(0, 0, 90);

    //box(800, 800,90);
    shape(pyramid2, 0, 0);
    translate(0, 0, 90);
    
    //box(700, 700,90);
    shape(pyramid3, 0, 0);
    translate(0, 0, 90);
    
    //box(600, 600,90);
    shape(pyramid4, 0, 0);
    translate(0, 0, 90);
    
    //box(500, 500,90);
    shape(pyramid5, 0, 0);
    translate(0, 0, 90);
    
    //box(400, 400,90);
    shape(pyramid6, 0, 0);
    translate(0, 0, 90);
    
    //box(300, 300,90);
    shape(pyramid7, 0, 0);
    translate(0, 0, 90);
    
    //box(200, 200,90);
    shape(pyramid8, 0, 0);
    
    
    pushMatrix();
    translate(0,0,60);
    trianglePyr(200);
    popMatrix();
    
    // _______________ FIN PYRAMIDE ___________________
    
    //translate(1000, 1000, 1000);
    //translate(0, 0, 0);
    //scale(100);
    //momie();
    
  // ______________ MOMIE _______________________
    
  //translate(width/2, (height/2) -50);
  pushMatrix();
  translate(-370, -420, -750);
  scale(0.10);
  rotateX(2*PI);
  rotateZ(PI/2);
  
  //background(255,192,255);
  
  //CORPS
  pushMatrix();
  scale(1,1.5,1);
  shape(body,0,0);
  popMatrix();  
  
  
  // BRAS DROIT
  pushMatrix();
  translate(-100,90,100);
  rotateX(PI/1.50);
  rotateY(PI);
  scale(0.2,0.5,0.5);
  shape(arm,0,0);
  popMatrix();
  
  // BRAS GAUCHE
  pushMatrix();
  translate(140,100,100);
  rotateX(PI/1.50);
  rotateY(PI);
  scale(0.2,0.5,0.5);
  shape(arm,200,0);
  popMatrix();
  
  // main objet left
  pushMatrix();
  translate(-115,225,190);
  scale(5);
  rotateX(2.5*PI/1.5);
  shape(hand2);
  translate(45,0,0);
  shape(hand1);
  popMatrix();
  
  //TETE
  scale(0.5);
  translate(0,0,600);
  shape(head,0,0);
 
  //OEIL DROIT
  pushMatrix();
  noStroke();
  fill(255);
  translate(-50,180,100);
  sphere(30);
  
  //PUPILLE
  fill(0);
  translate(0,20,0);
  sphere(15);
  popMatrix();
  
  //OEIL GAUCHE
  pushMatrix();
  translate(70,180,100);
  fill(255);
  sphere(30);
  
  // PUPILLE
  fill(0);
  translate(0,20,0);
  sphere(15);
  popMatrix(); 
  //FIN MOMIE
  popMatrix();
  
  
  
  // __________________ FIN MOMIE _______________________
  pushMatrix();
  translate(-320, -340, -765);
  scale(20);
  rotateX(PI/2);
  rotateY(PI);  
  shape(sarcophage, 0, 0);
  popMatrix();
}

// __________________ FIN DRAW _____________________________

// _______________ KEYPRESSED ___________________

void keyPressed() {
  if (key=='l') inLab = !inLab;
  if (anim==0 && keyCode==38) {
    if (posX+dirX>=0 && posX+dirX<LAB_SIZE && posY+dirY>=0 && posY+dirY<LAB_SIZE &&
      labyrinthe[posY+dirY][posX+dirX]!='#') {
      anim=20;
      animT = true;
      animR = false;
    }
    posX+=dirX; 
      posY+=dirY;
      anim=20;
      animT = true;
      animR = false;
  }
  //reculer
  /*if (anim==0 && keyCode==40 && labyrinthe[posY-dirY][posX-dirX]!='#') {
    posX-=dirX; 
    posY-=dirY;
  }*/
  if (anim==0 && keyCode==37) {
    odirX = dirX;
    odirY = dirY;
    anim = 20;
    int tmp = dirX; 
    dirX=dirY; 
    dirY=-tmp;
    animT = false;
    animR = true;
  }
  if (anim==0 && keyCode==39) {
    odirX = dirX;
    odirY = dirY;
    anim = 20;
    animT = false;
    animR = true;
    int tmp = dirX; 
    dirX=-dirY; 
    dirY=tmp;
  }
}
// _______________ FIN KEYPRESSED ___________________
