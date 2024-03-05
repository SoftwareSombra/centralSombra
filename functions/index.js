const functions = require('firebase-functions').region('southamerica-east1');
const cors = require('cors')({ origin: true });
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();
const storage = admin.storage();
const { getStorage, getDownloadURL } = require('firebase-admin/storage');


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


exports.getDirections = functions.https.onRequest((request, response) => {
    cors(request, response, async () => {
        if (request.method !== 'GET') {
            return response.status(500).json({ error: "Método não permitido" });
        }

        const googleMapsUrl = `https://maps.googleapis.com/maps/api/directions/json?${request.url.split('?')[1]}`;

        try {
            const apiResponse = await fetch(googleMapsUrl);
            const data = await apiResponse.json();
            response.json(data);
        } catch (err) {
            response.status(500).send(err);
        }
    });
});

//getRoute usando a api google routes
exports.getRoute = functions.https.onRequest((request, response) => {
    cors(request, response, async () => {
        if (request.method !== 'GET') {
            return response.status(500).json({ error: "Método não permitido" });
        }

        const googleMapsUrl = `https://maps.googleapis.com/maps/api/directions/json?${request.url.split('?')[1]}`;

        try {
            const apiResponse = await fetch(googleMapsUrl);
            const data = await apiResponse.json();
            response.json(data);
        } catch (err) {
            response.status(500).send(err);
        }
    });
});


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
//             const now = Date.now();
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
//             const now = Date.now();
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
//             const now = Date.now();
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


// exports.addFotoRelatorio2 = functions.https.onRequest(async (request, response) => {
//     try {
//         //log('request.body.missaoId', request.body.missaoId);
//         const buffer = Buffer.from(request.body.image, 'base64');
//         const now = Date.now();
//         const token = `${request.body.missaoId}${now}`

//         const file = storage.bucket().file(`FotosDeMissao/${request.body.missaoId}/${now}.jpg`);

//         await file.save(buffer, {
//             contentType: 'image/jpg',
//             metadata: {
//                 firebaseStorageDownloadTokens: token
//             }
//         });

//         //log imprimindo fileSabe
//         //console.log(fileSave);

//         const fileRef = getStorage().bucket().file(`FotosDeMissao/${request.body.missaoId}/${now}.jpg`);
//         const downloadURL = await getDownloadURL(fileRef);

//         console.log(` =================${downloadURL}`);

//         //const bucketName = storage.bucket().name;
//         //const downloadURL = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(`FotosDeMissao/${request.body.missaoId}/${now}.jpg`)}?alt=media&token=${token}`;
//         let fotoComLegenda = [
//             {
//                 url: downloadURL,
//                 caption: request.body.caption,
//                 timestamp: new Date()
//             }
//         ];

//         const fotosRelatorioRef = db.collection('Fotos relatório').doc(request.body.uid);
//         await fotosRelatorioRef.set({ sinc: 'sinc' });

//         const missaoRef = fotosRelatorioRef.collection('Missões').doc(request.body.missaoId);


//         await missaoRef.set({
//             fotos: admin.firestore.FieldValue.arrayUnion(...fotoComLegenda)
//         }, { merge: true });

//         response.status(200).send(`Documento adicionado com sucesso`);
//     } catch (error) {
//         // let errorCode = 'unknown-error';
//         // let errorMessage = 'Um erro desconhecido ocorreu.';

