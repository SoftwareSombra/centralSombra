const { HttpsError } = require('firebase-functions').https;

class CustomClaimsServices {
  constructor(customClaimsRepository) {
    this.customClaimsRepository = customClaimsRepository;
  }

  async setAllClaims(data) {
    if (!data.uid) {
      throw new HttpsError('invalid-argument', 'UID não informado');
    }
    try {
      const user = await this.customClaimsRepository.userExists(data.uid);
      if (user != null) {
        await this.customClaimsRepository.setAllClaims(data.uid);
      } else {
        throw new HttpsError('not-found', 'Usuário não encontrado');
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async setDevClaim(data) {
    if (!data.uid) {
      throw new HttpsError('invalid-argument', 'UID não informado');
    }
    try {
      const user = await this.customClaimsRepository.userExists(data.uid);
      if (user != null) {
        await this.customClaimsRepository.setDevClaim(data.uid);
      } else {
        throw new HttpsError('not-found', 'Usuário não encontrado');
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async setAdminClaim(data) {
    if (!data.uid) {
      throw new HttpsError('invalid-argument', 'UID não informado');
    }

    try {
      const user = await this.customClaimsRepository.userExists(data.uid);
      if (user != null) {
        await this.customClaimsRepository.setAdminClaim(data.uid);
      } else {
        throw new HttpsError('not-found', 'Usuário não encontrado');
      }
    } catch (error) {
      this.handleError(error);
      //throw new HttpsError('not-found', `Falha ao setar claim de gestor(${error.code}): ${error.message}, UID: ${JSON.stringify(data)}`);
    }
  }


  async setGestorClaim(data) {
    if (!data.uid) {
      throw new HttpsError('invalid-argument', 'UID não informado');
    }
    try {
      const user = await this.customClaimsRepository.userExists(data.uid);
      if (user != null) {
        await this.customClaimsRepository.setGestorClaim(data.uid);
      } else {
        throw new HttpsError('not-found', 'Usuário não encontrado');
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async setOperadorClaim(data) {
    if (!data.uid) {
      throw new HttpsError('invalid-argument', 'UID não informado');
    }
    try {
      const user = await this.customClaimsRepository.userExists(data.uid);
      if (user != null) {
        await this.customClaimsRepository.setOperadorClaim(data.uid);
      }
      else {
        throw new HttpsError('not-found', 'Usuário não encontrado');
      }
    } catch (error) {
      this.handleError(error);
    }
  }


  async setAdminClienteClaim(data) {
    if (!data.uid) {
      throw new HttpsError('invalid-argument', 'UID não informado');
    }
    try {
      const user = await this.customClaimsRepository.userExists(data.uid);
      if (user != null) {
        await this.customClaimsRepository.setAdminClienteClaim(data.uid, data.id);
      } else {
        throw new HttpsError('not-found', 'Usuário não encontrado');
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async setOperadorClienteClaim(data) {
    if (!data.uid) {
      throw new HttpsError('invalid-argument', 'UID não informado');
    }
    try {
      const user = await this.customClaimsRepository.userExists(data.uid);
      if (user != null) {
        await this.customClaimsRepository.setOperadorClienteClaim(data.uid, data.id);
      } else {
        throw new HttpsError('not-found', 'Usuário não encontrado');
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async hasAllClaims(data) {
    if (!data.uid) {
      throw new HttpsError('invalid-argument', 'UID não informado');
    }

    try {
      const user = await this.customClaimsRepository.userExists(data.uid);
      if (user != null) {
        return await this.customClaimsRepository.hasAllClaims(data.uid);
      } else {
        throw new HttpsError('not-found', 'Usuário não encontrado');
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  //funcao para verificar se o usuario tem claim de desenvolvedor
  async hasDevClaim(data) {
    if (!data.uid) {
      throw new HttpsError('invalid-argument', 'UID não informado');
    }
    try {
      const user = await this.customClaimsRepository.userExists(data.uid);
      if (user != null) {
        return await this.customClaimsRepository.hasDevClaim(data.uid);
      } else {
        return HttpsError('not-found', 'Usuário não encontrado');
      }

    } catch (error) {
      //throw new HttpsError('not-found', `Falha ao verificar claim de desenvolvedor(${error.code}): ${error.message}, UID: ${JSON.stringify(data)}`);
      this.handleError(error);
      return '${error.code}): ${error.message}';
    }
  }

  async hasAdminClaim(data) {
    if (!data.uid) {
      throw new HttpsError('invalid-argument', 'UID não informado');
    }
    try {
      const user = await this.customClaimsRepository.userExists(data.uid);
      if (user != null) {
        return await this.customClaimsRepository.hasAdminClaim(data.uid);
      } else {
        throw new HttpsError('not-found', 'Usuário não encontrado');
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async hasGestorClaim(data) {

    if (!data.uid) {
      throw new HttpsError('invalid-argument', 'UID não informado');
    }
    try {
      const user = await this.customClaimsRepository.userExists(data.uid);
      if (user != null) {
        return await this.customClaimsRepository.hasGestorClaim(data.uid);
      } else {
        throw new HttpsError('not-found', 'Usuário não encontrado');
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async hasOperadorClaim(data) {

    if (!data.uid) {
      throw new HttpsError('invalid-argument', 'UID não informado');
    }
    try {
      const user = await this.customClaimsRepository.userExists(data.uid);
      if (user != null) {
        return await this.customClaimsRepository.hasOperadorClaim(data.uid);
      } else {
        throw new HttpsError('not-found', 'Usuário não encontrado');
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async hasAdminClienteClaim(data) {

    if (!data.uid) {
      throw new HttpsError('invalid-argument', 'UID não informado');
    }
    try {
      const user = await this.customClaimsRepository.userExists(data.uid);
      if (user != null) {
        return await this.customClaimsRepository.hasAdminClienteClaim(data.uid);
      } else {
        throw new HttpsError('not-found', 'Usuário não encontrado');
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async hasOperadorClienteClaim(data) {

    if (!data.uid) {
      throw new HttpsError('invalid-argument', 'UID não informado');
    }
    try {
      const user = await this.customClaimsRepository.userExists(data.uid);
      if (user != null) {
        return await this.customClaimsRepository.hasOperadorClienteClaim(data.uid);
      } else {
        throw new HttpsError('not-found', 'Usuário não encontrado');
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  //funcao para deletar todos os usuarios 
  async deleteAllUsers() {
    try {
      await this.customClaimsRepository.deleteAllUsers();
    } catch (error) {
      throw new HttpsError('erro', `Falha ao excluir usuarios(${error.code}): ${error.message}`);
    }
  }

  async deleteAllUsers2() {
    try {
      await this.customClaimsRepository.deleteAllUsers2();
    } catch (error) {
      throw new HttpsError('erro', `Falha ao excluir usuarios(${error.code}): ${error.message}`);
    }
  }

  handleError(error) {
    let userFriendlyMessage;

    switch (error.code) {
      case 'auth/user-not-found':
        userFriendlyMessage = 'Usuário não encontrado.';
        break;
      case 'user-not-found':
        userFriendlyMessage = 'Usuário não encontrado.';
        break;
      case 'not-found':
        userFriendlyMessage = 'Usuário não encontrado.';
        break;
      case 'unknown':
        userFriendlyMessage = 'Erro desconhecido.';
        break;
      case 'internal':
        userFriendlyMessage = 'Erro interno.';
        break;
      case 'unauthenticated':
        userFriendlyMessage = 'Não autenticado.';
        break;
      case 'invalid-argument':
        userFriendlyMessage = 'Argumento inválido.';
        break;
      default:
        userFriendlyMessage = 'Um erro desconhecido ocorreu.';
    }

    throw new HttpsError(error.code, userFriendlyMessage);
  }
}

module.exports = CustomClaimsServices;