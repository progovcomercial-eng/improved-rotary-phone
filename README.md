# ALE CLUBE — React + Firebase

## Desenvolvimento
1. Instale Node.js LTS.
2. Execute `npm install`.
3. Copie `.env.example` para `.env.local` e preencha as credenciais do app Web do Firebase.
4. Execute `npm run dev`.

## Preparar o Firebase
1. Crie/abra o projeto no Firebase Console.
2. Em Authentication, habilite Email/Password.
3. Crie o banco Firestore.
4. Ative o Firebase Storage.
5. Crie o app Web e preencha as variáveis de `.env.local`.
6. Crie a conta proprietária com o e-mail `progovcomercial@gmail.com` em Authentication.
7. Publique as regras: `firebase deploy --only firestore:rules,storage`.

A conta proprietária é reconhecida pelo e-mail acima. Não coloque senhas nem chaves privadas no código. As credenciais do Firebase Web são variáveis públicas de configuração; a proteção dos dados é aplicada pelas regras do Firestore e Storage.

## Publicar no Firebase Hosting
Instale a CLI: `npm install -g firebase-tools`; faça `firebase login`; execute `firebase use --add` para associar o projeto; depois execute `npm run build` e `firebase deploy`.

## Recursos integrados nesta branch
- Login e cadastro por e-mail/senha via Firebase Authentication.
- Firestore para cadastros e sincronização de conteúdo publicado.
- Painel administrativo com clientes, associados, planos, tratamentos, parceiros, produtos/vitrine, promoções, agendamentos, pedidos, funcionários e configurações.
- Configurações de identidade, cores, logo, publicidade, vídeo, parcerias, horários, links e Alexandra IA.
- Solicitações de agendamento; o horário fica pendente até confirmação da equipe.
- Tratamentos com imagem, vídeo e link, limitados a 20 registros.
- Produtos/vitrine com imagem, vídeo e link externo.
- Upload de imagens e vídeos para Firebase Storage, com regras de acesso.
- Até cinco cadastros de funcionários; criação de gerente restrita à proprietária.
- PWA e configuração para Firebase Hosting.
- Workflow do GitHub Actions para executar `npm run build`.

## Ainda depende de configuração/serviço externo
- Preencher as variáveis Firebase, ativar serviços e testar as regras no projeto real.
- Publicar no Firebase Hosting.
- Pagamentos e integrações OAuth/API com Shopee, Mercado Livre, Amazon, Kiwify, Hotmart e QRFy.
- Respostas generativas da Alexandra IA: a tela e as instruções são configuráveis, mas a IA real precisa de um backend seguro e provedor conectado.
- Convites automáticos de funcionários pelo Firebase Authentication.
- Confirmação automática de agenda, notificações e pontuação XP por regras de negócio no backend.

A branch de integração deve ser validada pelo build e por testes no Firebase antes de ser mesclada em `main`.
