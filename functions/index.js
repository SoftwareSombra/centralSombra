const functions = require('firebase-functions').region('southamerica-east1');
const cors = require('cors')({ origin: true });
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();
const storage = admin.storage();
const { getStorage, getDownloadURL } = require('firebase-admin/storage');
const axios = require('axios');
const https = require('https');
const mpPolyline = require('@mapbox/polyline');
const { format, parse, subHours } = require('date-fns');
const { ptBR } = require('date-fns/locale');

// const coreStringReplace = require('core-js/modules/es.string.replace');
//const novaString = coreStringReplace.replace(stringAntiga, regex, novaSubstituicao);
// const googleMaps = require('@google/maps').createClient({
//     key: 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU',
// });
// const maps = require('@googlemaps/google-maps-services-js').createClient({
//     key: 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU',
// });



// const CustomClaimsRepository = require('./autenticacao/administrador/custom_claims_repository');
// const CustomClaimsServices = require('./autenticacao/administrador/custom_claims_services');
// const CustomClaimsController = require('./autenticacao/administrador/custom_claims_controller');
// const CadastroRepository = require('./autenticacao/cadastro/cadastro_repository');
// const CadastroService = require('./autenticacao/cadastro/cadastro_services');
// const CadastroController = require('./autenticacao/cadastro/cadastro_controller');
// // const UserRepository = require('./user/user_repository');
// // const UserService = require('./user/user_services');
// // const UserController = require('./user/user_controller');



// const cadastroRepository = new CadastroRepository(admin.auth(), admin.firestore(), admin.storage());
// const cadastroService = new CadastroService(cadastroRepository);
// const cadastroControllerInstance = new CadastroController(cadastroService);

// //const userRepository = new UserRepository(admin.auth(), admin.firestore(), admin.storage());
// //const userService = new UserService(userRepository);
// //const userControllerInstance = new UserController(userService);

// const customClaimsRepository = new CustomClaimsRepository(admin.auth(), admin.firestore(), admin.storage());
// const customClaimsService = new CustomClaimsServices(customClaimsRepository);
// const customClaimsControllerInstance = new CustomClaimsController(customClaimsService);

// const exportedFunctions = {
//   setDevClaim: customClaimsControllerInstance.setDev,
//   setAdmin: customClaimsControllerInstance.setAdmin,
//   setGestor: customClaimsControllerInstance.setGestor,
//   setOperador: customClaimsControllerInstance.setOperador,
//   setAdminCliente: customClaimsControllerInstance.setAdminCliente,
//   setOperadorCliente: customClaimsControllerInstance.setOperadorCliente,
//   hasAllClaims: customClaimsControllerInstance.hasAllClaims,
//   hasDev: customClaimsControllerInstance.hasDev,
//   hasAdmin: customClaimsControllerInstance.hasAdmin,
//   hasGestor: customClaimsControllerInstance.hasGestor,
//   hasOperador: customClaimsControllerInstance.hasOperador,
//   hasAdminCliente: customClaimsControllerInstance.hasAdminCliente,
//   hasOperadorCliente: customClaimsControllerInstance.hasOperadorCliente,
//   deleteAllUsers: customClaimsControllerInstance.deleteAllUsers,
//   deleteAllUsers2: customClaimsControllerInstance.deleteAllUsers2,
//   cadastro: cadastroControllerInstance.registerUser,
//   // getUserName: userControllerInstance.getName,
//   // getUserPhoto: userControllerInstance.getPhoto,
//   // addUserInfos: userControllerInstance.addUserInfos,
// };

// module.exports = exportedFunctions;


// exports.getDirections = functions.https.onRequest((request, response) => {
//     cors(request, response, async () => {
//         if (request.method !== 'GET') {
//             return response.status(500).json({ error: "Método não permitido" });
//         }

//         const googleMapsUrl = `https://maps.googleapis.com/maps/api/directions/json?${request.url.split('?')[1]}`;

//         try {
//             const apiResponse = await fetch(googleMapsUrl);
//             const data = await apiResponse.json();
//             response.json(data);
//         } catch (err) {
//             response.status(500).send(err);
//         }
//     });
// });

// //getRoute usando a api google routes
// exports.getRoute = functions.https.onRequest((request, response) => {
//     cors(request, response, async () => {
//         if (request.method !== 'GET') {
//             return response.status(500).json({ error: "Método não permitido" });
//         }

//         const googleMapsUrl = `https://maps.googleapis.com/maps/api/directions/json?${request.url.split('?')[1]}`;

//         try {
//             const apiResponse = await fetch(googleMapsUrl);
//             const data = await apiResponse.json();
//             response.json(data);
//         } catch (err) {
//             response.status(500).send(err);
//         }
//     });
// });


// exports.getDistanceBetweenWaypoints = functions.https.onRequest((request, response) => {
//     cors(request, response, async () => {
//         //console.log(request);
//         console.log(request.body);
//         console.log(request.query);

//         console.log('chegou aqui')
//         const googleMapsUrl = `https://maps.googleapis.com/maps/api/directions/json?origin=${request.query.origin}&destination=${request.query.destination}&waypoints=${request.query.waypoints}&key=AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU`;

//         try {
//             const apiResponse = await fetch(googleMapsUrl);
//             const data = await apiResponse.json();
//             console.log(data);
//             response.json(data);
//         } catch (err) {
//             response.status(500).send(err);
//         }
//     });
// }
// );

// exports.getDistanceBetweenWaypoints2 = functions.https.onRequest((request, response) => {
//     cors(request, response, async () => {
//         console.log(request.body);
//         console.log(request.query);

//         const waypoints = request.body.waypoints;
//         const apiKey = 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU';
//         const url = `https://routes.googleapis.com/directions/v2:computeRoutes`;

//         try {
//             // Assume que waypoints é um array de objetos {latitude, longitude}
//             const intermediates = waypoints.slice(1, -1).map(point => ({
//                 latLng: { latitude: point.latitude, longitude: point.longitude }
//             }));

//             const origin = waypoints[0];
//             const destination = waypoints[waypoints.length - 1];

//             const body = {
//                 origin: {
//                     location: {
//                         latitude: waypoints[0].latitude,
//                         longitude: waypoints[0].longitude
//                     }
//                 },
//                 destination: {
//                     location: {
//                         latitude: waypoints[waypoints.length - 1].latitude,
//                         longitude: waypoints[waypoints.length - 1].longitude
//                     }
//                 },
//                 intermediates: waypoints.slice(1, -1).map(waypoint => ({
//                     location: {
//                         latitude: waypoint.latitude,
//                         longitude: waypoint.longitude
//                     }
//                 })),
//                 travelMode: "DRIVE" // Certifique-se de usar o valor correto esperado pela API aqui
//             };

