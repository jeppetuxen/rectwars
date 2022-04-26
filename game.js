let app = new PIXI.Application({ width: 800, height: 600 });
document.body.appendChild(app.view);

gravitational_pull = (0, 0.001)
resistance = 0.95

const constrain = (num, min, max) => Math.min(Math.max(num, min), max)

const isKeyDown = (() => {
    const state = {};
    window.addEventListener('keyup', (e) => state[e.key] = false);
    window.addEventListener('keydown', (e) => state[e.key] = true);

    return (key) => state.hasOwnProperty(key) && state[key] || false;
})();

window.addEventListener('keydown', e => console.log(e.key))

const SPACE_KEY = ' '

let bullets = [];

const spawnShip = (x, y) => {
    let obj = new PIXI.Graphics();
    const ROTATION_SPEED = Math.PI/40
    obj.beginFill(0xffffff);
    obj.drawRect(0, 0, 10, 10);
    obj.x = x; obj.y=y;
    obj.dx = 0;
    obj.dy = 0;
    obj.thrustOn = false
    obj.thrustVel = 0.03;
    obj.maxSpeed = 1;
    obj.angle = 0
    obj.pivot.x = 5
    obj.pivot.y = 5
    
    obj.shoot = () => {
        let bullet = new PIXI.Graphics();
        bullet.beginFill(0xffffff);
        bullet.drawRect(0, 0, 2, 2);
        bullet.direction = obj.rotation
        bullet.pivot.x = 1
        bullet.pivot.y = 1
        bullet.speed = 1
        bullet.dx = Math.sin(bullet.direction)*bullet.speed
        bullet.dy = -Math.cos(bullet.direction)*bullet.speed
        bullet.x = obj.x
        bullet.y = obj.y
        bullet.update = (dt) => {
            bullet.x += bullet.dx*dt
            bullet.y += bullet.dy*dt
        }
        
        bullets.push(bullet)
        app.stage.addChild(bullet)

        window.setTimeout(() => {
            console.log("asdasd")
            app.stage.removeChild(bullet)
            /*             bullets.pop(bullet) */
        }, 1000

        )

    }

    obj.update = (dt) => {
        if (isKeyDown('ArrowLeft')){
            obj.rotation -= ROTATION_SPEED*dt
        }
        if (isKeyDown('ArrowRight')){
            obj.rotation += ROTATION_SPEED*dt
        }

        if (isKeyDown(SPACE_KEY)){
            obj.thrustOn = true
            obj.dy += -Math.cos(obj.rotation)*obj.thrustVel*dt
            obj.dx += Math.sin(obj.rotation)*obj.thrustVel*dt
        }
        else {
            obj.thrustOn = false
        }




        obj.dy += gravitational_pull
        
        obj.x += obj.dx
        obj.y += obj.dy
    }

    window.addEventListener('keydown', e => {
        
        if (e.key==='ArrowUp'){
            obj.shoot()
            console.log("Shooting")
        }
    })
    
    app.stage.addChild(obj)
    return obj
}

let ships = []


ships.push(spawnShip(10, 20))

// Magically load the PNG asynchronously
let sprite = PIXI.Sprite.from('sample.png');
app.stage.addChild(sprite);

// Add a variable to count up the seconds our demo has been running
let elapsed = 0.0;
// Tell our application's ticker to run a new callback every frame, passing
// in the amount of time that has passed since the last tick
app.ticker.add((delta) => {
    // Add the time to our total elapsed time
    elapsed += delta;
    // Update the sprite's X position based on the cosine of our elapsed time.  We divide
    // by 50 to slow the animation down a bit...
    for (let ship of ships){
        ship.update(delta)
    }
    for (let bullet of bullets){
        bullet.update(delta)
    }
});
