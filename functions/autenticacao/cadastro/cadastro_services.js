const { HttpsError } = require('firebase-functions').https;

class CadastroService {
  constructor(cadastroRepository) {
    this.cadastroRepository = cadastroRepository;
  }

  async registerUser(data) {
    try {
      const defaultProfileImage = await this.cadastroRepository.getDefaultProfileImageUrl();

      if (!data.nome || !data.email || !data.senha) {
        throw new HttpsError('Um ou mais campos estão vazios.');
      }

      const userRecord = await this.cadastroRepository.createUser({
        displayName: data.nome,
        email: data.email,
        password: data.senha,
        photoURL: defaultProfileImage
      })

      //se falhar não tem problema
      if (userRecord) {
        await this.cadastroRepository.addNome(data.nome, userRecord);
        await this.cadastroRepository.addFoto(defaultProfileImage, userRecord);
        //await this.cadastroRepository.addFCMtoken(data.token, user.uid);
        //await this.cadastroRepository.setAdminClaim(user.uid);
      }

      return {
        uid: userRecord,
        success: true,
        message: `Usuário cadastrado com sucesso.`
      };
    } catch (error) {
      switch (error.code) {
        case 'auth/email-already-exists':
          throw new HttpsError('already-exists', 'O email fornecido já está em uso.');
        case 'auth/invalid-password':
          throw new HttpsError('invalid-argument', 'A senha fornecida é inválida.');
        case 'auth/invalid-email':
          throw new HttpsError('invalid-argument', 'O email fornecido é inválido.');
        case 'auth/weak-password':
          throw new HttpsError('weak-password', 'A senha fornecida é muito fraca.');
        case 'auth/operation-not-allowed':
          throw new HttpsError('permission-denied', 'Operação não permitida.');
        default:
          throw new HttpsError('internal', 'Erro ao tentar cadastrar usuário');
      }
    }
  }
}

module.exports = CadastroService;