//             const requestOptions = {
//                 method: 'POST',
//                 headers: {
//                     'Content-Type': 'application/json',
//                     'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters',
//                     "X-Goog-Api-Key": apiKey
//                 },
//                 body: JSON.stringify(body)
//             };

//             const fetchResponse = await fetch(url, requestOptions);
//             console.log(fetchResponse);
//             // const textResponse = await fetchResponse.text();
//             // console.log(textResponse);
//             const data = await fetchResponse.json();
//             console.log(data);

//             // Calcular a distância total percorrida ao longo da rota
//             let totalDistanceMeters = 0;
//             data.routes[0].legs.forEach(leg => {
//                 totalDistanceMeters += leg.distanceMeters;
//             });

//             // Responder com a distância total em quilômetros
//             response.json({ totalDistanceKm: totalDistanceMeters / 1000 });
//         } catch (error) {
//             console.error(error);
//             response.status(500).send(`Erro ao calcular distância, ${error}`);
//         }
//     });
// });

// exports.getDistanceBetweenWaypoints3 = functions.https.onRequest((req, res) => {
//     cors(req, res, async () => {
//         const waypoints = req.body.waypoints;
//         console.log(waypoints);

//         if (!waypoints || waypoints.length < 2) {
//             res.status(500).send('É necessário fornecer pelo menos 2 waypoints.');
//         }

//         // Definição da URL da API
//         const apiKey = 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU';
//         const url = `https://routes.googleapis.com/directions/v2:computeRoutes`;


//         let totalDistanceMeters = 0;
//         let accumulatedPolyline = ''; // Variável para acumular as polilinhas

//         const createRequestBlock = async (origin, destination, intermediates) => {
//             const body = JSON.stringify({
//                 origin: { location: { latLng: origin } },
//                 destination: { location: { latLng: destination } },
//                 intermediates: intermediates.map(wp => ({ location: { latLng: wp } })),
//                 travelMode: "DRIVE",
//                 computeAlternativeRoutes: false,
//             });

//             const response = await fetch(url, {
//                 method: 'POST',
//                 headers: {
//                     'Content-Type': 'application/json',
//                     'X-Goog-Api-Key': apiKey,
//                     'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
//                 },
//                 body
//             });

//             if (!response.ok) {
//                 throw new Error(`HTTP Error: ${response.status}`);
//             }

//             const data = await response.json();
//             return {
//                 distanceMeters: data.routes[0].distanceMeters,
//                 polyline: data.routes[0].polyline.encodedPolyline // Ajuste aqui para incluir a polilinha
//             };
//         };

//         for (let i = 0; i < waypoints.length - 1; i += 24) {
//             const origin = waypoints[i];
//             const nextIndex = Math.min(i + 25, waypoints.length - 1);
//             const destination = waypoints[nextIndex];
//             const intermediates = waypoints.slice(i + 1, nextIndex);

//             const result = await createRequestBlock(origin, destination, intermediates);
//             console.log(`distancia do bloco: ${result.distanceMeters}`);
//             totalDistanceMeters += result.distanceMeters;
//             accumulatedPolyline += result.polyline; // Acumulando polilinhas
//         }

//         const totalDistanceKilometers = totalDistanceMeters / 1000;
//         res.status(200).send({
//             totalDistanceKm: totalDistanceKilometers.toFixed(2),
//             polyline: accumulatedPolyline // Inclui a polilinha na resposta
//         });
//     });
// });

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// exports.getDistanceAndPolylineBetweenWaypoints = functions.runWith({
//     timeoutSeconds: 300,  // Define o tempo limite para 300 segundos (5 minutos)
//     memory: '1GB'         // Define a alocação de memória para 1GB
// }).https.onRequest((req, res) => {
//     cors(req, res, async () => {
//         //const now = new Date();
//         ///console.log(now);
//         console.log('!!!!!!!!!!');
//         const waypoints = req.body.waypoints;
//         console.log(waypoints);

//         if (!waypoints || waypoints.length < 2) {
//             res.status(500).send('É necessário fornecer pelo menos 2 waypoints.');
//         }

//         // Definição da URL da API
//         const apiKey = 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU';
//         const url = `https://routes.googleapis.com/directions/v2:computeRoutes`;


//         let totalDistanceMeters = 0;

//         const createRequestBlock = async (origin, destination, intermediates) => {
//             const body = JSON.stringify({
//                 origin: { location: { latLng: origin } },
//                 destination: { location: { latLng: destination } },
//                 intermediates: intermediates.map(wp => ({ location: { latLng: wp } })),
//                 travelMode: "DRIVE",
//                 computeAlternativeRoutes: false,
//                 optimizeWaypointOrder: true,
//                 polyline_quality: 'HIGH_QUALITY',
//             });

//             try {

//                 const response = await fetch(url, {
//                     method: 'POST',
//                     headers: {
//                         'Content-Type': 'application/json',
//                         'X-Goog-Api-Key': apiKey,
//                         'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline,routes.optimizedIntermediateWaypointIndex',
//                     },
//                     body
//                 });


//                 if (!response.ok) {
//                     res.status(500).send(`HTTP Error: -----> ${response.status, response.statusText}`);
//                 }

//                 const data = await response.json();
//                 console.log(data);
//                 return {
//                     distanceMeters: data.routes[0].distanceMeters,
//                     polyline: data.routes[0].polyline.encodedPolyline
//                 };
//             } catch (e) {
//                 console.log(e)
//             }
//         };

//         let finalPoints = [];

//         let previousDestination = null;

//         for (let i = 0; i < waypoints.length; i += 25) {
//             let origin;
//             if (i === 0) {
//                 origin = waypoints[i]; // Primeiro bloco, sem bloco anterior
//             } else {
//                 origin = previousDestination; // Inicia com o destino do bloco anterior
//             }

//             const nextIndex = Math.min(i + 25, waypoints.length - 1);
//             const destination = waypoints[nextIndex];
//             previousDestination = destination; // Atualiza para o próximo ciclo

//             const intermediates = (i === 0) ? waypoints.slice(i + 1, nextIndex) : waypoints.slice(i, nextIndex);

//             const result = await createRequestBlock(origin, destination, intermediates);
//             if (result.distanceMeters > 0) {
//                 console.log(`distancia do bloco: ${result.distanceMeters}`);

