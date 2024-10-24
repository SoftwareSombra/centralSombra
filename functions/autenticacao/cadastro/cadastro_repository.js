const { HttpsError } = require('firebase-functions').https;

class CadastroRepository {
  constructor(auth, firestore, storage) {
    this.auth = auth;
    this.firestore = firestore;
    this.storage = storage;
  }

  async createUser({ displayName, email, password, photoURL }) {
    const userRecord = await this.auth.createUser({
      email,
      password,
      displayName,
      photoURL
    });
    return userRecord.uid;
  }

  async updateName(uid, nome) {
    if (nome == null || uid == null) {
      throw new HttpsError('invalid-argument', 'Nome e UID não podem ser nulos.');
    }
    await this.auth.updateUser(uid, { displayName: nome });
    await this.firestore.collection('User Name').doc(uid).set({
      'Nome': nome,
      'UID': uid
    });
  }

  async deleteUser(uid) {
    await this.auth.deleteUser(uid);
  }

  async addFCMtoken(token, uid) {
    this.firestore.collection('FCM Tokens').doc(uid).collection('tokens').doc(token).set({
      'FCM Token': token,
    });
  }


  async addNome(nome, uid) {
    await this.firestore.collection('User Name').doc(uid).set({
      'Nome': nome,
      'UID': uid
    });
  }

  async addFoto(fotoUrl, uid) {
    await this.firestore.collection('User Foto').doc(uid).set({
      'FotoUrl': fotoUrl,
    });
    // const defaultImagePath = `FotoNull/fotoDePerfilNull.jpg`;
    // const filePath = `profileImages/${uid}/defaultProfileImage.jpg`;
    // await this.storage.bucket().file(defaultImagePath).copy(filePath);
  }

  async getDefaultProfileImageUrl() {
    return 'https://firebasestorage.googleapis.com/v0/b/primeval-rune-309222.appspot.com/o/FotoNull%2FfotoDePerfilNull.jpg?alt=media&token=83532362-51e3-4cbb-8f83-cf6accd7aedb';
  }

  async setAdminClaim(uid) {
    await this.auth.setCustomUserClaims(uid, { admin: true });
  }

}

module.exports = CadastroRepository;
