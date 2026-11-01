# Configuração de autenticação — ALE CLUBE

## O que esta etapa prepara
- Cliente oficial Supabase com sessão persistente e fluxo PKCE.
- Login por e-mail e senha.
- Verificação de papéis no banco; não confiar em flags do navegador.
- Recuperação de senha por e-mail.
- Bloqueio de contas sem papel administrativo.
- Procedimento separado para conceder o primeiro papel owner.

## Dependências externas obrigatórias
1. Criar um projeto Supabase de propriedade do ALE CLUBE.
2. Em Authentication > URL Configuration, configurar o domínio de produção e URLs locais autorizadas.
3. Criar a conta proprietária em Authentication > Users (ou por convite seguro).
4. Revisar e executar o schema em ambiente de teste; depois executar owner-bootstrap.sql, substituindo o UUID real após conferir a conta.
5. Definir VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY no ambiente de build. A chave anon/public pode estar no frontend; a chave service_role nunca.
6. Configurar SMTP próprio para e-mails de confirmação e recuperação antes de produção.

## Segurança
- O papel owner não pode ser escolhido pelo formulário de cadastro.
- Não criar usuário proprietário pelo navegador nem expor service_role.
- A autorização final dos dados deve continuar nas políticas RLS do PostgreSQL.
- Conectar a autenticação à interface e testar contas sem papel, cada papel de equipe e a proprietária.
- Não cadastrar dados reais até revisar RLS, LGPD, privacidade e retenção.

## Limitação
Esta preparação não cria o projeto Supabase, não configura credenciais, não cria usuário e não ativa o login no site automaticamente. Esses passos dependem do projeto Supabase controlado pela proprietária e da configuração segura do ambiente.