//                 totalDistanceMeters += result.distanceMeters;

//                 // Decodifique a polilinha do bloco atual para pontos
//                 const points = mpPolyline.decode(result.polyline);

//                 // Se não for o primeiro bloco, remova o primeiro ponto para evitar sobreposição
//                 if (i > 0) {
//                     console.log('removendo pontos');
//                     points.shift();
//                     // points.pop(); 
//                     // points.shift();
//                     // points.pop();
//                 }

//                 // Adicione os pontos decodificados ao array final
//                 finalPoints = finalPoints.concat(points);
//             }
//         }

//         // Recodifique os pontos finais em uma polilinha
//         const finalPolyline = mpPolyline.encode(finalPoints);

//         const totalDistanceKilometers = totalDistanceMeters / 1000;
//         console.log(totalDistanceMeters);
//         res.status(200).send({
//             totalDistanceKm: totalDistanceKilometers.toFixed(2),
//             polyline: finalPolyline
//         });
//     });
// });

// exports.googleSnapToRoads = functions.https.onRequest((req, res) => {
//     cors(req, res, async () => {

//         //req.body é uma lista de locations, cada location é um objeto com latitude e longitude
//         const locations = req.body.path;
//         console.log(locations);
//         const path = locations.map(location => `${location.latitude},${location.longitude}`).join('|');
//         const apiKey = 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU';
//         const url = `https://roads.googleapis.com/v1/snapToRoads?path=${path}&key=${apiKey}`;

//         try {
//             const response = await fetch(url);
//             const data = await response.json();
//             res.status(200).send(data);
//         } catch (error) {
//             console.error(error);
//             res.status(500).send('Erro ao obter dados da API');
//         }
//     });
// });

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// exports.obterPontos = functions.https.onRequest((req, res) => {
//     cors(req, res, async () => {
//         const locations = req.body.path;
//         console.log(locations);

//         if (locations.length === 0) {
//             return res.status(400).send('A lista de localizações está vazia.');
//         }

//         const apiKey = 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU';
//         const baseUrl = 'https://roads.googleapis.com/v1/snapToRoads';

//         // Função auxiliar para dividir as locations em blocos de 100, com sobreposição
//         const splitInBlocks = (locations, blockSize) => {
//             let blocks = [];
//             for (let i = 0; i < locations.length; i += blockSize) {
//                 // Adiciona sobreposição
//                 let end = i + blockSize;
//                 if (i > 0) end += 1;
//                 blocks.push(locations.slice(i, end));
//             }
//             return blocks;
//         };

//         const locationBlocks = splitInBlocks(locations, 99); // Ajuste para 99 para considerar sobreposição
//         let allSnappedPoints = [];

//         try {
//             for (const [index, block] of locationBlocks.entries()) {
//                 const path = block.map(location => `${location.latitude},${location.longitude}`).join('|');
//                 const response = await fetch(`${baseUrl}?path=${encodeURIComponent(path)}&interpolate=true&key=${apiKey}`);
//                 if (!response.ok) {
//                     throw new Error(`HTTP Error: ${response.status}`);
//                 }
//                 const data = await response.json();
//                 // Evita adicionar o primeiro ponto do bloco, exceto no primeiro bloco
//                 if (index > 0) {
//                     data.snappedPoints.shift(); // Remove o primeiro ponto duplicado
//                 }
//                 allSnappedPoints.push(...data.snappedPoints);
//             }

//             res.status(200).send({ snappedPoints: allSnappedPoints });
//         } catch (error) {
//             console.error(error);
//             res.status(500).send('Erro ao obter dados da API');
//         }
//     });
// });

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

exports.getDistance = functions.https.onRequest((request, response) => {
    cors(request, response, async () => {
        if (request.method !== 'POST') {
            return response.status(500).json({ error: "Método não permitido" });
        }
        const { origins, destinations } = request.body;

        const googleMapsUrl = `https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=${encodeURIComponent(origins)}&destinations=${encodeURIComponent(destinations)}&key=AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU`;

        try {
            const apiResponse = await fetch(googleMapsUrl);
            const data = await apiResponse.json();
            console.log(data);
            response.json(data);
        } catch (err) {
            console.log(err);
            response.status(500).send(err);
        }

    }
    );
});


exports.getDistancesBetweenCoordinates = functions.runWith({
    timeoutSeconds: 300,  // Define o tempo limite para 300 segundos (5 minutos)
    memory: '1GB'         // Define a alocação de memória para 1GB
}).https.onRequest((req, res) => {
    cors(req, res, async () => {
        const coordinates = req.body.coordinates;

        if (!coordinates || coordinates.length < 2) {
            return res.status(400).send('É necessário fornecer pelo menos dois pares de coordenadas.');
        }

        const apiKey = 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU';
        const url = 'https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix';

        let results = [];

        // Processa cada par de coordenadas consecutivas como um único par origin-destination
        for (let i = 0; i < coordinates.length - 1; i++) {
            const origins = [{
                "waypoint": {
                    "location": {
                        "latLng": {
                            "latitude": coordinates[i].latitude,
                            "longitude": coordinates[i].longitude
                        }
                    }
                }
            }];

            const destinations = [{
                "waypoint": {
                    "location": {
                        "latLng": {
                            "latitude": coordinates[i + 1].latitude,
                            "longitude": coordinates[i + 1].longitude
                        }
                    }
                }
            }];

            try {
                const response = await fetch(url, {
                    method: 'POST',
                    body: JSON.stringify({
                        origins,
                        destinations,
                        travelMode: 'DRIVE',
                        routingPreference: 'TRAFFIC_AWARE'
                    }),
                    headers: {
                        'Content-Type': 'application/json',
                        'X-Goog-Api-Key': apiKey,
                        'X-Goog-FieldMask': 'originIndex,destinationIndex,duration,distanceMeters'
                    }
                });

                if (!response.ok) {
                    console.error(`Erro ao chamar a API: ${response.status}, ${response.statusText}`);
                    continue; // Skip to next iteration on error
                }

                const data = await response.json();
                console.log(data);
                //console.log(data[0]);

                if (data) {
                    //const element = data.rows[0].elements[0];
                    results.push({
                        from: coordinates[i],
                        to: coordinates[i + 1],
                        distanceMeters: data[0].distanceMeters,
                        duration: data[0].duration
                    });
                } else {
                    console.log('No valid elements found in the response:', data);
                }
            } catch (error) {
                console.error('Error fetching distance matrix:', error);
                return res.status(500).send('Erro ao obter dados da API');
            }
        }

        res.status(200).send(results);
    });
});