//         switch (error.code) {
//             case 'unknown':
//                 errorCode = 'unknown';
//                 errorMessage = 'Ocorreu um erro desconhecido.';
//                 break;
//             case 'object-not-found':
//                 errorCode = 'not-found';
//                 errorMessage = 'Nenhum objeto na referência desejada.';
//                 break;
//             case 'bucket-not-found':
//                 errorCode = 'bucket-not-found';
//                 errorMessage = 'Nenhum bucket configurado para o Cloud Storage.';
//                 break;
//             case 'project-not-found':
//                 errorCode = 'project-not-found';
//                 errorMessage = 'Nenhum projeto configurado para o Cloud Storage.';
//                 break;
//             case 'quota-exceeded':
//                 errorCode = 'quota-exceeded';
//                 errorMessage = 'A cota do bucket do Cloud Storage foi excedida.';
//                 break;
//             case 'unauthenticated':
//                 errorCode = 'unauthenticated';
//                 errorMessage = 'O usuário não está autenticado.';
//                 break;
//             case 'unauthorized':
//                 errorCode = 'unauthorized';
//                 errorMessage = 'O usuário não está autorizado a executar a ação desejada.';
//                 break;
//             case 'retry-limit-exceeded':
//                 errorCode = 'retry-limit-exceeded';
//                 errorMessage = 'O limite máximo de tempo em uma operação foi excedido.';
//                 break;
//             case 'invalid-checksum':
//                 errorCode = 'invalid-checksum';
//                 errorMessage = 'O arquivo no cliente não corresponde à soma de verificação do arquivo recebido pelo servidor.';
//                 break;
//             case 'canceled':
//                 errorCode = 'canceled';
//                 errorMessage = 'O usuário cancelou a operação.';
//                 break;
//             case 'invalid-event-name':
//                 errorCode = 'invalid-event-name';
//                 errorMessage = 'Nome inválido do evento fornecido.';
//                 break;
//             case 'invalid-url':
//                 errorCode = 'invalid-url';
//                 errorMessage = 'URL inválido fornecido.';
//                 break;
//             case 'invalid-argument':
//                 errorCode = 'invalid-argument';
//                 errorMessage = 'Argumento inválido transmitido.';
//                 break;
//             case 'no-default-bucket':
//                 errorCode = 'no-default-bucket';
//                 errorMessage = 'Nenhum bucket foi definido na propriedade storageBucket da configuração.';
//                 break;
//             case 'cannot-slice-blob':
//                 errorCode = 'cannot-slice-blob';
//                 errorMessage = 'O arquivo local foi alterado. Tente fazer o upload novamente.';
//                 break;
//             case 'server-file-wrong-size':
//                 errorCode = 'server-file-wrong-size';
//                 errorMessage = 'O arquivo no cliente não corresponde ao tamanho do arquivo recebido pelo servidor.';
//                 break;
//             default:
//                 errorCode = error.code;
//                 errorMessage = error.message;
//         }

//         //log de erro
//         //console.error(error);

//         //retonar bucketName caso ele exista 

//         // 
//         response.status(500).send(`Erro ao adicionar documento`);
//     }
// });

// exports.addFinalLocation = functions.https.onRequest(async (request, response) => {
//     try {
//         const missaoRef = db.collection('Rotas').doc(request.body.missaoId).collection('Rota').doc();
//         await missaoRef.set({
//             latitude: Number(request.body.latitude),
//             longitude: Number(request.body.longitude),
//             timestamp: new Date(request.body.timestamp),
//             uid: request.body.uid
//         }, { merge: true });

//         response.status(200).send(`Documento adicionado com sucesso`);
//     } catch (error) {
//         response.status(500).send("Erro ao adicionar documento");
//     }
// });

// exports.finalizarMissao = functions.https.onRequest(async (request, response) => {
//     try {
//         const MissoesAceitasRef = db.collection('Missões aceitas').doc(request.body.userUid);
//         const MissoesAceitas = await MissoesAceitasRef.get();
//         if (MissoesAceitas.exists) {
//             await MissoesAceitasRef.delete();
//         }

//         const missaoEmpresaRef = db.collection('Empresa').doc(request.body.cnpj).collection('Missões ativas').doc(request.body.missaoID);
//         const missaoEmpresa = await missaoEmpresaRef.get();
//         if (missaoEmpresa.exists) {
//             await missaoEmpresaRef.delete();
//         }

//         const missaoIniciadaRef = db.collection('Missão iniciada').doc(request.body.userUid);
//         const missaoIniciada = await missaoIniciadaRef.get();
//         if (missaoIniciada.exists) {
//             await missaoIniciadaRef.delete();
//         }

