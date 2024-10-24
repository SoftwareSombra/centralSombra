const functions = require('firebase-functions').region('southamerica-east1');
const cors = require('cors')({ origin: true });

class CadastroController {
  constructor(cadastroService) {
    this.cadastroService = cadastroService;
  }
  registerUser = functions.https.onCall((data) => {
    return this.cadastroService.registerUser(data);
  });
  updateUserName = functions.region('southamerica-east1').https.onRequest((request, response) => {
    cors(request, response, async () => {
        console.log(request.body);
        return await this.cadastroService.updateUserName(request, response);
    });
});
}

module.exports = CadastroController;