// // exports.getMissaoIniciada = functions.https.onRequest((request, response) => {
// //     cors(request, response, async () => {
// //         if (request.method !== 'GET') {
// //             return response.status(500).json({ error: "Método não permitido" });
// //         }
// //         try {
// //             doc = await db.collection('Missão iniciada').doc(request.body.uid).get();
// //             //retorna true caso o documento exista
// //             return response.json(doc.exists);
// //         } catch (err) {
// //             return response.status(500).send(err);
// //         }
// //     });
// // });


// exports.preAddDocumentosDoAgente = functions.https.onRequest(async (request, response) => {
//     const { uid, nome, logradouro, numero, complemento, bairro, cidade, estado, cep, celular, rg, cpf, rgFotoFrente, rgFotoVerso, compResidFoto, rgFotoFrenteBase64, rgFotoVersoBase64, compResidFotoBase64 } = request.body;

//     let rgFotoFrenteDownloadURL = null;
//     let rgFotoVersoDownloadURL = null;
//     let compResidFotoDownloadURL = null;

//     try {

//         if (!rgFotoFrente) {
//             const bufferRgFotoFrente = Buffer.from(rgFotoVersoBase64, 'base64');
//             const now = new Date();
//             const token = `${uid}${now}`
//             const rgFotoFrenteFile = storage.bucket().file(`DocumentosDoAgente/${uid}/rgFotoFrente/${now}.jpg`);

//             await rgFotoFrenteFile.save(bufferRgFotoFrente, {
//                 contentType: 'image/jpg',
//                 metadata: {
//                     firebaseStorageDownloadTokens: token
//                 }
//             });

//             const rgFotoFrenteFileRef = getStorage().bucket().file(`DocumentosDoAgente/${uid}/rgFotoFrente/${now}.jpg`);
//             rgFotoFrenteDownloadURL = await getDownloadURL(rgFotoFrenteFileRef);
//         } else {
//             rgFotoFrenteDownloadURL = rgFotoFrente;
//         }

//         if (!rgFotoVerso) {
//             const bufferRgFotoVerso = Buffer.from(rgFotoVersoBase64, 'base64');
//             const now = new Date();
//             const token = `${uid}${now}`
//             const rgFotoVersoFile = storage.bucket().file(`DocumentosDoAgente/${uid}/rgFotoVerso/${now}.jpg`);

//             await rgFotoVersoFile.save(bufferRgFotoVerso, {
//                 contentType: 'image/jpg',
//                 metadata: {
//                     firebaseStorageDownloadTokens: token
//                 }
//             });

//             const rgFotoVersoFileRef = getStorage().bucket().file(`DocumentosDoAgente/${uid}/rgFotoVerso/${now}.jpg`);
//             rgFotoVersoDownloadURL = await getDownloadURL(rgFotoVersoFileRef);
//         } else {
//             rgFotoVersoDownloadURL = rgFotoVerso;
//         }

//         if (!compResidFoto) {
//             const bufferCompResidFoto = Buffer.from(compResidFotoBase64, 'base64');
//             const now = new Date();
//             const token = `${uid}${now}`
//             const compResidFotoFile = storage.bucket().file(`DocumentosDoAgente/${uid}/compResidFoto/${now}.jpg`);

//             await compResidFotoFile.save(bufferCompResidFoto, {
//                 contentType: 'image/jpg',
//                 metadata: {
//                     firebaseStorageDownloadTokens: token
//                 }
//             });

//             const compResidFotoFileRef = getStorage().bucket().file(`DocumentosDoAgente/${uid}/compResidFoto/${now}.jpg`);
//             compResidFotoDownloadURL = await getDownloadURL(compResidFotoFileRef);
//         } else {
//             compResidFotoDownloadURL = compResidFoto;
//         }

//         await db.collection('Aprovação de user infos').doc(uid).set({
//             uid: uid,
//             'Nome': nome,
//             logradouro: logradouro,
//             numero: numero,
//             complemento: complemento,
//             bairro: bairro,
//             cidade: cidade,
//             estado: estado,
//             Cep: cep,
//             Celular: celular,
//             RG: rg,
//             CPF: cpf,
//             'RG frente': rgFotoFrenteDownloadURL,
//             'RG verso': rgFotoVersoDownloadURL,
//             'Comprovante de residência': compResidFotoDownloadURL,
//             Timestamp: new Date(),
//         });
//         response.status(200).send(`Documentos adicionados com sucesso`);
//     } catch (e) {
//         console.log(e);
//         response.status(500).send(`Erro ao adicionar documentos: ${e}`);
//     };
// });