//         const missaoRef = db.collection('Missões concluídas').doc(request.body.userUid).collection('Missão').doc(request.body.missaoID);

//         let fim;
//         if (request.body.fim) {
//             fim = new Date(request.body.fim);
//             if (isNaN(fim)) {
//                 throw new Error('Data inválida');
//             }
//         } else {
//             fim = new Date();
//         }

//         await missaoRef.set({
//             cnpj: request.body.cnpj,
//             'nome da empresa': request.body.nomeDaEmpresa,
//             placaCavalo: request.body.placaCavalo,
//             placaCarreta: request.body.placaCarreta,
//             motorista: request.body.motorista,
//             corVeiculo: request.body.corVeiculo,
//             observacao: request.body.observacao,
//             'tipo de missao': request.body.tipo,
//             missaoID: request.body.missaoID,
//             userUid: request.body.userUid,
//             userLatitude: Number(request.body.userLatitude),
//             userLongitude: Number(request.body.userLongitude),
//             userFinalLatitude: Number(request.body.userFinalLatitude),
//             userFinalLongitude: Number(request.body.userFinalLongitude),
//             missaoLatitude: Number(request.body.missaoLatitude),
//             missaoLongitude: Number(request.body.missaoLongitude),
//             'fim': fim,
//             relatorio: true
//         },);

//         response.status(200).send(`Documento adicionado com sucesso`);
//     } catch (error) {
//         response.status(500).send(`Erro ao adicionar documento: ${error}, --- ${request.body.userUid}, ${request.body.missaoID}, ${request.body.cnpj}, ${request.body.nomeDaEmpresa}, ${request.body.placaCavalo}, ${request.body.placaCarreta}, ${request.body.motorista}, ${request.body.corVeiculo}, ${request.body.observacao}, ${request.body.tipo}, ${request.body.userLatitude}, ${request.body.userLongitude}, ${request.body.userFinalLatitude}, ${request.body.userFinalLongitude}, ${request.body.missaoLatitude}, ${request.body.missaoLongitude}`);
//     }
// });

// exports.addRelatorioMissao = functions.https.onRequest(async (request, response) => {

//     try {
//         let doc = await db.collection('Fotos relatório').doc(request.body.uid).collection('Missões').doc(request.body.missaoId).get();
//         let missaoIniciadaRef = db.collection('Missões').doc(request.body.missaoId);
//         let missaoIniciada = await missaoIniciadaRef.get();
//         let fim;
//         if (request.body.fim) {
//             fim = new Date(request.body.fim);
//             if (isNaN(fim)) {
//                 throw new Error('Data inválida');
//             }
//         } else {
//             fim = new Date();
//         }
//         let inicio;
//         if (missaoIniciada.exists) {
//             inicio = missaoIniciada.data().timestamp;
//         }
//         let data = {
//             'cnpj': request.body.cnpj,
//             'nome da empresa': request.body.nomeDaEmpresa,
//             'placaCavalo': request.body.placaCavalo,
//             'placaCarreta': request.body.placaCarreta ?? null,
//             'motorista': request.body.motorista,
//             'corVeiculo': request.body.corVeiculo ?? null,
//             'observacao': request.body.observacao ?? null,
//             'uid': request.body.uid,
//             'missaoId': request.body.missaoId,
//             'nome': request.body.nome,
//             'tipo': request.body.tipo,
//             'infos': request.body.infos,
//             'userInitialLatitude': Number(request.body.userInitialLatitude),
//             'userInitialLongitude': Number(request.body.userInitialLongitude),
//             'userFinalLatitude': Number(request.body.userFinalLatitude),
//             'userFinalLongitude': Number(request.body.userFinalLongitude),
//             'missaoLatitude': Number(request.body.missaoLatitude),
//             'missaoLongitude': Number(request.body.missaoLongitude),
//             'inicio': inicio,
//             'fim': fim,
//             'serverFim': new Date(),
//         }

