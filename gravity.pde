//RECTWARS
// IN A WONDERFULL UNIVERSE WITH RECTANGLES SOMETHING EVIL IS COMING, FIGHT THE RED CIRCLES OR THEY WILL INFEST YOU!!
//author Jeppe Tuxen
//itu 2011


World world;
Ship ship;
//Glow glow;

ArrayList enemies;
int nrOfEnemies = 10;

//Here are the different gameStates;
boolean gameOver;
boolean gameWon;

//Named integers so its easier to hold track on keyInputs
static final int KEY_UP = 0;
static final int KEY_LEFT = 1;
static final int KEY_RIGHT = 2;
static final int KEY_SPACE = 3;
boolean [] keyInput = { //Array to track keyInput
	false,false,false,false
};

// Zoom variables;
float maxZoom = 3;
float scaleXY = maxZoom;




void setup() {
	size(1000,600);
	smooth();

	//INITIALIZES THE ELLEMENTS AND GAMESTATES
	ship = new Ship();
	world = new World();
	//  glow = new Glow();
	enemies = new ArrayList();
	gameOver = false;
	gameWon = false;

	// FILL THE ENEMY ARRAY WITH ENEMIES
	for (int i = 0; i < nrOfEnemies ; i++) {
		PVector currentVector = new PVector (random(0,width),random(0,height));
		EllipseOfDeath enemy = new EllipseOfDeath(currentVector);
		enemies.add(enemy);
	}
}

void draw() {

	//MAIN GAME STATE
	if (!gameOver && !gameWon) {
		pushMatrix();//HOLD TRACK OF POSITION

		//CONTROLS THE XY POSITION OF THE "CAMERA", ITS IMPORTENT TO INCLUDE THE SCALE VARIABLE IN HERE
		float xTrans = width/2-scaleXY*width/2;
		float yTrans = constrain(height/2-scaleXY*ship.position.y,height-scaleXY*height,0);
		translate (xTrans,yTrans);

		//SCALES THE DISPLAY
		scale(scaleXY);
		//println("im looping")
		world.display();
		ship.display();

		//ENEMIES TO THE SCREEN
		displayAndUpdateEnemies();

		//BASIC PHYSICS;
		checkBulletCollision();
		checkShipCollision();

		//CHECK IF NO ENEMIES
		checkWinningCondition();

		popMatrix();
		removeDeadBullets();

		//glow.process();
		calcScale();
	}


	//GAME OVER STATE

	else if(gameOver) {

		//SOME DISPLAY STUFF
		background(0);
		fill(255);
		textAlign(CENTER);

		//FILL IN THE TEXT
		text("THE CIRCS HAVE INFESTED YOU!",width/2,height/2);
		text("GAME OVER!",width/2,height/2+20);
		text("Press mouse to restart",width/2,height/2+40);

		//PRESS MOUSE TO RESET GAME
		if (mousePressed) {
			setup();
		}
	}


	//GAME WON STATE
	else if (gameWon) {

		// SOME DISPLAY
		background(0);
		fill(255);
		textAlign(CENTER);

		// TEXT
		text("CONGRATULATIONS!!",width/2,height/2);
		text("YOU HAVE EXTERMINATED THE EVIL CIRCS",width/2,height/2+20);
		text("Press mouse to restart",width/2,height/2+40);

		//HOW TO RESTART THE GAME
		if (mousePressed) {
			setup();
		}
	}
}

// CALCULATES THE SCALEFACTOR BY TAKING THE SHIPS POSITION FROM THE MIDDLE OF THE SCREEN
void calcScale() {
	float distanceFromMiddle = dist(width/2,0,ship.position.x,0);
	float distFactor = distanceFromMiddle/(width/2);

	//SCALE VALUE IS CONSTRAINED SO CAMERA WONT GO OUTSIDE WORLD
	scaleXY = constrain(maxZoom-distFactor*(maxZoom-0.2),1,maxZoom);

	//println (scaleXY);// FOR DEBUG
}

// ENEMIES 
void displayAndUpdateEnemies() {

	//NEED TO GO THROUGH ALL ENEMIES IN ARRAY
	for (int i = 0; i < enemies.size(); i++) {
		EllipseOfDeath currentEnemy = (EllipseOfDeath) enemies.get(i);
		currentEnemy.display();
		currentEnemy.grow();
	}
}