exports.addFotoRelatorio3 = functions.https.onRequest(async (request, response) => {
    try {
        //log('request.body.missaoId', request.body.missaoId);
        const buffer = Buffer.from(request.body.image, 'base64');
        const now = new Date();
        const token = `${request.body.missaoId}${now}`

        const file = storage.bucket().file(`FotosDeMissao/${request.body.missaoId}/${now}.jpg`);

        await file.save(buffer, {
            contentType: 'image/jpg',
            metadata: {
                firebaseStorageDownloadTokens: token
            }
        });

        //log imprimindo fileSabe
        //console.log(fileSave);

        const fileRef = getStorage().bucket().file(`FotosDeMissao/${request.body.missaoId}/${now}.jpg`);
        const downloadURL = await getDownloadURL(fileRef);

        console.log(` =================${downloadURL}`);

        //const bucketName = storage.bucket().name;
        //const downloadURL = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(`FotosDeMissao/${request.body.missaoId}/${now}.jpg`)}?alt=media&token=${token}`;
        let fotoComLegenda = [
            {
                url: downloadURL,
                caption: request.body.caption,
                timestamp: new Date(),
            }
        ];

        const fotosRelatorioRef = db.collection('Fotos relatório').doc(request.body.uid);
        await fotosRelatorioRef.set({ sinc: 'sinc' }, { merge: true });

        const fotosRelatorioOdometroRef = db.collection('Fotos relatório')
            .doc(request.body.uid)
            .collection('Missões')
            .doc(request.body.missaoId);

        await fotosRelatorioOdometroRef.set({ sinc: 'sinc' }, { merge: true });

        const missaoRef = request.body.odometroInicial == true
            ? fotosRelatorioRef.collection('Missões').doc(request.body.missaoId).collection('Odometro').doc('odometroInicial')
            : request.body.odometroFinal == true ? fotosRelatorioRef.collection('Missões').doc(request.body.missaoId).collection('Odometro').doc('odometroFinal')
                : fotosRelatorioRef.collection('Missões').doc(request.body.missaoId);


        await missaoRef.set({
            fotos: admin.firestore.FieldValue.arrayUnion(...fotoComLegenda),
            notificacaoCentral: true
        }, { merge: true });

        response.status(200).send(`Documento adicionado com sucesso`);
    } catch (error) {
        // let errorCode = 'unknown-error';
        // let errorMessage = 'Um erro desconhecido ocorreu.';

        switch (error.code) {
            case 'unknown':
                errorCode = 'unknown';
                errorMessage = 'Ocorreu um erro desconhecido.';
                break;
            case 'object-not-found':
                errorCode = 'not-found';
                errorMessage = 'Nenhum objeto na referência desejada.';
                break;
            case 'bucket-not-found':
                errorCode = 'bucket-not-found';
                errorMessage = 'Nenhum bucket configurado para o Cloud Storage.';
                break;
            case 'project-not-found':
                errorCode = 'project-not-found';
                errorMessage = 'Nenhum projeto configurado para o Cloud Storage.';
                break;
            case 'quota-exceeded':
                errorCode = 'quota-exceeded';
                errorMessage = 'A cota do bucket do Cloud Storage foi excedida.';
                break;
            case 'unauthenticated':
                errorCode = 'unauthenticated';
                errorMessage = 'O usuário não está autenticado.';
                break;
            case 'unauthorized':
                errorCode = 'unauthorized';
                errorMessage = 'O usuário não está autorizado a executar a ação desejada.';
                break;
            case 'retry-limit-exceeded':
                errorCode = 'retry-limit-exceeded';
                errorMessage = 'O limite máximo de tempo em uma operação foi excedido.';
                break;
            case 'invalid-checksum':
                errorCode = 'invalid-checksum';
                errorMessage = 'O arquivo no cliente não corresponde à soma de verificação do arquivo recebido pelo servidor.';
                break;
            case 'canceled':
                errorCode = 'canceled';
                errorMessage = 'O usuário cancelou a operação.';
                break;
            case 'invalid-event-name':
                errorCode = 'invalid-event-name';
                errorMessage = 'Nome inválido do evento fornecido.';
                break;
            case 'invalid-url':
                errorCode = 'invalid-url';
                errorMessage = 'URL inválido fornecido.';
                break;
            case 'invalid-argument':
                errorCode = 'invalid-argument';
                errorMessage = 'Argumento inválido transmitido.';
                break;
            case 'no-default-bucket':
                errorCode = 'no-default-bucket';
                errorMessage = 'Nenhum bucket foi definido na propriedade storageBucket da configuração.';
                break;
            case 'cannot-slice-blob':
                errorCode = 'cannot-slice-blob';
                errorMessage = 'O arquivo local foi alterado. Tente fazer o upload novamente.';
                break;
            case 'server-file-wrong-size':
                errorCode = 'server-file-wrong-size';
                errorMessage = 'O arquivo no cliente não corresponde ao tamanho do arquivo recebido pelo servidor.';
                break;
            default:
                errorCode = error.code;
                errorMessage = error.message;
        }

        //log de erro
        //console.error(error);

        //retonar bucketName caso ele exista 

        // 
        response.status(500).send(`Erro ao adicionar documento`);
    }
});

// exports.addFinalLocation = functions.https.onRequest(async (request, response) => {
//     try {
//         const missaoRef = db.collection('Rotas').doc(request.body.missaoId).collection('Rota').doc();
//         const dateString = request.body.timestamp;
//         const [datePart, timePart] = dateString.split(' ');
//         const [day, month, year] = datePart.split('/');
//         const [hour, minute, second] = timePart.split(':');

//         // Criar um objeto Date com os valores extraídos
//         const date = new Date(`${year}-${month}-${day}T${hour}:${minute}:${second}.000-03:00`);
//         await missaoRef.set({
//             latitude: Number(request.body.latitude),
//             longitude: Number(request.body.longitude),
//             timestamp: date,
//             uid: request.body.uid
//         }, { merge: true });

//         response.status(200).send(`Documento adicionado com sucesso`);
//     } catch (error) {
//         response.status(500).send("Erro ao adicionar documento");
//     }
// });

exports.finalizarMissao = functions.https.onRequest(async (request, response) => {
    // const requiredFields = [
    //     'userUid', 'cnpj', 'missaoID', 'nomeDaEmpresa', 'placaCavalo',
    //     'placaCarreta', 'motorista', 'corVeiculo', 'observacao', 'tipo',
    //     'userLatitude', 'userLongitude', 'userFinalLatitude', 'userFinalLongitude',
    //     'missaoLatitude', 'missaoLongitude', 'finalizadaPor'
    // ];

    // for (const field of requiredFields) {
    //     if (!request.body[field]) {
    //         return response.status(400).send(`Parâmetro ausente: ${field}`);
    //     }
    // }

    try {
        const MissoesAceitasRef = db.collection('Missões aceitas').doc(request.body.userUid);
        const MissoesAceitas = await MissoesAceitasRef.get();
        if (MissoesAceitas.exists) {
            await MissoesAceitasRef.delete();
        }

        const missaoEmpresaRef = db.collection('Empresa').doc(request.body.cnpj).collection('Missões ativas').doc(request.body.missaoID);
        const missaoEmpresa = await missaoEmpresaRef.get();
        if (missaoEmpresa.exists) {
            await missaoEmpresaRef.delete();
        }

        const missaoIniciadaRef = db.collection('Missão iniciada').doc(request.body.userUid);
        const missaoIniciada = await missaoIniciadaRef.get();
        if (missaoIniciada.exists) {
            await missaoIniciadaRef.delete();
        }

        const missaoRef = db.collection('Missões concluídas').doc(request.body.userUid).collection('Missão').doc(request.body.missaoID);

        let fim;
        if (request.body.fim) {
            fim = new Date(request.body.fim);
            if (isNaN(fim)) {
                throw new Error('Data inválida');
            }
        } else {
            fim = new Date();
        }

        await missaoRef.set({
            cnpj: request.body.cnpj,
            'nome da empresa': request.body.nomeDaEmpresa,
            placaCavalo: request.body.placaCavalo,
            placaCarreta: request.body.placaCarreta,
            motorista: request.body.motorista,
            corVeiculo: request.body.corVeiculo,
            observacao: request.body.observacao,
            'tipo de missao': request.body.tipo,
            missaoID: request.body.missaoID,
            userUid: request.body.userUid,
            userLatitude: Number(request.body.userLatitude),
            userLongitude: Number(request.body.userLongitude),
            userFinalLatitude: Number(request.body.userFinalLatitude),
            userFinalLongitude: Number(request.body.userFinalLongitude),
            missaoLatitude: Number(request.body.missaoLatitude),
            missaoLongitude: Number(request.body.missaoLongitude),
            'fim': fim,
            relatorio: true,
            finalizadaPor: request.body.finalizadaPor
        });

        response.status(200).send(`Documento adicionado com sucesso`);
    } catch (error) {
        console.log(`Erro ao adicionar documento: ${error}`);
        response.status(500).send(`Erro ao adicionar documento: ${error}, --- ${request.body.userUid}, ${request.body.missaoID}, ${request.body.cnpj}, ${request.body.nomeDaEmpresa}, ${request.body.placaCavalo}, ${request.body.placaCarreta}, ${request.body.motorista}, ${request.body.corVeiculo}, ${request.body.observacao}, ${request.body.tipo}, ${request.body.userLatitude}, ${request.body.userLongitude}, ${request.body.userFinalLatitude}, ${request.body.userFinalLongitude}, ${request.body.missaoLatitude}, ${request.body.missaoLongitude}`);
    }
});


