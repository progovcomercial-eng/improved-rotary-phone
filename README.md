# ALE CLUBE — React + Firebase

## Desenvolvimento
1. Instale Node.js LTS.
2. Execute `npm install`.
3. Copie `.env.example` para `.env.local` e preencha as credenciais do app Web do Firebase.
4. Execute `npm run dev`.

## Firebase
Ative Authentication > Email/Password e crie um banco Firestore em modo produção. Publique as regras com `firebase deploy --only firestore:rules`.

A conta proprietária é reconhecida pelo e-mail `progovcomercial@gmail.com`. Crie primeiro essa conta em Firebase Authentication. Não coloque senha ou chave privada no código. As credenciais do Firebase Web são variáveis públicas de configuração; as permissões reais são aplicadas pelas regras do Firestore.

## Publicação no Firebase Hosting
Instale a CLI: `npm install -g firebase-tools`; faça `firebase login`; execute `firebase use --add` para associar o projeto; depois `npm run build` e `firebase deploy`.

## Funções desta etapa
- Login e cadastro por e-mail/senha com Firebase Authentication.
- Reconhecimento da conta proprietária e estrutura inicial de funções de equipe.
- Painel com clientes, associados, planos, tratamentos, parceiros, produtos/vitrine, promoções, agendamentos, pedidos, funcionários e configurações.
- Cadastro, edição e exclusão dos registros suportados pelo formulário genérico, com Firestore.
- Conteúdo publicado sincronizado para visitantes.
- Formulário de interesse armazenado em leads.
- Regras iniciais de acesso e estrutura PWA para Firebase Hosting.

Pagamentos, agenda externa, upload de imagens/vídeos, convites e criação segura de contas de funcionários, e IA conversacional ainda exigem integrações próprias. A interface do módulo não significa que esses serviços externos já estejam conectados.