//CHECKING COLLISION BETWEEN ENEMIES AND SHIP, CALCULATION THEIR DISTANCE AND HOLDING IT UP AGAINST SIZE OF ENEMIES
void checkShipCollision() {
	for (int i = 0; i < enemies.size(); i++) {
		//CREATING A NEW INSTANCE OF ELLIPSE FROM ENEMIES
		EllipseOfDeath currentDeath = (EllipseOfDeath) enemies.get(i);
		// CALCULATION DISTANCE BETWEEN SHIP AND CURRENT ELLIPSE
		float distance = dist(ship.position.x,ship.position.y,currentDeath.position.x,currentDeath.position.y);

		// IF COLLISION IS DETECTED SHIP IS FLAGGED DEAD
		if (distance <= currentDeath.deathSize/2) {
			ship.isDead=true;
		}
	}
}

// CHECKS IF BULLETS ARE HITTING THE ENEMIES
void checkBulletCollision() {

	// Going through all bullets
	for(int i = 0; i < ship.bullets.size(); i++) {

		//CREATING A BULLET INSTANCE OF I VALUE FROM BULLETS ARRAY
		Bullet currentBullet = (Bullet) ship.bullets.get(i);

		// Going through all enemies for this particular bullet
		for (int u = 0 ; u < enemies.size() ; u++) {

			//CREATING A ENEMY INSTANCE OF U VALUE FROM ENEMIES ARRAY
			EllipseOfDeath currentEllipseOfDeath = (EllipseOfDeath) enemies.get(u);

			//CALCULATION THE DISTANCE BETWEEN THE TWO
			float distance = dist(currentBullet.position.x,currentBullet.position.y,currentEllipseOfDeath.position.x,currentEllipseOfDeath.position.y);

			//println(distance);
			// IF COLLISION IS DETECTED
			if (distance <= currentEllipseOfDeath.deathSize/2) {
				//FLAG BULLET DEAD
				currentBullet.isDead = true;
				//FLAG HIT ON ENEMY
				currentEllipseOfDeath.hitByBullet = true;
				//DECREASE SIZE OF ENEMY BUT CONSTRAIN TO MIN 0
				currentEllipseOfDeath.deathSize = constrain(currentEllipseOfDeath.deathSize - currentBullet.POWER,0,1000000);
				//IF ENEMY SIZE IS ZERO ITS REMOVED FROM ARRAY
				if (currentEllipseOfDeath.deathSize <= 0) {
					enemies.remove(u);
				}
			}
		}
	}
}

void removeDeadBullets(){
	for (int i = 0; i < ship.bullets.size(); i++){
		Bullet currentBullet = (Bullet) ship.bullets.get(i);
		if (currentBullet.isDead){
			ship.bullets.remove(i);
		}
	}
}

//TOO SEE THERE ARE ANY ENEMIES LEFT
void checkWinningCondition() {
	if (enemies.size()<1) {
		gameWon = true;
	}
}

// HERE IS THE INPUT SYSTEM, 4 KEYS ARE NEEDED.

void keyPressed() {
	if (key == CODED) {
		if (keyCode == UP) {
			keyInput[KEY_UP] = true;
			//println("KEY_UP" + keyInput[KEY_UP]);
		}

		if (keyCode == LEFT) {
			keyInput[KEY_LEFT] = true;
		}
		if (keyCode == RIGHT) {
			keyInput[KEY_RIGHT] = true;
		}
	}
	if (key == ' ') {
		keyInput[KEY_SPACE] = true;
	}
}

void keyReleased() {
	if (key == CODED) {
		if (keyCode == UP) {
			keyInput[KEY_UP] = false;
			//println("KEY_UP" + keyInput[KEY_UP]);
		}

		if (keyCode == LEFT) {
			keyInput[KEY_LEFT] = false;
		}
		if (keyCode == RIGHT) {
			keyInput[KEY_RIGHT] = false;
		}
	}
	if (key == ' ') {
		keyInput[KEY_SPACE] = false;
	}
}


// Class HyperLink


