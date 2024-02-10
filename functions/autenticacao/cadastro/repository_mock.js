// const UserService = require('./user_services');
// const UserRepository = require('./user_repository');

// jest.mock('./cadastro_repository');

// describe('UserService', () => {
//   let userService;
//   let mockUserRepository;

//   beforeEach(() => {
//     mockUserRepository = new UserRepository();
//     mockUserRepository.createUser.mockReset();

//     userService = new UserService(mockUserRepository);
//   });

//   it('registerUser deve chamar o createUser com os parametros corretos', async () => {
//     const testUser = {
//       nome: 'Test User',
//       email: 'test@example.com',
//       senha: 'password'
//     };
//     const defaultProfileImage = 'https://default/url';

//     mockUserRepository.getDefaultProfileImageUrl.mockResolvedValue(defaultProfileImage);
//     mockUserRepository.createUser.mockResolvedValue({ success: true });

//     await userService.registerUser(testUser);

//     expect(mockUserRepository.createUser).toHaveBeenCalledWith({
//       name: testUser.nome,
//       email: testUser.email,
//       password: testUser.senha,
//       photoURL: defaultProfileImage
//     });
//   });
// });