exports.addRelatorioMissao = functions.https.onRequest((request, response) => {
    cors(request, response, async () => {
        console.log('inciando funcao addRelatorioMissao');
        console.log(request.body);
        try {
            let doc = await db.collection('Fotos relatório').doc(request.body.uid).collection('Missões').doc(request.body.missaoId).get();
            let missaoIniciadaRef = db.collection('Missões').doc(request.body.missaoId);
            let missaoIniciada = await missaoIniciadaRef.get();
            let fim;
            if (request.body.fim) {
                dateString = request.body.fim;
                const [datePart, timePart] = dateString.split(' ');
                const [day, month, year] = datePart.split('/');
                const [hour, minute, second] = timePart.split(':');

                // Criar um objeto Date com os valores extraídos
                fim = new Date(`${year}-${month}-${day}T${hour}:${minute}:${second}.000-03:00`);

                if (isNaN(fim)) {
                    console.log(`Erro ao adicionar documento, data inválida`);
                    response.status(500).send(`Erro ao adicionar documento, data inválida`);
                }
            } else {
                fim = new Date();
            }
            let inicio;
            if (missaoIniciada.exists) {
                inicio = missaoIniciada.data().timestamp;
            }
            let data = {
                'cnpj': request.body.cnpj,
                'nome da empresa': request.body.nomeDaEmpresa,
                'placaCavalo': request.body.placaCavalo ?? null,
                'placaCarreta': request.body.placaCarreta ?? null,
                'motorista': request.body.motorista ?? null,
                'corVeiculo': request.body.corVeiculo ?? null,
                'observacao': request.body.observacao ?? null,
                'uid': request.body.uid,
                'missaoId': request.body.missaoId,
                'nome': request.body.nome,
                'tipo': request.body.tipo,
                'infos': request.body.infos,
                'userInitialLatitude': Number(request.body.userInitialLatitude),
                'userInitialLongitude': Number(request.body.userInitialLongitude),
                'userFinalLatitude': Number(request.body.userFinalLatitude),
                'userFinalLongitude': Number(request.body.userFinalLongitude),
                'missaoLatitude': Number(request.body.missaoLatitude),
                'missaoLongitude': Number(request.body.missaoLongitude),
                'local': request.body.local,
                'inicio': inicio ?? null,
                'fim': fim,
                'serverFim': new Date(),
                'finalizadaPor': request.body.finalizadaPor
            }

            if (doc.exists && doc.data().fotos) {
                let fotos = doc.data().fotos;
                data = {
                    'cnpj': request.body.cnpj,
                    'nome da empresa': request.body.nomeDaEmpresa,
                    'placaCavalo': request.body.placaCavalo ?? null,
                    'placaCarreta': request.body.placaCarreta ?? null,
                    'motorista': request.body.motorista ?? null,
                    'corVeiculo': request.body.corVeiculo ?? null,
                    'observacao': request.body.observacao ?? null,
                    'uid': request.body.uid,
                    'missaoId': request.body.missaoId,
                    'nome': request.body.nome,
                    'tipo': request.body.tipo,
                    'infos': request.body.infos,
                    'userInitialLatitude': Number(request.body.userInitialLatitude),
                    'userInitialLongitude': Number(request.body.userInitialLongitude),
                    'userFinalLatitude': Number(request.body.userFinalLatitude),
                    'userFinalLongitude': Number(request.body.userFinalLongitude),
                    'missaoLatitude': Number(request.body.missaoLatitude),
                    'missaoLongitude': Number(request.body.missaoLongitude),
                    'local': request.body.local,
                    'inicio': inicio ?? null,
                    'fim': fim,
                    'serverFim': new Date(),
                    'fotos': fotos,
                    'finalizadaPor': request.body.finalizadaPor
                }
            }
            await db.collection('Relatórios').doc(request.body.uid).set({
                sinc: 'sinc'
            });
            await db.collection('Relatórios').doc(request.body.uid).collection('Missões').doc(request.body.missaoId).set(data);
            const fotosRelatorioRef = db.collection('Fotos relatório').doc(request.body.uid);
            const fotosRelatorio = await fotosRelatorioRef.get();
            if (fotosRelatorio.exists) {
                await fotosRelatorioRef.delete();
            }

            response.status(200).send(`Documento adicionado com sucesso`);
        } catch (error) {
            console.log(`Erro ao adicionar documento ${error}`)
            response.status(500).send(`Erro ao adicionar documento ${error}`);
        }
    });
});
// exports.incrementoRelatorioMissao2 = functions.https.onRequest(async (request, response) => {
//     const { uid, missaoId, fotosPosMissao, infos } = request.body;

//     try {
//         let data = { 'infos': infos };
//         let fotos = [];
//         if (fotosPosMissao && fotosPosMissao.length > 0) {
//             for (const fotoBase64 of fotosPosMissao) {
//                 //subir para o storage 
//                 const buffer = Buffer.from(fotoBase64.url, 'base64');
//                 const now = new Date();
//                 const token = `${request.body.missaoId}${now}`

//                 const file = storage.bucket().file(`FotosDeMissao/${request.body.missaoId}/${now}.jpg`);

//                 await file.save(buffer, {
//                     contentType: 'image/jpg',
//                     metadata: {
//                         firebaseStorageDownloadTokens: token
//                     }
//                 });