//         if (doc.exists && doc.data().fotos) {
//             let fotos = doc.data().fotos;
//             data = {
//                 'cnpj': request.body.cnpj,
//                 'nome da empresa': request.body.nomeDaEmpresa,
//                 'placaCavalo': request.body.placaCavalo,
//                 'placaCarreta': request.body.placaCarreta ?? null,
//                 'motorista': request.body.motorista,
//                 'corVeiculo': request.body.corVeiculo ?? null,
//                 'observacao': request.body.observacao ?? null,
//                 'uid': request.body.uid,
//                 'missaoId': request.body.missaoId,
//                 'nome': request.body.nome,
//                 'tipo': request.body.tipo,
//                 'infos': request.body.infos,
//                 'userInitialLatitude': Number(request.body.userInitialLatitude),
//                 'userInitialLongitude': Number(request.body.userInitialLongitude),
//                 'userFinalLatitude': Number(request.body.userFinalLatitude),
//                 'userFinalLongitude': Number(request.body.userFinalLongitude),
//                 'missaoLatitude': Number(request.body.missaoLatitude),
//                 'missaoLongitude': Number(request.body.missaoLongitude),
//                 'inicio': inicio,
//                 'fim': fim,
//                 'serverFim': new Date(),
//                 'fotos': fotos
//             }
//         }
//         await db.collection('Relatórios').doc(request.body.uid).set({
//             sinc: 'sinc'
//         });
//         await db.collection('Relatórios').doc(request.body.uid).collection('Missões').doc(request.body.missaoId).set(data);
//         const fotosRelatorioRef = db.collection('Fotos relatório').doc(request.body.uid);
//         const fotosRelatorio = await fotosRelatorioRef.get();
//         if (fotosRelatorio.exists) {
//             await fotosRelatorioRef.delete();
//         }

//         response.status(200).send(`Documento adicionado com sucesso`);
//     } catch (error) {
//         response.status(500).send(`Erro ao adicionar documento`);
//     }
// });

exports.incrementoRelatorioMissao2 = functions.https.onRequest(async (request, response) => {
    const { uid, missaoId, fotosPosMissao, infos } = request.body;

    try {
        let data = { 'infos': infos };
        let fotos = [];
        if (fotosPosMissao && fotosPosMissao.length > 0) {
            for (const fotoBase64 of fotosPosMissao) {
                //subir para o storage 
                const buffer = Buffer.from(fotoBase64.url, 'base64');
                const now = Date.now();
                const token = `${request.body.missaoId}${now}`

                const file = storage.bucket().file(`FotosDeMissao/${request.body.missaoId}/${now}.jpg`);

                await file.save(buffer, {
                    contentType: 'image/jpg',
                    metadata: {
                        firebaseStorageDownloadTokens: token
                    }
                });

                const fileRef = getStorage().bucket().file(`FotosDeMissao/${request.body.missaoId}/${now}.jpg`);
                const downloadURL = await getDownloadURL(fileRef);

                console.log(` =================${downloadURL}`);


                //const downloadURL = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(`FotosDeMissao/${request.body.missaoId}/${now}.jpg`)}?alt=media&token=${token}`;
                fotoBase64.url = downloadURL;
                //console.log(` =================${fotoBase64.url}`);
                let horario =  new Date();
                fotoBase64.timestamp = horario;
                fotos.push(fotoBase64);
            };
        }

        if (fotos.length > 0) {
            data['fotosPosMissao'] = fotos;
        }

        await admin.firestore()
            .collection('Relatórios')
            .doc(uid)
            .collection('Missões')
            .doc(missaoId)
            .set(data, { merge: true });

        response.status(200).send(`Relatório atualizado com sucesso`);

    } catch (error) {
        response.status(500).send(`Erro ao adicionar documento, erro: ${error}, --- ${request.body.uid}, ${request.body.missaoId}, ${request.body.fotosPosMissao}, ${request.body.infos}`);
    }
});



// const functions = require('firebase-functions');
// const admin = require('firebase-admin');
// admin.initializeApp();

// exports.addDocument = functions.https.onRequest(async (request, response) => {
//     try {
//         const buffer = Buffer.from(request.body.image, 'base64');
//         const token = 'teste';
//         const now = Date.now();
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