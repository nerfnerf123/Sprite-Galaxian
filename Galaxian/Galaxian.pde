/*
*/
import java.util.*;
import sprites.utils.*;
import sprites.maths.*;
import sprites.*;

// The dimensions of the monster grid.
int monsterCols = 10;
int monsterRows = 5; 

static final String MISSILE_IMAGE = "cranberry.png";
static final float MISSILE_SCALE = 0.05f;
static final String MONSTER_IMAGE = "sprite.png";
static final float MONSTER_SCALE = 0.3f;
static final String SPRITE_CRANBERRY_IMAGE = "spriteCranberry.png";
static final float SPRITE_CRANBERRY_SCALE = 0.3f;
static final String LEBRON_JAMES_IMAGE = "lebron.png";
static final float LEBRON_JAMES_SCALE = 0.18f;
static final float GRAVITY = 600f;
static final float FLOATING_MONSTER_SPEED = 100f;

static final float SCALE = 1.4f;
static final int UNSCALED_WIDTH = 700;
static final int UNSCALED_HEIGHT = 500;

Sprite ship, fallingMonster, explosion, gameOverSprite;
ArrayList<Sprite> missiles;
ArrayList<Sprite> spriteCranberries;
Sprite monsters[] = new Sprite[monsterCols * monsterRows];
Sprite monsterBlock;

KeyboardController kbController;
SoundPlayer soundPlayer;
StopWatch stopWatch = new StopWatch();

void settings() 
{
  kbController = new KeyboardController(this);
  soundPlayer = new SoundPlayer(this);  

  // register the function (pre) that will be called
  // by Processing before the draw() function. 
  registerMethod("pre", this);

  size((int)(UNSCALED_WIDTH*SCALE), (int)(UNSCALED_HEIGHT*SCALE));
  S4P.messagesEnabled(true);
  buildSprites();
  resetMonsters();

  missiles = new ArrayList<Sprite>();
  spriteCranberries = new ArrayList<Sprite>();

  explosion = new Sprite(this, "explosion_strip16.png", 17, 1, 90);
  explosion.setScale(1);

  gameOverSprite = new Sprite(this, "gameOver.png", 100);
  gameOverSprite.setDead(true);

  soundPlayer.playSong();

  initSnowflakes();
}

void setup() {
  frame.setTitle("Wanna Sprite Cranberry?");
  frameRate(50);
}

boolean gameOver = false;
int score = 0;
int cranberriesTaken = 0;
int fallingMonsterPts = 20;
int gridMonsterPts = 10;


void buildSprites()
{
  // The Ship
  ship = buildShip();

  // The Grid Monsters 
  buildMonsterGrid();

  monsterBlock = new Sprite(this, MONSTER_IMAGE, 0);
  monsterBlock.setScale(MONSTER_SCALE);
  monsterBlock.setVisible(false);
}

Sprite buildShip()
{
  Sprite ship = new Sprite(this, LEBRON_JAMES_IMAGE, 50);
  ship.setXY(UNSCALED_WIDTH/2, UNSCALED_HEIGHT - 30);
  ship.setVelXY(0.0f, 0);
  ship.setScale(LEBRON_JAMES_SCALE);
  // Domain keeps the moving sprite withing specific screen area 
  ship.setDomain(0, UNSCALED_HEIGHT-ship.getHeight(), UNSCALED_WIDTH, UNSCALED_HEIGHT, Sprite.HALT);



  return ship;
}

// Populate the monsters grid 
void buildMonsterGrid() 
{
  for (int idx = 0; idx < monsters.length; idx++ ) {
    monsters[idx] = buildMonster();
  }
}

double totalWidth = 0;

