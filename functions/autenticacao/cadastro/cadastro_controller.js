const functions = require('firebase-functions').region('southamerica-east1');

class CadastroController {
  constructor(cadastroService) {
    this.cadastroService = cadastroService;
  }
  registerUser = functions.https.onCall((data) => {
    return this.cadastroService.registerUser(data);
  });
}

module.exports = CadastroController;
