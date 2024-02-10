class CadastroModel {
  constructor(uid, name, email, password, photoURL) {
    this.uid = uid;
    this.name = name;
    this.email = email;
    this.password = password;
    this.photoURL = photoURL;
  }
}

module.exports = CadastroModel;