// Arrange Monsters into a grid
void resetMonsters() 
{
  double mwidth = monsters[0].getWidth() + 20;
  double mheight = monsters[0].getHeight();
  totalWidth = mwidth * monsterCols;
  double start = (UNSCALED_WIDTH - totalWidth)/2; 
  for (int idx = 0; idx < monsters.length; idx++ ) {
    Sprite monster = monsters[idx];
    monster.setVelXY(FLOATING_MONSTER_SPEED, 0);
    int xpos = (int)((((idx % monsterCols)*mwidth)+start)) + 22;
    int ypos = (int)(((int)(idx / monsterCols)*mheight)+50);
    monster.setXY(xpos, ypos);


    monster.setDead(false);
  }
  monsterBlock.setVelXY(FLOATING_MONSTER_SPEED, 0);
  monsterBlock.setXY(start + 22, 0);
}

// Build individual monster
Sprite buildMonster() 
{
  Sprite monster = new Sprite(this, MONSTER_IMAGE, 30);
  monster.setScale(MONSTER_SCALE);
  monster.setDead(false);

  return monster;
}

Sprite buildMissile()
{
  // The Missile
  Sprite sprite  = new Sprite(this, MISSILE_IMAGE, 10);
  sprite.setScale(MISSILE_SCALE);
  sprite.setDead(true); // Initially hide the missile
  return sprite;
}

int missileSpeed = 500;
double upRadians = 4.71238898;

void fireMissile() 
{
  if (!ship.isDead()) {
    Sprite missile = buildMissile();
    Vector2D shipPos = ship.getPos();
    missile.setPos(new Vector2D(shipPos.x + ship.getWidth()*0.32f, shipPos.y - ship.getHeight()*.5f));
    missile.setSpeed(missileSpeed, upRadians);
    missile.setDead(false);
    missiles.add(missile);
  }
}

void stopMissile(int index) 
{
  missiles.get(index).setSpeed(0, upRadians);
  missiles.get(index).setDead(true);
  S4P.deregisterSprite(missiles.get(index));
  missiles.remove(index);
}

// Pick the first monster on the grid that is not dead.
// Return null if they are all dead.
Sprite pickNonDeadMonster() 
{
  for (int idx = 0; idx < monsters.length; idx++) {
    Sprite monster = monsters[idx];
    if (!monster.isDead()) {
      return monster;
    }
  }
  return null;
}

void replaceFallingMonster() 
{
  if (fallingMonster != null) {
    fallingMonster.setDead(true);
    fallingMonster = null;
  }

  // select new falling monster 
  fallingMonster = pickNonDeadMonster();
  if (fallingMonster == null) {
    return;
  }

  fallingMonster.setSpeed(fmSpeed, fmRightAngle);
  // Domain keeps the moving sprite within specific screen area 
  fallingMonster.setDomain(0, 0, UNSCALED_WIDTH, UNSCALED_HEIGHT+100, Sprite.REBOUND);
}

void explodeShip() 
{
  soundPlayer.playExplosion();
  explosion.setPos(ship.getPos());
  explosion.setFrameSequence(0, 16, 0.1, 1);
  ship.setDead(true);
}


boolean isOnScreen(Sprite sprite) {
  double lx = sprite.getX() - sprite.getWidth()/2;
  double rx = sprite.getX() + sprite.getWidth()/2;
  double uy = sprite.getY() - sprite.getHeight()/2;
  double ly = sprite.getY() + sprite.getHeight()/2;

  return lx <= UNSCALED_WIDTH && rx >= 0 && uy <= UNSCALED_HEIGHT && ly >= 0;
}

// Executed before draw() is called 
public void pre() 
{    
  checkKeys();
  processCollisions();
  moveMonsters();

  // If missile flies off screen
  for (int i=missiles.size()-1; i>=0; i--) {
    if (!isOnScreen(missiles.get(i))) {
      stopMissile(i);
    }
  }

  for (int i=spriteCranberries.size()-1; i>=0; i--) {
    if (!isOnScreen(spriteCranberries.get(i))) {
      S4P.deregisterSprite(spriteCranberries.get(i));
      spriteCranberries.remove(i);
    }
  }


  if (pickNonDeadMonster() == null) {
    resetMonsters();
  }

  // if falling monster is off screen
  if (fallingMonster == null || !isOnScreen(fallingMonster)) {
    replaceFallingMonster();
  }



  S4P.updateSprites(stopWatch.getElapsedTime());
} 

