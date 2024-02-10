const { HttpsError } = require('firebase-functions').https;

class UserService {
  constructor(userRepository) {
    if (!userRepository) {
      throw new HttpsError('internal', 'Repositório não fornecido');
    }
    this.userRepository = userRepository;
  }

  handleError(error) {
    let userFriendlyMessage = 'Um erro desconhecido ocorreu.';

    switch (error.code) {
      case 'cancelled':
        userFriendlyMessage = 'A operação foi cancelada pelo usuário.';
        break;
      case 'unknown':
        userFriendlyMessage = 'Erro desconhecido.';
        break;
      case 'invalid-argument':
        userFriendlyMessage = 'Argumento inválido.';
        break;
      case 'deadline-exceeded':
        userFriendlyMessage = 'O tempo limite da operação foi excedido.';
        break;
      case 'not-found':
        userFriendlyMessage = 'Recurso não encontrado.';
        break;
      case 'already-exists':
        userFriendlyMessage = 'O recurso já existe.';
        break;
      case 'permission-denied':
        userFriendlyMessage = 'Permissão negada.';
        break;
      case 'resource-exhausted':
        userFriendlyMessage = 'Recursos esgotados.';
        break;
      case 'failed-precondition':
        userFriendlyMessage = 'Condição prévia falhou.';
        break;
      case 'aborted':
        userFriendlyMessage = 'Operação abortada.';
        break;
      case 'out-of-range':
        userFriendlyMessage = 'Fora do intervalo permitido.';
        break;
      case 'unimplemented':
        userFriendlyMessage = 'Não implementado.';
        break;
      case 'internal':
        userFriendlyMessage = 'Erro interno.';
        break;
      case 'unavailable':
        userFriendlyMessage = 'Serviço indisponível.';
        break;
      case 'data-loss':
        userFriendlyMessage = 'Perda de dados.';
        break;
      case 'unauthenticated':
        userFriendlyMessage = 'Não autenticado.';
        break;
      default:
        userFriendlyMessage = 'Um erro desconhecido ocorreu.';
    }

    throw new HttpsError(error.code, userFriendlyMessage);
  }


