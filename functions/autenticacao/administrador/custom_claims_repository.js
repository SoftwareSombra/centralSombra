class CustomClaimsRepository {
  constructor(auth, firestore, storage) {
    this.auth = auth;
    this.firestore = firestore;
    this.storage = storage;
  }

  // funcao para verificar se o usuario existe
  async userExists(uid) {
    try {
      const user = await this.auth.getUser(uid);
      return user;
    }
    catch (error) {
      return null;
    }
  }

  // funcao para desenvolvedor com todas as claims

  async setAllClaims(uid) {
    await this.auth.setCustomUserClaims(uid, {
      admin: true,
      gestor: true,
      operador: true,
      adminCliente: true,
      operadorCliente: true
    });
  }

  async setDevClaim(uid) {
    await this.auth.setCustomUserClaims(uid, {
      dev: true,
      admin: true,
      gestor: true,
      operador: true
    });
  }

  async setAdminClaim(uid) {
    await this.auth.setCustomUserClaims(uid, { admin: true, gestor: true, operador: true });
  }

  async setGestorClaim(uid) {
    await this.auth.setCustomUserClaims(uid, { gestor: true, operador: true });
  }

  async setOperadorClaim(uid) {
    await this.auth.setCustomUserClaims(uid, { operador: true });
  }

  async setAdminClienteClaim(uid, id) {
    await this.auth.setCustomUserClaims(uid, { adminCliente: true, operadorCliente: true, empresaID: id });
  }

  async setOperadorClienteClaim(uid, id) {
    await this.auth.setCustomUserClaims(uid, { operadorCliente: true, empresaID: id });
  }

  // Função para verificar se o usuário tem todas as claims
  async hasAllClaims(uid) {
    const user = await this.auth.getUser(uid);
    return user.customClaims && user.customClaims.admin === true &&
      user.customClaims.gestor === true &&
      user.customClaims.operador === true &&
      user.customClaims.adminCliente === true &&
      user.customClaims.operadorCliente === true;
  }

  //funcao para verificar se o usuario tem a claim de desenvolvedor
  async hasDevClaim(uid) {
    const user = await this.auth.getUser(uid);
    return user.customClaims.dev == true ? true : false;
  }

  // Função para verificar a claim de administrador
  async hasAdminClaim(uid) {
    const user = await this.auth.getUser(uid);
    return user.customClaims && user.customClaims.admin === true;
  }

  // Função para verificar a claim de gestor
  async hasGestorClaim(uid) {
    const user = await this.auth.getUser(uid);
    return user.customClaims && user.customClaims.gestor === true;
  }

  // Função para verificar a claim de operador
  async hasOperadorClaim(uid) {

    const user = await this.auth.getUser(uid);
    return user.customClaims && user.customClaims.operador === true;
  }

  // Função para verificar a claim de adminCliente
  async hasAdminClienteClaim(uid) {

    const user = await this.auth.getUser(uid);
    const isAdmin = user.customClaims && user.customClaims.adminCliente === true;
    const empresaId = user.customClaims && user.customClaims.empresaID;
    return { isAdmin, empresaId };
  }

  // Função para verificar a claim de operadorCliente
  async hasOperadorClienteClaim(uid) {
    const user = await this.auth.getUser(uid);
    const isOperador = user.customClaims && user.customClaims.operadorCliente === true;
    const empresaId = user.customClaims && user.customClaims.empresaID;
    return { isOperador, empresaId };
  }

  //funcao que exclui todos os usuarios 
  async deleteAllUsers() {
    let result = await this.auth.listUsers();
    let users = result.users;

    while (users.length > 0) {
      await Promise.all(users.map(user => this.auth.deleteUser(user.uid)));

      // Verifica se existem mais usuários para serem excluídos
      result = await this.auth.listUsers();
      users = result.users;
    }
  }

  async deleteAllUsers2() {
    try {
      let result = await this.auth.listUsers(1000);
      while (result.users.length > 0) {
        const uids = result.users.map(user => user.uid);
        const deleteResult = await this.auth.deleteUsers(uids);
  
        console.log(`Successfully deleted ${deleteResult.successCount} users`);
        if (deleteResult.failureCount > 0) {
          console.log(`Failed to delete ${deleteResult.failureCount} users`);
          deleteResult.errors.forEach(err => {
            console.log(err.error.toJSON());
          });
        }
  
        // Verifica se existem mais usuários para serem excluídos
        if (result.pageToken) {
          result = await this.auth.listUsers(1000, result.pageToken);
        } else {
          break;
        }
      }
  
      console.log('Todos os usuários foram excluídos');
    } catch (error) {
      console.error('Erro ao excluir usuários:', error);
    }
  }
}


module.exports = CustomClaimsRepository;