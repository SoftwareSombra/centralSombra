const { HttpsError } = require('firebase-functions').https;

class UserRepository {
    constructor(auth, firestore, storage) {
        if (!auth || !firestore) {
            throw new HttpsError('Dependência fornecida é invalida');
        }
        this.auth = auth;
        this.firestore = firestore;
        this.storage = storage;
    }

    async getUserName(uid) {
        try {
            const userDocRef = this.firestore.collection('User Name').doc(uid);
            const userDoc = await userDocRef.get();

            if (userDoc.exists) {
                return userDoc.data();
            } else {
                throw new HttpsError('Usuário não encontrado');
            }
        } catch (error) {
            throw new HttpsError('Falha ao buscar o nome do usuário.');
        }
    }

    async getUserPhotoUrl(uid) {
        try {
            const user = await this.auth.getUser(uid);
            if (user && user.photoURL) {
                return { photoURL: user.photoURL };
            } else {
                throw new HttpsError('Usuário ou foto não encontrado.');
            }
        } catch (error) {
            throw new HttpsError('Falha ao buscar foto do usuário.');
        }
    }

    async uploadFotoDePerfil(uid, image) {
        const buffer = Buffer.from(image, 'base64');
        const file = this.storage.bucket().file(`profileImages/${uid}/fotoDePerfil.jpg`);

        await file.save(buffer, {
            contentType: 'image/jpg',
            public: true,
        });

        const [signedUrl] = await file.getSignedUrl({
            action: 'read',
            expires: '03-09-2491',
        });

        return signedUrl;
    }

    async uploadDocImage(uid, image, nomeDoDoc) {
        const buffer = Buffer.from(image, 'base64');
        const file = this.storage.bucket().file(`Usuários docs/${uid}/${nomeDoDoc}`);

        await file.save(buffer, {
            contentType: 'image/jpg',
            public: true,
        });

        const [signedUrl] = await file.getSignedUrl({
            action: 'read',
            expires: '03-09-2491',
        });

        return signedUrl;
    }

    async uploadImage(image, nomeDoExercicio) {
        const buffer = Buffer.from(image, 'base64');
        const file = this.storage.bucket().file(`Exercícios/${nomeDoExercicio}/imagem`);
        
        await file.save(buffer, {
            contentType: 'image/jpg', // ou o tipo de conteúdo que você sabe que a imagem deve ter
            public: true,
        });
        
        const [signedUrl] = await file.getSignedUrl({
            action: 'read',
            expires: '03-09-2491',
        });
    
        return signedUrl;
    }

    async addInfos({ uid, endereco, cep, celular, rg, cpf,
        rgFotoFrente, 
        //rgFotoVerso, 
        //compResidFoto
    }) {
        await this.firestore.collection('User infos').doc(`${uid}`).set({
            'Endereço': endereco,
            'Cep': cep,
            'Celular': celular,
            'RG': rg,
            'CPF': cpf,
            'RG frente': rgFotoFrente,
            // 'Rg verso': rgFotoVerso,
            // 'Comprovante de residência': compResidFoto,
        });
    }

    async addCarro(uid, placaDoCarro, marca, ano, modelo) {
        await this.firestore.collection('Veículos')
            .doc(uid)
            .collection('Veículo')
            .doc(`${placaDoCarro}`)
            .set({
                'Placa': placaDoCarro,
                'Marca': marca,
                'Ano': ano,
                'Modelo': modelo,
            });
    }

    async addContaBancaria(uid, titular, numeroDaConta, agencia, chavePix) {
        await this.firestore.collection('Contas bancárias').doc(uid).set({
            'Titular': titular,
            'Número da conta': numeroDaConta,
            'Agência': agencia,
            'Chave pix': chavePix,
        })
    }

    
}

module.exports = UserRepository;