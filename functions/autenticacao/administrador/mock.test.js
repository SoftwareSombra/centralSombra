const CustomClaimsService = require('./custom_claims_services'); // Importe a classe que contém setAdminClaim
const CustomClaimsRepository = require('./custom_claims_repository'); // Importe o repositório
const { HttpsError } = require('firebase-functions').https;

jest.mock('./custom_claims_repository'); // Mocke o módulo que contém CustomClaimsRepository

describe('CustomClaimsService', () => {
  let customClaimsService;
  let mockCustomClaimsRepository;

  beforeEach(() => {
    // Crie uma instância mockada do CustomClaimsRepository
    mockCustomClaimsRepository = new CustomClaimsRepository();
    // Resetar os mocks antes de cada teste
    mockCustomClaimsRepository.setAdminClaim.mockReset();
    mockCustomClaimsRepository.userExists.mockReset();

    // Crie uma instância do CustomClaimsService passando o repositório mockado
    customClaimsService = new CustomClaimsService(mockCustomClaimsRepository);
  });

  it('setAdminClaim deve chamar setAdminClaim do repositório com o UID fornecido', async () => {
    const mockUID = '12345';
    // Configurar o mock para resolver
    mockCustomClaimsRepository.userExists.mockResolvedValue(true);
    mockCustomClaimsRepository.setAdminClaim.mockResolvedValue();

    // Chamar a função setAdminClaim do serviço
    await customClaimsService.setAdminClaim({ uid: mockUID });

    // Verificar se o mock do repositório foi chamado corretamente
    expect(mockCustomClaimsRepository.setAdminClaim).toHaveBeenCalledWith(mockUID);
  });

  it('setAdminClaim deve lançar um erro se o UID não for informado', async () => {
    await expect(customClaimsService.setAdminClaim({}))
      .rejects.toThrow(new HttpsError('invalid-argument', 'UID não informado'));
  });

  it('setAdminClaim deve lançar um erro se o usuário não for encontrado', async () => {
    mockCustomClaimsRepository.userExists.mockResolvedValue(false);
    await expect(customClaimsService.setAdminClaim({ uid: '12345' }))
      .rejects.toThrow(new HttpsError('not-found', 'Usuário não encontrado'));
  });

  it('setAdminClaim deve lançar um erro se a operação falhar', async () => {
    const errorMessage = 'Erro interno';
    mockCustomClaimsRepository.userExists.mockResolvedValue(true);
    mockCustomClaimsRepository.setAdminClaim.mockRejectedValue({ code: 'internal-error', message: errorMessage });
    
    await expect(customClaimsService.setAdminClaim({ uid: '12345' }))
      .rejects.toThrow(`Falha ao setar claim de administrador: ${errorMessage}, UID: {"uid":"12345"}`);
  });
});