  async getName(data) {
    try {
      if (!data || !data.uid) {
        throw new HttpsError('invalid-argument', 'UID está vazio.');
      }
      const userName = await this.userRepository.getUserName(data.uid);
      if (!userName) {
        throw new HttpsError('not-found', `Nome do Usuário com UID ${data.uid} não encontrado.`);
      }
      return userName;
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error; // Re-throw if it's already an HttpsError
      }
      throw new HttpsError('internal', 'Erro ao buscar nome.');
    }
  }

  async getPhoto(data) {
    try {
      if (!data || !data.uid) {
        throw new HttpsError('invalid-argument', 'UID está vazio.');
      }
      const userPhoto = await this.userRepository.getUserPhotoUrl(data.uid);
      if (!userPhoto || !userPhoto.photoURL) {
        throw new HttpsError('not-found', 'Foto não encontrada.');
      }
      return userPhoto;
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError('internal', 'Erro ao buscar foto.');
    }
  }

  // async uploadFotoDePerfil(data) {
  //   try {
  //     if (!data.uid || !data.image) {
  //       throw new HttpsError('invalid-argument', 'Um ou mais campos estão vazios ou não são válidos.');
  //     }
  //     return await this.repository.uploadFotoDePerfil({ uid: data.uid, image: data.image });
  //   } catch (error) {
  //     this.handleError(error);
  //   }
  // }

  // async uploadDocImage(data) {
  //   try {
  //     if (!data.uid || !data.image || !data.nomeDoDoc) {
  //       throw new HttpsError('invalid-argument', 'Um ou mais campos estão vazios ou não são válidos.');
  //     }
  //     return await this.repository.uploadDocImage({ uid: data.uid, image: data.image, nomeDoDoc: data.nomeDoDoc });
  //   } catch (error) {
  //     this.handleError(error);
  //   }
  // }

  async addUserInfos(data) {
    try {
      if (!data.uid || !data.endereco || !data.cep || !data.celular || !data.rg || !data.cpf || !data.rgFotoFrente
        // || !data.rgFotoVerso || !data.compResidFoto
        ) {
        throw new HttpsError('invalid-argument', 'Um ou mais campos estão vazios ou não são válidos.');
      }
      // const rgFotoVersoUrl = await this.userRepository.uploadDocImage(
      //   data.uid,
      //   data.rgFotoVerso,
      //   'RG verso');
      // const rgFotoFrenteUrl = await this.userRepository.uploadDocImage(
      //   data.uid,
      //   data.rgFotoFrente,
      //   'RG frente');
      // const compResidFotoUrl = await this.userRepository.uploadDocImage(
      //   data.uid,
      //   data.compResidFoto,
      //   'Comprovante de residência');

      const rgFotoFrente = 
      await this.userRepository.uploadImage(data.rgFotoFrente, data.uid);

      await this.userRepository.addInfos({
        uid: data.uid,
        endereco: data.endereco,
        cep: data.cep,
        celular: data.celular,
        rg: data.rg,
        cpf: data.cpf,
        rgFotoFrente: rgFotoFrente,
        // rgFotoVerso: rgFotoVersoUrl,
        // compResidFoto: compResidFotoUrl
      });
      return {
        success: true,
        message: 'Informações adicionadas com sucesso.'
      };
    } catch (error) {
      console.error('Erro:', error.code);

      let userFriendlyMessage = 'Um erro desconhecido ocorreu.';

      switch (error.code) {
        case 'cancelled':
          userFriendlyMessage = 'A operação foi cancelada pelo usuário.';
          break;
        case 'unknown':
          userFriendlyMessage = 'Erro desconhecido.';
          break;
        case 'invalid-argument':
          userFriendlyMessage = 'Argumento inválido.';
          break;
        case 'deadline-exceeded':
          userFriendlyMessage = 'O tempo limite da operação foi excedido.';
          break;
        case 'not-found':
          userFriendlyMessage = 'Recurso não encontrado.';
          break;
        case 'already-exists':
          userFriendlyMessage = 'O recurso já existe.';
          break;
        case 'permission-denied':
          userFriendlyMessage = 'Permissão negada.';
          break;
        case 'resource-exhausted':
          userFriendlyMessage = 'Recursos esgotados.';
          break;
        case 'failed-precondition':
          userFriendlyMessage = 'Condição prévia falhou.';
          break;
        case 'aborted':
          userFriendlyMessage = 'Operação abortada.';
          break;
        case 'out-of-range':
          userFriendlyMessage = 'Fora do intervalo permitido.';
          break;
        case 'unimplemented':
          userFriendlyMessage = 'Não implementado.';
          break;
        case 'internal':
          userFriendlyMessage = 'Erro interno.';
          break;
        case 'unavailable':
          userFriendlyMessage = 'Serviço indisponível.';
          break;
        case 'data-loss':
          userFriendlyMessage = 'Perda de dados.';
          break;
        case 'unauthenticated':
          userFriendlyMessage = 'Não autenticado.';
          break;
        default:
          userFriendlyMessage = 'Um erro desconhecido ocorreu.';
      }
      throw new HttpsError(error.code, userFriendlyMessage);
    }
  }

  async addCarro(data) {
    try {
      if (!data.uid || !data.placaDoCarro || !data.marca || !data.ano || !data.modelo) {
        throw new HttpsError('invalid-argument', 'Um ou mais campos estão vazios ou não são válidos.');
      }
      await this.repository.addCarro({ uid: data.uid, placaDoCarro: data.placaDoCarro, marca: data.marca, ano: data.ano, modelo: data.modelo });
      return {
        success: true,
        message: 'Veículo cadastrado com sucesso.'
      };
    } catch (error) {
      this.handleError(error);
    }
  }

  async addContaBancaria(data) {
    try {
      if (!data.uid || !data.titular || !data.numeroDaConta || !data.agencia || !data.chavePix) {
        throw new HttpsError('invalid-argument', 'Um ou mais campos estão vazios ou não são válidos.');
      }
      await this.repository.addContaBancaria({ uid: data.uid, titular: data.titular, numeroDaConta: data.numeroDaConta, agencia: data.agencia, chavePix: data.chavePix });
      return {
        success: true,
        message: 'Conta bancária cadastrada com sucesso.'
      };
    } catch (error) {
      this.handleError(error);
    }
  }

}

module.exports = UserService;
