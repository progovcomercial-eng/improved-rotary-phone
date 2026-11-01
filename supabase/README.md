# Backend do ALE CLUBE (preparação)

A aplicação visual está sendo preparada como PWA para Android e iPhone. Este diretório contém a primeira proposta de estrutura PostgreSQL/Supabase com Row Level Security.

## Antes de ativar
1. Criar um projeto Supabase sob controle do responsável pelo ALE CLUBE.
2. Revisar e executar `schema.sql` em ambiente novo/de teste.
3. Criar a conta proprietária e atribuir o papel `owner` usando procedimento administrativo seguro; nunca expor a chave service_role no aplicativo.
4. Configurar URL e chave pública no ambiente de build usando as variáveis de `.env.example`.
5. Implementar Edge Functions/webhooks para Mercado Pago/Kiwify. O cliente nunca pode declarar pagamento aprovado.
6. Configurar política de privacidade, retenção, consentimento e fluxo de dados sensíveis antes de guardar qualquer informação de saúde.

## Limites desta etapa
- Não há banco conectado nem autenticação real.
- Nenhum usuário, plano, preço, produto, pagamento ou agendamento real foi criado.
- Os dados exibidos como traços na área administrativa são intencionalmente vazios.
- A interface administrativa atual é demonstração e ainda não deve ser usada para gerir clientes reais.
- Revisão de segurança e testes em ambiente de homologação são obrigatórios antes de produção.
