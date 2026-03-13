<!DOCTYPE html>

<html>
<head>
<meta charset="UTF-8">
<title>Desafio do Labirinto</title>

<style>
body {
	margin: 0;
	font-family: Arial;
	background: #111;
	color: white;
	display: flex;
	flex-direction: column;
	align-items: center;
}

#topbar {
	width: 100%;
	text-align: center;
	background: #222;
	padding: 10px;
}

#mazeContainer {
	margin-top: 20px;
	width: 90vw;
	height: 80vh;
	overflow: auto;
	display: flex;
	justify-content: center;
}

#maze {
	position: relative;
}

.wall {
	position: absolute;
	background: #e63946;
}

.start {
	position: absolute;
	background: #2ecc71;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 11px;
}

.finish {
	position: absolute;
	background: #4361ee;
}

#lose, #win {
	display: none;
	position: fixed;
	inset: 0;
	background: black;
	justify-content: center;
	align-items: center;
	flex-direction: column;
	font-size: 30px;
}

button {
	padding: 10px 25px;
	font-size: 18px;
	margin-top: 20px;
	cursor: pointer;
}
</style>

</head>

<body>

	<div id="topbar">
		Tempo: <span id="timer">0.0</span>s
		<div id="ranking"></div>
	</div>

	<div id="mazeContainer">
		<div id="maze"></div>
	</div>

	<div id="lose">
		<h1>Você tocou na parede!</h1>
		<button onclick="restart()">Reiniciar</button>
	</div>

	<div id="win">
		<h1>Você venceu!</h1>
		<div id="finalTime"></div>
		<button onclick="restart()">Jogar novamente</button>
	</div>

	<script>

const cols = 50;
const rows = 35;
const size = 18;

const maze = document.getElementById("maze");
maze.style.width = cols*size+"px";
maze.style.height = rows*size+"px";

let grid=[];
let stack=[];
let gameStarted=false;
let startTime;
let timerInterval;

function get(x,y){
    return grid[y*cols+x];
}

function generate(){

    for(let y=0;y<rows;y++){
        for(let x=0;x<cols;x++){

            grid.push({
                x,y,
                visited:false,
                walls:[1,1,1,1]
            });

        }
    }

    let current=get(0,0);
    current.visited=true;

    stack.push(current);

    while(stack.length){

        current=stack.pop();

        let neighbors=[];

        if(current.x>0) neighbors.push(get(current.x-1,current.y));
        if(current.x<cols-1) neighbors.push(get(current.x+1,current.y));
        if(current.y>0) neighbors.push(get(current.x,current.y-1));
        if(current.y<rows-1) neighbors.push(get(current.x,current.y+1));

        neighbors=neighbors.filter(n=>!n.visited);

        if(neighbors.length){

            stack.push(current);

            let next=neighbors[Math.floor(Math.random()*neighbors.length)];
            next.visited=true;

            if(next.x>current.x){
                current.walls[1]=0;
                next.walls[3]=0;
            }

            if(next.x<current.x){
                current.walls[3]=0;
                next.walls[1]=0;
            }

            if(next.y>current.y){
                current.walls[2]=0;
                next.walls[0]=0;
            }

            if(next.y<current.y){
                current.walls[0]=0;
                next.walls[2]=0;
            }

            stack.push(next);

        }

    }

}

function createWall(x,y,w,h){

    const d=document.createElement("div");

    d.className="wall";
    d.style.left=x+"px";
    d.style.top=y+"px";
    d.style.width=w+"px";
    d.style.height=h+"px";

    d.addEventListener("mouseenter",loseGame);

    maze.appendChild(d);

}

function draw(){

    grid.forEach(c=>{

        if(c.walls[0]) createWall(c.x*size,c.y*size,size,2);
        if(c.walls[1]) createWall(c.x*size+size,c.y*size,2,size);
        if(c.walls[2]) createWall(c.x*size,c.y*size+size,size,2);
        if(c.walls[3]) createWall(c.x*size,c.y*size,2,size);

    });

}

function createStart(){

    const s=document.createElement("div");

    s.className="start";
    s.style.left="0px";
    s.style.top="0px";
    s.style.width=size+"px";
    s.style.height=size+"px";

    s.innerText="START";

    s.addEventListener("mouseenter",startGame);

    maze.appendChild(s);

}

function createFinish(){

    const f=document.createElement("div");

    f.className="finish";
    f.style.left=(cols-1)*size+"px";
    f.style.top=(rows-1)*size+"px";
    f.style.width=size+"px";
    f.style.height=size+"px";

    f.addEventListener("mouseenter",winGame);

    maze.appendChild(f);

}

function startGame(){

    if(gameStarted) return;

    gameStarted=true;
    startTime=Date.now();

    timerInterval=setInterval(()=>{

        let t=(Date.now()-startTime)/1000;
        document.getElementById("timer").innerText=t.toFixed(1);

    },100);

}

function loseGame(){

    if(!gameStarted) return;

    clearInterval(timerInterval);

    document.getElementById("lose").style.display="flex";

}

function winGame(){

    if(!gameStarted) return;

    clearInterval(timerInterval);

    let t=(Date.now()-startTime)/1000;

    document.getElementById("finalTime").innerText="Tempo: "+t.toFixed(2)+"s";

    saveScore(t);

    document.getElementById("win").style.display="flex";

}

function restart(){
    location.reload();
}

function saveScore(t){

    let scores=JSON.parse(localStorage.getItem("mazeScores")||"[]");

    scores.push(t);

    scores.sort((a,b)=>a-b);

    scores=scores.slice(0,5);

    localStorage.setItem("mazeScores",JSON.stringify(scores));

    showRanking();

}

function showRanking(){

    let scores=JSON.parse(localStorage.getItem("mazeScores")||"[]");

    let html="Ranking:<br>";

    scores.forEach((s,i)=>{
        html+=(i+1)+". "+s.toFixed(2)+"s<br>";
    });

    document.getElementById("ranking").innerHTML=html;

}

generate();
draw();
createStart();
createFinish();
showRanking();

</script>

</body>
</html>