// BULLET
// Bullets are the weapon used by the ship, if they colide with the circs, 
// the circs will decrease in size.
class Bullet {

	//VARIABLES
	//Used to position and moving the Bullet
	PVector position;
	PVector speed;

	//STATIC PROPERTIES
	float BULLETSIZE = 1;
	float BULLETSPEED = 0.99;
	float POWER = 6;

	//Boolean used to tell if bullet is off screen, or has hit a Circ.
	boolean isDead;

	Bullet(PVector _position, PVector _direction) {
		position = new PVector(_position.x,_position.y);
		PVector direction = new PVector(_direction.x,_direction.y);
		speed = PVector.mult(direction,BULLETSPEED);
		isDead = false;
	}

	void display() {
		fill(255);
		noStroke();
		move();
		pushMatrix();
		translate(position.x,position.y)
		rect(0,0,BULLETSIZE,BULLETSIZE);
		popMatrix();
		updateLife();
	}

	void move() {
		position = PVector.add(position,speed);
	}

	void updateLife() {
		if (position.x < 0 || position.x > width) {
			isDead = true;
		}
		else if (position.y < 0 || position.y > height) {
			isDead = true;
		}
	}
}



class EllipseOfDeath {

	PVector position;

	color enemyColor = color(255,0,0,180);
	color hitColor;

	boolean hitByBullet;

	float deathSize = 0.001;

	float growth = 0.07;
	float oscSpeed = 20;
	float oscFactor = 0.4;

	EllipseOfDeath(PVector _position) {
		position = _position;
		hitColor = color(random(100,255),random(100,255),random(100,255));
	}

	void display() {
		noStroke();
		if (hitByBullet) {
			fill (hitColor);
			hitByBullet = false;
		}
		else fill(enemyColor);

		ellipseMode(CENTER);
		ellipse(position.x,position.y,deathSize,deathSize);
	}

	void grow() {
		float oscilation = sin(oscSpeed* millis()/1000)* oscFactor;
		deathSize = deathSize + growth + oscilation;
	}
}

/*class Glow {

ArrayList vectors = new ArrayList();
float threshold = 250;

int minBlurSize = 20;
int maxBlurSize = 21;

int intensity = 10;

color blurColor = color(255,255,255);

Glow() {
}

void process() {
loadPixels();
for (int x = 0; x < width; x++) {
for (int y = 0; y < height; y++) {
int loc = x + y*width; 

if (brightness(pixels[loc]) > threshold) {
PVector tempVector = new PVector(x,y);
vectors.add(tempVector);
}
}
}
int blurSize = (int) random(minBlurSize,maxBlurSize);
for (int i=0;i<vectors.size();i=i+1) {
PVector tempVector = (PVector) vectors.get(i);
fill(blurColor,intensity);
noStroke();
ellipseMode(CENTER);
ellipse(tempVector.x,tempVector.y,blurSize,blurSize);
}

vectors.clear();
}
}*/

class Particle {

	PVector position;
	PVector speed;

	boolean isOffScreen;

	boolean isDead=false;

	Particle(PVector _position, PVector _speed) {
		position = _position;
		speed = _speed;
		isOffScreen = false;
	}

	void display() {
		fill(randomColor());
		rect(position.x,position.y,1,1);
	}

	void move() {
		position = PVector.add(position,speed);
	}

	color randomColor() {
		color returnColor = color(random(255),random(255),random(255));
		return returnColor;
	}
}

class Ship {
	PVector position;
	PVector speed;
	float thrust;
	float speedFactor;
	float rotation;
	float airDensity;
	float maxSpeed;
	int recapLength = 100;
	boolean hasFired;
	boolean isDead;
	ArrayList bullets;
	ArrayList particles;
	boolean thrustOn;

	static final int SIZE = 4;
	static final float ROTATIONSPEED = PI/40;

