# Configuração do acesso administrativo — ALE CLUBE

O acesso administrativo usa Supabase Auth e a função de banco de dados `current_app_role`. A interface só abre o painel depois que o usuário entra e o banco confirma a função `owner` ou `manager`.

## 1. Criar o projeto Supabase
1. Crie um projeto Supabase exclusivo para o ALE CLUBE.
2. Em Project Settings → API, copie Project URL e a chave pública/anon (publishable/anon).
3. Configure no ambiente de build/hosting:
   - `VITE_SUPABASE_URL` = Project URL
   - `VITE_SUPABASE_ANON_KEY` = chave pública anon/publishable
4. Reimplante o aplicativo depois de salvar as variáveis.

A chave pública pode estar no frontend; **não coloque a service_role key no aplicativo**.

## 2. Criar as tabelas e políticas de função
1. No Supabase, abra SQL Editor.
2. Execute o arquivo `supabase/admin-roles.sql` deste repositório.

## 3. Criar o primeiro usuário proprietário
1. Em Authentication → Users, crie o usuário proprietário com e-mail e senha fortes.
2. Copie o UUID desse usuário.
3. No SQL Editor, execute, substituindo o UUID:
   ```sql
   insert into public.app_user_roles(user_id, role)
   values ('UUID-DO-USUARIO', 'owner');
   ```

Para dar acesso de gerente a alguém da equipe, crie primeiro o usuário em Authentication → Users e então associe:
```sql
insert into public.app_user_roles(user_id, role)
values ('UUID-DO-FUNCIONARIO', 'manager');
```

Para remover o acesso administrativo, apague a linha correspondente de `app_user_roles` ou altere a função para um valor não autorizado.

## 4. Abrir a tela administrativa
Acesse o aplicativo com o parâmetro `?admin=1`, por exemplo:
`https://SEU-DOMINIO/?admin=1`

O usuário deverá informar e-mail e senha. O painel só será aberto se a função do usuário for `owner` ou `manager`. Clientes comuns não recebem botão de configuração nem autorização para abrir o painel.

## 5. Papéis nesta etapa
- `owner`: proprietário do ALE CLUBE.
- `manager`: gerente/funcionário com acesso ao painel administrativo.
- `staff`: reservado para uma etapa futura de permissões mais limitadas; ainda não entra no painel geral.

## Limites desta etapa
Esta implementação protege a entrada do painel com Supabase Auth e verifica o papel do usuário no banco. Os cadastros de tratamentos e promoções ainda são armazenados no navegador (`localStorage`); eles não são sincronizados e não devem ser considerados protegidos por autorização de banco até a migração dessas tabelas e políticas RLS. Também falta definir permissões por seção para funcionários, trilha de auditoria e recuperação de senha.