boolean spaceWasPressed = false;

void checkKeys() 
{
  if (focused) {
    if (kbController.isLeft()) {
      ship.setX(ship.getX()-10);
    }
    if (kbController.isRight()) {
      ship.setX(ship.getX()+10);
    }
    if (kbController.isSpace() && !spaceWasPressed) {
      spaceWasPressed = true;
      fireMissile();
    } else if (!kbController.isSpace()) {
      spaceWasPressed = false;
    }
  }
}

// Lower difficulty values introduce a more 
// random falling monster descent. 
int difficulty = 100;
double fmRightAngle = 0.3490; // 20 degrees
double fmLeftAngle = 2.79253; // 160 degrees
double fmSpeed = 150;


void moveMonsters() 
{  
  // Move Grid Monsters
  if (monsterBlock.getX() - monsterBlock.getWidth()/2 - 10 < 25) {
    for (int idx = 0; idx < monsters.length; idx++ ) {
      Sprite monster = monsters[idx];
      if (!monster.isDead()&& monster != fallingMonster) {
        monster.setVelX(FLOATING_MONSTER_SPEED);
        monsterBlock.setVelX(FLOATING_MONSTER_SPEED);
      }
    }
  } else if (monsterBlock.getX() - monsterBlock.getWidth()/2 + totalWidth - 10 > UNSCALED_WIDTH - 25) {
    for (int idx = 0; idx < monsters.length; idx++ ) {
      Sprite monster = monsters[idx];
      if (!monster.isDead()&& monster != fallingMonster) {
        monster.setVelX(-FLOATING_MONSTER_SPEED);
        monsterBlock.setVelX(-FLOATING_MONSTER_SPEED);
      }
    }
  }
  // Move Falling Monster
  if (fallingMonster != null) {
    if (int(random(difficulty)) == 1) {
      // Change FM Speed
      fallingMonster.setSpeed(fallingMonster.getSpeed() 
        + random(-40, 40));
      // Reverse FM direction.
      if (fallingMonster.getDirection() == fmRightAngle) 
        fallingMonster.setDirection(fmLeftAngle);
      else
        fallingMonster.setDirection(fmRightAngle);
    }
  }
}
// Detect collisions between sprites
void processCollisions() 
{
  // Detect collisions between Grid Monsters and Missile
  for (int idx = 0; idx < monsters.length; idx++) {
    Sprite monster = monsters[idx];
    for (int j = missiles.size()-1; j>=0; j--) {

      Sprite missile = missiles.get(j);
      if (!missile.isDead() && !monster.isDead() 
        && monster != fallingMonster 
        && missile.bb_collision(monster)) {
        score += gridMonsterPts;
        monsterHit(monster);
        stopMissile(j);
      }
    }
  }
  
  // Detect collisions between cranberrys and ship
  for (int idx = 0; idx < spriteCranberries.size(); idx++) {
    Sprite cranberry = spriteCranberries.get(idx);
    if (cranberry != null && !ship.isDead() 
    && cranberry.bb_collision(ship)) {
      cranberryHit(cranberry);
      cranberry = null;
      spriteCranberries.remove(idx);
      //explodeShip(); // Comment out if you don't want to die
      //gameOver = true;
    }
  }
  
  
  if (fallingMonster != null)
    for (int j = missiles.size()-1; j>=0; j--) {
      Sprite missile = missiles.get(j);
      // Between Falling Monster and Missile
      if (missile.cc_collision(fallingMonster)) {
        score += fallingMonsterPts;
        monsterHit(fallingMonster); 
        stopMissile(j);
        fallingMonster = null;
        break;
      }
    }

  // Between Falling Monster and Ship
  if (fallingMonster!= null && !ship.isDead() 
    && fallingMonster.bb_collision(ship)) {
    explodeShip();
    monsterHitShip(fallingMonster);
    fallingMonster = null;
    gameOver = true;
    soundPlayer.stopSong();
  }
}