	Ship() {
		position = new PVector(width/2,height-SIZE/2);
		speed = new PVector(0,0);
		rotation = 0;
		airDensity = 0.99;
		speedFactor = 0.03;
		thrustOn = false;
		bullets = new ArrayList();
		hasFired = false;
		isDead = false;
		// bullet = new Bullet();
		bullets = new ArrayList();
		particles = new ArrayList();
		for (int x = 0; x < SIZE ; x++) {
			for (int y = 0; y < SIZE ; y++) {
				PVector position = new PVector (x-SIZE/2,y-SIZE/2);
				PVector speed = position;
				Particle currentParticle = new Particle(position,speed);
				particles.add(currentParticle);
			}
		}
		// bullets.add(bullet);
		maxSpeed = 1;
	}

	void display() {

		if (!isDead) {
			move();
			pushMatrix();
			translate(position.x,position.y);
			rotate(rotation);

			noStroke();
			fill(255);
			rectMode(CENTER);
			rect(0,0,SIZE,SIZE);
			if (thrustOn) {
				drawThrust();
			}
			popMatrix();
			fireBullet();
			displayBullets();

		}

		else {
			pushMatrix();
			translate(position.x,position.y);
			rotate(rotation);
			explosion();
			popMatrix();
		}
	}

	void move() {
		setSpeed();
		setRotation();
		position = PVector.add(position,speed);
		checkBounderies();
	}

	void checkBounderies() {
		if (position.x<0 || position.x>width) {
			speed.x=speed.x*-1;
		}
		if (position.y<0 || position.y>height) {
			speed.y=speed.y*-1;
		}
	}

	void drawThrust() {
		color c = color (random(100,255),random(100,255),random(100,255));
		int flameLength = (int) random (5,10);
		noStroke();
		fill(c);
		rectMode(TOP,LEFT);
		pushMatrix();
		translate(-0.5,SIZE/2)
		rect(0,0,1.0,flameLength);
		popMatrix();
	}

	void setSpeed() {
		//println("setting the speed");
		if (keyInput[KEY_UP]) {
			speed.x= constrain(speed.x + sin(rotation)*speedFactor,-maxSpeed,maxSpeed);
			speed.y= constrain(speed.y - cos(rotation)*speedFactor,-maxSpeed,maxSpeed);
			thrustOn = true;

		}
		else {

			speed.x = speed.x * airDensity;
			speed.y = speed.y * airDensity;
			thrustOn = false;
		}
	}

	void setRotation() {
		if (keyInput[KEY_LEFT]) {
			rotation -= ROTATIONSPEED;
		}

		if (keyInput[KEY_RIGHT]) {
			rotation += ROTATIONSPEED;
		}
	}

	void fireBullet() {
		if (keyInput[KEY_SPACE]) {

			PVector newFireDirection = new PVector(sin(rotation),-cos(rotation));


			Bullet newBullet = new Bullet(position,newFireDirection);




			bullets.add(newBullet);

			hasFired = true;


			keyInput[KEY_SPACE] = false;
		}
	}
	void displayBullets() {

		for (int i = 0; i<bullets.size();i++) {
			Bullet currentBullet = (Bullet) bullets.get(i);
			currentBullet.display();
			currentBullet.move();
		}
	}

	void killOffScreenBullets() {
		for (int i = 0; i<bullets.size();i++) {
			Bullet currentBullet = (Bullet) bullets.get(i);
			if (currentBullet.isDead) {
				bullets.remove(i);
			}
		}
	}

	void explosion() {
		for (int i = 0 ; i < particles.size(); i++) {
			Particle currentParticle = (Particle) particles.get(i);
			currentParticle.display();
			currentParticle.move();
			if (currentParticle.position.x<-recapLength || currentParticle.position.x>recapLength || currentParticle.position.y<-recapLength || currentParticle.position.y>recapLength) {
				currentParticle.isDead = true;
			}
			if (currentParticle.isDead) {
				particles.remove(i);
			}
		}
		if (particles.size()<=1) {
			gameOver = true;
		}
	}
}

class World {

	int nrOfStars = 100;
	PVector[] stars = new PVector[nrOfStars];

	World () {
		for (int i=0;i<stars.length;i++) {
			PVector currentVec = new PVector(random(width),random(height));
			stars[i] = currentVec;
		}
	}

	void display() {
		background(0);
		for (int i=0;i<stars.length;i++) {
			fill(255);
			noStroke();
			rectMode(CENTER);
			rect(stars[i].x,stars[i].y,1,1);
		}
		stroke(255);
		noFill();
	}
}


