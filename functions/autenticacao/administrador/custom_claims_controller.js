const functions = require('firebase-functions').region('southamerica-east1');

class CustomClaimsController {
    constructor(customClaimsService) {
        this.customClaimsService = customClaimsService;
    }

    setDev = functions.https.onCall((data) => {
        return this.customClaimsService.setDevClaim(data);
    });

    setAdmin = functions.https.onCall((data) => {
        return this.customClaimsService.setAdminClaim(data);
    });

    setGestor = functions.https.onCall((data) => {
        return this.customClaimsService.setGestorClaim(data);
    });

    setOperador = functions.https.onCall((data) => {
        return this.customClaimsService.setOperadorClaim(data);
    });

    setAdminCliente = functions.https.onCall((data) => {
        return this.customClaimsService.setAdminClienteClaim(data);
    });

    setOperadorCliente = functions.https.onCall((data) => {
        return this.customClaimsService.setOperadorClienteClaim(data);
    });

    hasAllClaims = functions.https.onCall((data) => {
        return this.customClaimsService.hasAllClaims(data);
    });

    hasDev = functions.https.onCall((data) => {
        return this.customClaimsService.hasDevClaim(data);
    });

    hasAdmin = functions.https.onCall((data) => {
        return this.customClaimsService.hasAdminClaim(data);
    });

    hasGestor = functions.https.onCall((data) => {
        return this.customClaimsService.hasGestorClaim(data);
    });

    hasOperador = functions.https.onCall((data) => {
        return this.customClaimsService.hasOperadorClaim(data);
    });

    hasAdminCliente = functions.https.onCall((data) => {
        return this.customClaimsService.hasAdminClienteClaim(data);
    });

    hasOperadorCliente = functions.https.onCall((data) => {
        return this.customClaimsService.hasOperadorClienteClaim(data);
    });

    //deletar todos os usuarios 
    deleteAllUsers = functions.https.onCall(() => {
        return this.customClaimsService.deleteAllUsers();
    });

    deleteAllUsers2 = functions.https.onCall(() => {
        return this.customClaimsService.deleteAllUsers2();
    });
}

module.exports = CustomClaimsController;