Sprite buildCranberry(Sprite monster) // Changes sprite to Cranberry
{
  Sprite cranberry = new Sprite(this, SPRITE_CRANBERRY_IMAGE, 30);
  cranberry.setScale(SPRITE_CRANBERRY_SCALE);
  cranberry.setXY(monster.getX(), monster.getY());

  cranberry.setPos(monster.getPos());
  cranberry.setDomain(0, 0, UNSCALED_WIDTH, UNSCALED_HEIGHT+100, Sprite.REBOUND);
  cranberry.setVelXY(monster.getVelX(), monster.getVelY());
  cranberry.setAccXY(0, GRAVITY);
  cranberry.setDead(false);

  spriteCranberries.add(cranberry);

  return cranberry;
}

void cranberryHit(Sprite cranberry)
{
  soundPlayer.playCranberry();
  cranberry.setDead(true);
  cranberriesTaken += 1; // Adds to cranberryTaken counter
}

void monsterHit(Sprite monster) // Upon hit, change sprite to cranberry sprite
{
  soundPlayer.playPop();
  monster.setDead(true);
  buildCranberry(monster);
}

void monsterHitShip(Sprite monster) {
  monster.setDead(true);
}

void drawScore() {
  fill(255);
  textSize(32);
  String msg = " Score: " + score;
  text(msg, 10, 30);
}

void drawCranberries() {
  fill(255);
  textSize(32);
  String msg = " Cranberries: " + cranberriesTaken; // cranberriesTaken is a placeholder for whatever we decide to do with it
  text(msg, 10, 60);
}

void drawGameOver() 
{
  gameOverSprite.setXY(UNSCALED_WIDTH/2, UNSCALED_HEIGHT/2);
  gameOverSprite.setDead(false);
}


void setGradient(int x, int y, float w, float h, color c1, color c2) {

  noFill();

  for (int i = y; i <= y+h; i++) {
    float inter = map(i, y, y+h, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(x, i, x+w, i);
  }
}

static final int NUM_FLAKES = (int)(300*SCALE*SCALE);
static final int MAX_FLAKE_SIZE = 5; 
int[] snowXPos = new int[NUM_FLAKES];
int[] snowYPos = new int[NUM_FLAKES];
int[] snowDir = new int[NUM_FLAKES];
int[] snowSize = new int[NUM_FLAKES];


void initSnowflakes() {
  for (int i=0; i<NUM_FLAKES; i++) {
    snowXPos[i] = (int)random(width);
    snowYPos[i] = (int)random(height);
    snowDir[i] = (int)random(3) - 1;
    snowSize[i] = (int)random(MAX_FLAKE_SIZE) + 1;
  }
}

void drawBackground() {
  color c1 = color(24, 184, 199);
  color c2 = color(126, 242, 252);
  setGradient(0, 0, width, height, c1, c2);

  noStroke();
  fill(255, 255, 255, 200);
  for (int i=0; i<NUM_FLAKES; i++) {


    if (snowXPos[i] < 0 || snowXPos[i] > width || snowYPos[i] > height) {
      snowXPos[i] = (int)random(width);
      snowYPos[i] = 0;
      snowDir[i] = (int)random(3) - 1;
      snowSize[i] = (int)random(MAX_FLAKE_SIZE) + 1;
    }

    ellipse(snowXPos[i], snowYPos[i], snowSize[i], snowSize[i]);
    snowXPos[i] += snowDir[i];
    snowYPos[i] += 2;
  }
}

public void draw() 
{
  drawBackground();

  pushMatrix();
  scale(SCALE);
  drawScore();
  drawCranberries();

  S4P.drawSprites();

  if (gameOver)
    drawGameOver();
  popMatrix();
}
