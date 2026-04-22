const { TikTokLiveConnection, WebcastEvent, User } = require('tiktok-live-connector');
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const WebSocket = require('ws'); // 👈 Nueva librería para Godot
const { PassThrough } = require('stream');
const { stringify } = require('querystring');
const { exit } = require('process');

const app = express();
const server = http.createServer(app);
const io = new Server(server);

// --- CONFIGURACIÓN DE WEBSOCKET PARA GODOT ---
const wss = new WebSocket.Server({ port: 3001 }); // Puerto 3001 para Godot

wss.on('connection', (ws) => {
    console.log('🤖 ¡Godot se ha conectado exitosamente!');
});

// Función para enviar datos a Godot de forma limpia
function enviarAGodot(evento, usuario, puntos, regalo = null, fotoUrl = "") {
    // Si fotoUrl es un array (lo que está pasando), elegimos la primera opción
    const fotoLimpia = Array.isArray(fotoUrl) ? fotoUrl[0] : fotoUrl;

    const payload = JSON.stringify({
        evento: evento,
        usuario: usuario, // 👈 Asegúrate de que esta variable NO sea undefined
        puntos: puntos,
        regalo: regalo,
        fotoUrl: fotoLimpia // 👈 Enviamos solo el primer link
    });

    // console.log(payload)

    wss.clients.forEach(client => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(payload);
        }
    });
}

app.use(express.static('public'));

let usuariosTiktok = [
    "andree_iv",
    "soyboa_",
    'nisoje.tk',
    'm4uricho',
    'soyelmoiss',
    "daniaplaygame",
    'yudithquispesul10',
    'ellisproo',
    // "ernestogz_11",
    "alejandrodavid177",
    "nocdtino",
    "josegnzl777",
    "alex.t_gamer",
    "arenitauwu", "luz_moom", "eway.dem", "felixstudiolive", "danny_kol", "dolldarki", "zlatartv", "stevenrata7", "langela89", "nelva.invest2","", "maw.en.sistemas", "alexiya369", "zacil.jimenez", "santusoy"]
let intentos = 0



function intentosDeConexion() {
    if (intentos > usuariosTiktok.length - 1) { exit() }
    console.log(' ')
    console.log(`👾 Iniciando conexion con ${usuariosTiktok[intentos]}`)
    let tiktokConnection = new TikTokLiveConnection(usuariosTiktok[intentos]);


    tiktokConnection.connect().then(state => {
        console.log(`✅ Conectado a TikTok: ${state.roomId}`);
    }).catch(err => {
        // console.error('❌ Error:', err.message);
        console.error('❌ El usuario no se encuentra en LIVE');
        intentos++;
        intentosDeConexion()
    });
    
    // ! 1. LÓGICA DE LIKES
    tiktokConnection.on(WebcastEvent.LIKE, data => {
        const foto = data.user?.profilePicture?.url || "";
        
     
        enviarAGodot('like-recibido', data.user.uniqueId, data.likeCount, 'LikeBoost', foto);
        console.log(`[LIKE] ${data.user.uniqueId} boost --> ${data.likeCount}`);
    });
    
    // ! 2. INGRESAR
    tiktokConnection.on(WebcastEvent.MEMBER, data => {
        const foto = data.user?.profilePicture?.url || "";
        
        enviarAGodot('usuario-ingresa', data.user.uniqueId, 250, 'Join', foto);
        console.log(`[JOIN] ${data.user.uniqueId} entró`);
    });
    
    // ! 3. REGALOS
    tiktokConnection.on(WebcastEvent.GIFT, data => {
        const foto = data.user?.profilePicture?.url || "";
        
        enviarAGodot('boost-recibido', data.user.uniqueId, data.giftDetails.diamondCount, data.giftDetails.giftName, foto);
        console.log(`[GIFT] ${data.user.uniqueId} envió --> ${data.giftDetails.giftName}`);
    });
    
    // ! 4. FOLLOW
    tiktokConnection.on(WebcastEvent.FOLLOW, data => {
        const foto = data.user?.profilePicture?.url || "";
    
        enviarAGodot('follow-recibido', data.user.uniqueId, 50, 'Follow',foto);
        console.log(`[FOLLOW] ${data.user.uniqueId} follow`);
    
    });

    // ! 5. SHARE
    tiktokConnection.on(WebcastEvent.SHARE, data => {
        const foto = data.user?.profilePicture?.url || "";
        enviarAGodot('share-recibido', data.user.uniqueId, 50, 'Follow',foto);
        console.log(`[SHARE] ${data.user.uniqueId} Compartió el LIVE`);
    })

    
}




intentosDeConexion();

server.listen(3000, () => {
    console.log('🌐 Web en puerto 3000 | 🤖 Godot en puerto 3001');
});