//                 const fileRef = getStorage().bucket().file(`FotosDeMissao/${request.body.missaoId}/${now}.jpg`);
//                 const downloadURL = await getDownloadURL(fileRef);

//                 console.log(` =================${downloadURL}`);


//                 //const downloadURL = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(`FotosDeMissao/${request.body.missaoId}/${now}.jpg`)}?alt=media&token=${token}`;
//                 fotoBase64.url = downloadURL;
//                 //console.log(` =================${fotoBase64.url}`);
//                 let horario = new Date();
//                 fotoBase64.timestamp = horario;
//                 fotos.push(fotoBase64);
//             };
//         }

//         if (fotos.length > 0) {
//             data['fotosPosMissao'] = fotos;
//         }

//         await admin.firestore()
//             .collection('Relatórios')
//             .doc(uid)
//             .collection('Missões')
//             .doc(missaoId)
//             .set(data, { merge: true });

//         response.status(200).send(`Relatório atualizado com sucesso`);

//     } catch (error) {
//         response.status(500).send(`Erro ao adicionar documento, erro: ${error}, --- ${request.body.uid}, ${request.body.missaoId}, ${request.body.fotosPosMissao}, ${request.body.infos}`);
//     }
// });



// // // // const functions = require('firebase-functions');
// // // // const admin = require('firebase-admin');
// // // // admin.initializeApp();

// exports.addDocument = functions.https.onRequest(async (request, response) => {
//     try {
//         const buffer = Buffer.from(request.body.image, 'base64');
//         const token = 'teste';
//         const now = new Date();
//         const file = admin.storage().bucket().file(`FotosDeMissao/${request.body.missaoId}/${now}.jpg`);

//         await file.save(buffer, {
//             contentType: 'image/jpg',
//             metadata: {
//                 firebaseStorageDownloadTokens: token
//             }
//         });

//         //log imprimindo fileSabe
//         //console.log(fileSave);

//         const bucketName = admin.storage().bucket().name;
//         const downloadURL = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(`FotosDeMissao/${request.body.missaoId}/${now}.jpg`)}?alt=media&token=${token}`;
//         response.status(200).send(`Documento adicionado com sucesso: ${downloadURL}`);
//     } catch (error) {
//         console.error("Erro ao adicionar documento: ", error);
//         response.status(500).send("Erro ao adicionar documento");
//     }
// });


// exports.checkChatNotifications = functions.firestore
//     .document('Chat/{docId}')
//     .onWrite((change, context) => {
//         // Verificar se o documento foi modificado com userUnreadCount > 0
//         const data = change.after.exists ? change.after.data() : null;

//         // Se o documento não existe mais, retorna false
//         if (!data) {
//             console.log('Notificação Chat: false');
//             return null;
//         }

//         // Verificar o valor de userUnreadCount
//         if (data.userUnreadCount > 0) {
//             console.log('Notificação Chat: true');
//             // Aqui você pode executar alguma lógica adicional, como enviar uma notificação
//             // Esta função não retorna um valor para o cliente diretamente, mas você pode,
//             // por exemplo, atualizar algum campo em Firestore ou enviar uma notificação push
//         } else {
//             console.log('Notificação Chat: false');
//         }

//         return null; // Cloud Functions deve sempre retornar um valor ou uma promessa
//     });

//editar displayName
// exports.editDisplayName = functions.https.onRequest((request, response) => {
//     cors(request, response, async () => {
//         try {
//             const uid = request.body.uid;
//             const nome = request.body.displayName;

//             await admin.auth().updateUser(uid, { displayName: nome });

//             response.status(200).send('Nome de usuário atualizado com sucesso');
//         } catch (error) {
//             console.error('Erro ao atualizar nome de usuário:', error);
//             response.status(500).send(`Erro ao atualizar nome de usuário: ${error}`);
//         }
//     });
// });


// // Função para alterar o email, nome e telefone do usuário
// exports.editUserInfos = functions.https.onRequest((request, response) => {
//     cors(request, response, async () => {
//         try {
//             const uid = request.body.uid;
//             const updates = {};

//             if (request.body.email) {
//                 updates.email = request.body.email;
//             }
//             if (request.body.displayName) {
//                 updates.displayName = request.body.displayName;
//             }
//             if (request.body.phoneNumber) {
//                 updates.phoneNumber = request.body.phoneNumber;
//             }

//             if (Object.keys(updates).length === 0) {
//                 response.status(400).send('Nenhuma informação fornecida para atualização.');
//                 return;
//             }

//             await admin.auth().updateUser(uid, updates);

//             response.status(200).send('Informações do usuário atualizadas com sucesso');
//         } catch (error) {
//             console.error('Erro ao atualizar informações do usuário:', error);
//             response.status(500).send(`Erro ao atualizar informações do usuário: ${error}`);
//         }
//     });
// });

// exports.getAllUsersAdmin = functions.https.onRequest((request, response) => {
//     cors(request, response, async () => {
//         try {
//             let allUsers = [];
//             let result = await admin.auth().listUsers(1000);
//             allUsers = allUsers.concat(result.users.map(userRecord => userRecord.toJSON()));

//             while (result.pageToken) {
//                 result = await admin.auth().listUsers(1000, result.pageToken);
//                 allUsers = allUsers.concat(result.users.map(userRecord => userRecord.toJSON()));
//             }

//             response.status(200).json(allUsers);
//         } catch (error) {
//             console.error("Erro ao listar usuários:", error);
//             response.status(500).send(`Erro ao listar usuários: ${error}`);
//         }
//     });
// });

// exports.updateMissingDisplayNames = functions.region('southamerica-east1').https.onCall(async (data, context) => {

//     // if (!context.auth.token.admin) {
//     //     throw new functions.https.HttpsError('permission-denied', 'Somente administradores podem executar essa função.');
//     // }

//     try {
//         let result = await admin.auth().listUsers(1000);
//         let updates = [];

//         do {
//             // Filtra os usuários sem displayName
//             const usersWithoutDisplayName = result.users.filter(user => !user.displayName);

//             for (const user of usersWithoutDisplayName) {
//                 // Busca o nome do usuário na coleção 'User Name' do Firestore
//                 const doc = await admin.firestore().collection('User Name').doc(user.uid).get();
//                 if (doc.exists) {
//                     const nome = doc.data().Nome;
//                     if (nome) {
//                         // Prepara para atualizar o displayName no Auth
//                         updates.push(admin.auth().updateUser(user.uid, { displayName: nome }));
//                     }
//                 }
//             }

