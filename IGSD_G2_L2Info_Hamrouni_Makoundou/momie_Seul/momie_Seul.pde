String[] vertSrc = { """
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
""" };


PImage texture0;
PShader shade;

PShape armr;
PShape body;
PShape head;

float ry;
PShape hand1; 
PShape hand2;

// il manque les shader sur la momie si on arrive a faire ca on est bien aussi

void setup(){
  size(1000, 1000, P3D);
  frameRate(2);
  texture0 = loadImage("bandages.png");
  shade = new PShader(g.parent, vertSrc, fragSrc );
  //for(int i = 0; i < vertSrc.length;i++) {
  //shade = loadShader(vertSrc[i], fragSrc[i]);
  //}
  hand1 = loadShape("hand1.obj");
  hand2 = loadShape("hand2.obj");
    
  armr = createShape();
  body = createShape();
  head = createShape();
  
  armr.beginShape(QUAD_STRIP);
  body.beginShape(QUAD_STRIP);
  
  armr.noStroke();
  body.noStroke();
  
  for (int i=-200; i<=250; i++){
    float a = i/50.0*2*PI;
    for (int j=-50; j<=50; j++){
      float R2 = 80+20*cos(i*PI/200);
      
      //Armr
      /*float xnoise = 0.0;
      float ynoise = 0.0;
      float znoise = 0.0;*/
      
      /*xnoise =+ 1.0;
      ynoise =+ 1.0;
      znoise =+ 1.0;*/
      float n = noise(i, j) * 256;
      // il faut avoir the perfect balance of color to get it yellow
      // ca affiche du vert jauné :/
      armr.fill(n*7,n*5,n+40);
      armr.vertex(R2*cos(a), R2*sin(a),i);
      armr.vertex(R2*cos(a), R2*sin(a),i+60);

      //Body
      textureMode(NORMAL);
      texture(texture0);
      
      body.fill(n*7,n*5,n+40);
      body.vertex(R2*cos(a), R2*sin(a),i, 10, 30);
      body.vertex(R2*cos(a), R2*sin(a),i+80, 20, 30);
      body.tint(n*7,n*5,n+40);
      
    }
  }
  armr.endShape();
  body.endShape();
  body.setTexture(texture0);
  head.setTexture(texture0);
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
      shader(shade);
     }
  }
  head.endShape();
  
}

// Pour mettre la momie dans le labyrinthe il faut utiliser framecount pour la deplacer 
// il faut la mettre à un posx, posy dans le draw
void draw(){
 
  perspective();
  lights();
  //spotLight(51, 102, 126, 200, 200, 1600, 
         // 0, 0, -1, PI/16, 30); 
  //pointLight(51, 102, 126, 140, 160, 144);
  //pointLight(50, 0, 50, 7, 50, 15);
  translate(width/2, height/1.5);
  rotateX(PI/2);
  background(255,192,255);
  
  //CORPS
  pushMatrix();
  //shader(shade);
  scale(1,1.5,1);
  shape(body,0,0);
  popMatrix();  
  
  
  // BRAS DROIT
  pushMatrix();
  translate(-100,90,100);
  rotateX(PI/1.50);
  rotateY(PI);
  scale(0.2,0.5,0.5);
  shape(armr,0,0);
  popMatrix();
  
  // BRAS GAUCHE
  pushMatrix();
  translate(140,100,100);
  rotateX(PI/1.50);
  rotateY(PI);
  scale(0.2,0.5,0.5);
  shape(armr,200,0);
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
  
}
