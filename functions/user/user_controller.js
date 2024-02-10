const { HttpsError } = require('firebase-functions').https;
const functions = require('firebase-functions').region('southamerica-east1');

class UserController {
    constructor(userService) {
        if (!userService) {
            throw new HttpsError('internal', 'Service não fornecido.');
        }
        this.userService = userService;
    }

    getName = functions.https.onCall(async (data) => {
        return await this.userService.getName(data);
    }
    );

    getPhoto = functions.https.onCall(async (data) => {
        return await this.userService.getPhoto(data);
    });

    addUserInfos = functions.https.onCall(async (data) => {
        return await this.userService.addUserInfos(data);
    });
}

module.exports = UserController;