//             // Se houver mais usuários, continue a busca
//             if (result.pageToken) {
//                 result = await admin.auth().listUsers(1000, result.pageToken);
//             } else {
//                 break;
//             }
//         } while (result.pageToken);

//         // Executa todas as atualizações acumuladas
//         await Promise.all(updates);

//         return { success: true, message: 'Display names atualizados com sucesso.' };
//     } catch (error) {
//         console.error("Erro ao atualizar display names:", error);
//         throw new functions.https.HttpsError('unknown', `Erro ao atualizar display names: ${error.message}`);
//     }
// });

// //funcao para excluir usuario
// exports.deleteUser = functions.https.onRequest((request, response) => {
//     cors(request, response, async () => {
//         try {

//             const uid = request.query.uid;

//             const userRecord = await admin.auth().getUser(uid);

//             // Verifica se o usuário existe
//             if (!userRecord) {
//                 return response.status(404).send('Usuário não encontrado.');
//             }

//             // Primeiro, lê os dados do documento na coleção 'User Infos'
//             const userInfoDoc = await db.collection('User Infos').doc(uid).get();

//             // Verifica se o documento existe
//             if (userInfoDoc.exists) {
//                 //return response.status(404).send('Usuário não encontrado.');
//                 // Pega os dados do documento
//                 const userInfoData = userInfoDoc.data();

//                 // Cria um novo documento na coleção 'Usuários Excluídos' com os mesmos dados
//                 await db.collection('Agentes excluidos').doc(uid).set(userInfoData);
//             } else {
//                 await db.collection('Usuarios excluidos').doc(uid).set({
//                     'uid': uid,
//                     'displayName': userRecord.displayName,
//                     'email': userRecord.email,
//                     'phoneNumber': userRecord.phoneNumber ?? null,
//                     'photoURL': userRecord.photoURL ?? null,
//                     'excludeTimestamp': new Date()
//                 });
//             }

//             const claim = userRecord.customClaims;

//             if (claim) {
//                 const centralCollection = db.collection('Central users');
//                 const clientCollection = db.collection('Empresa');
//                 if (claim.admin || claim.gestor || claim.operador) {
//                     const ref = centralCollection.doc(uid).get();
//                     if (ref.exists) {
//                         await centralCollection.doc(uid).delete();
//                     }
//                 }
//                 if (claim.adminCliente || claim.operadorCliente) {
//                     const empresaId = claim.empresaID;
//                     const ref = clientCollection
//                         .doc(empresaId)
//                         .collection('Usuarios')
//                         .doc(uid)
//                         .get();
//                     if (ref.exists) {
//                         await clientCollection.doc(uid).delete();
//                     }
//                 }
//             }

//             // Remove o usuário do Firebase Auth
//             await admin.auth().deleteUser(uid);

//             //verificar se a coleção existe
//             const userInfos = await db.collection('User Infos').doc(uid).get();
//             if (userInfos.exists) {
//                 await db.collection('User Infos').doc(uid).delete();
//             }
//             const userName = await db.collection('User Name').doc(uid).get();
//             if (userName.exists) {
//                 await db.collection('User Name').doc(uid).delete();
//             }
//             const userFoto = await db.collection('User Foto').doc(uid).get();
//             if (userFoto.exists) {
//                 await db.collection('User Foto').doc(uid).delete();
//             }

//             response.status(200).send('Usuário deletado com sucesso');
//         } catch (error) {
//             console.log(error);
//             if (error.errorInfo.code === 'auth/user-not-found') {
//                 // Usuário não encontrado, trate este caso conforme necessário.
//                 console.log('Usuário não encontrado');
//                 response.status(404).send('Usuário não encontrado');
//             } else {
//                 // Outros erros
//                 console.log('Erro ao deletar usuário:', error);
//                 response.status(500).send(`Erro ao deletar usuário: ${error}`);
//             }
//         }
//     })
// });

// //funcao para excluir empresa
// exports.deleteEmpresa = functions.https.onRequest(async (request, response) => {
//     try {
//         // Pega o CNPJ da empresa a partir do corpo da requisição
//         const cnpj = request.body.cnpj;

//         // Primeiro, lê os dados do documento na coleção 'Empresa'
//         const empresaDoc = await db.collection('Empresa').doc(cnpj).get();

//         // Verifica se o documento existe
//         if (!empresaDoc.exists) {
//             return response.status(404).send('Empresa não encontrada.');
//         }

//         // Pega os dados do documento
//         const empresaData = empresaDoc.data();

//         // Cria um novo documento na coleção 'Empresas Excluídas' com os mesmos dados
//         await db.collection('Empresas excluidas').doc(cnpj).set(empresaData);

//         // Continua para deletar a empresa e seus documentos relacionados
//         //verificar se a coleção existe
//         const empresa = await db.collection('Empresa').doc(cnpj).get();
//         if (empresa.exists) {
//             await db.collection('Empresa').doc(cnpj).delete();
//         }

//         response.status(200).send('Empresa deletada com sucesso');
//     } catch (error) {
//         response.status(500).send(`Erro ao deletar empresa: ${error}`);
//     }
// });

// //funcao para retirar custom claims do firebase auth do usuario
// exports.removeCentralCustomClaims = functions.https.onRequest(async (request, response) => {
//     try {
//         // Pega o UID do usuário a partir do corpo da requisição
//         const uid = request.body.uid;

//         // Primeiro, lê os dados do usuário
//         const userRecord = await admin.auth().getUser(uid);

//         // Verifica se o usuário existe
//         if (!userRecord) {
//             return response.status(404).send('Usuário não encontrado.');
//         }

//         // Remove todos os custom claims do usuário
//         await admin.auth().setCustomUserClaims(uid, null);

//         response.status(200).send('Custom claims removidos com sucesso');
//     } catch (error) {
//         response.status(500).send(`Erro ao remover custom claims: ${error}`);
//     }
// });

// exports.removeClientCustomClaims = functions.https.onRequest(async (request, response) => {
//     try {
//         // Pega o UID do usuário a partir do corpo da requisição
//         const uid = request.body.uid;

//         // Primeiro, lê os dados do usuário
//         const userRecord = await admin.auth().getUser(uid);

//         // Verifica se o usuário existe
//         if (!userRecord) {
//             return response.status(404).send('Usuário não encontrado.');
//         }

//         // Remove todos os custom claims do usuário
//         await admin.auth().setCustomUserClaims(uid, null);

//         response.status(200).send('Custom claims removidos com sucesso');
//     } catch (error) {
//         response.status(500).send(`Erro ao remover custom claims: ${error}`);
//     }
// });

